extends Control
## 작은 맵(쿼터뷰) 스테이지: 행보 상소(1~6칸)로 길을 따라 나아간다.
## 붉은 칸 = 감시꾼의 눈길. 그 칸에서 멈추면 싸움. 길을 막은 적은 지나갈 수 없다.

var main
var restore: Dictionary = {}

const TW := 160.0
const TH := 80.0
const STEP_VALUES := [1, 2, 3, 4, 5, 6]
const HOP_TIME := 0.32
const STEP_PAUSE := 0.12
const BLOCKERS := ["walpae", "pojol", "boss"]

var cfg: Dictionary
var stage_cfg: Dictionary
var data: Dictionary
var tiles: Array = []
var guards: Array = []
var pos := 0
var turns_left := 10
var busy := false
var cleared := {}
var guards_done := {}
var herbs_got := 0
var herbs_total := 0
var talk_idx := 0

var view: Control
var world: Control
var overlay: Control
var token: Control
var token_pic: TextureRect
var tile_nodes := {}
var ent_nodes := {}
var guard_nodes := {}
var cam_tween: Tween
var origin := Vector2.ZERO
var hud: PanelContainer
var tray: PanelContainer
var title_lbl: Label
var info_lbl: Label
var clock_lbl: Label
var hint_label: Label
var card_row: HBoxContainer

func _ready() -> void:
	cfg = main.ch_cfg()
	var stages: Array = cfg["stages"]
	stage_cfg = stages[clampi(main.stage_idx, 0, stages.size() - 1)]
	data = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/stages/%s.json" % stage_cfg["map"]))
	tiles = data["tiles"]
	guards = data["guards"]
	turns_left = int(data["turns"])
	for t in tiles:
		if t.get("herb", false):
			herbs_total += 1
	if not restore.is_empty():
		pos = int(restore.get("pos", 0))
		turns_left = int(restore.get("turns", turns_left))
		herbs_got = int(restore.get("herbs", 0))
		talk_idx = int(restore.get("talk_idx", 0))
		for k in restore.get("cleared", []):
			cleared[int(k)] = true
		for k in restore.get("guards_done", []):
			guards_done[int(k)] = true

	var bgr := TextureRect.new()
	bgr.texture = main.backdrop(data.get("bg", "street_ink"))
	bgr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bgr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bgr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bgr.modulate = Color(0.32, 0.27, 0.28)
	bgr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bgr)

	view = Control.new()
	view.clip_contents = true
	view.mouse_filter = Control.MOUSE_FILTER_STOP
	view.gui_input.connect(_on_view_input)
	add_child(view)
	world = Control.new()
	world.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view.add_child(world)
	_build_world()

	_build_hud()
	_build_tray()
	resized.connect(_layout)
	_layout.call_deferred()
	_intro.call_deferred()

# ── 맵 그리기 ───────────────────────────────────────────
func _iso(x: float, y: float) -> Vector2:
	return origin + Vector2((x - y) * TW / 2.0, (x + y) * TH / 2.0)

func tile_center(i: int) -> Vector2:
	return _iso(tiles[i]["x"], tiles[i]["y"]) + Vector2(0, TH / 2.0)

func _guard_center(g: Dictionary) -> Vector2:
	return _iso(g["x"], g["y"]) + Vector2(0, TH / 2.0)

func _build_world() -> void:
	var cells := []
	for i in tiles.size():
		cells.append({"x": tiles[i]["x"], "y": tiles[i]["y"], "i": i})
	for g in guards:
		if not g.get("on_path", false):
			cells.append({"x": g["x"], "y": g["y"], "i": -1})
	var minx := 1e9; var maxx := -1e9; var miny := 1e9; var maxy := -1e9
	for c in cells:
		var p := Vector2((c["x"] - c["y"]) * TW / 2.0, (c["x"] + c["y"]) * TH / 2.0)
		minx = min(minx, p.x); maxx = max(maxx, p.x); miny = min(miny, p.y); maxy = max(maxy, p.y)
	origin = Vector2(-minx + TW / 2.0 + 400, -miny + 420)
	world.size = Vector2(maxx - minx + TW + 800, maxy - miny + TH + 900)

	cells.sort_custom(func(a, b): return a["x"] + a["y"] < b["x"] + b["y"])
	var tex: Texture2D = load("res://assets/ui/tiles/tile_%s.png" % data.get("tile", "stone"))
	for c in cells:
		var tr := TextureRect.new()
		tr.texture = tex
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tr.position = _iso(c["x"], c["y"]) - Vector2(TW / 2.0, 0)
		if c["i"] < 0:
			tr.modulate = Color(0.7, 0.66, 0.66)
		world.add_child(tr)
		if c["i"] >= 0:
			tile_nodes[c["i"]] = tr

	overlay = Control.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.size = world.size
	overlay.draw.connect(_draw_overlay)
	world.add_child(overlay)

	# 장식·인물: 앞뒤 순서대로
	var ents := []
	for i in tiles.size():
		ents.append({"d": tiles[i]["x"] + tiles[i]["y"], "kind": "tile", "i": i})
	for gi in guards.size():
		ents.append({"d": guards[gi]["x"] + guards[gi]["y"], "kind": "guard", "i": gi})
	ents.sort_custom(func(a, b): return a["d"] < b["d"])
	for e in ents:
		if e["kind"] == "tile":
			_make_tile_ent(e["i"])
		else:
			_make_guard(e["i"])
	token = _make_token()
	token.position = tile_center(pos)
	world.add_child(token)

func _sprite(pic: String, h: float) -> TextureRect:
	var t: Texture2D = main.illust(pic)
	if t == null:
		t = main.icon("walpae")
	var w: float = h * t.get_width() / max(1.0, float(t.get_height()))
	var r: TextureRect = main.tex_rect(t, Vector2(w, h))
	r.position = Vector2(-w / 2.0, -h + 8)
	return r

func _make_tile_ent(i: int) -> void:
	var t: Dictionary = tiles[i]
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.position = tile_center(i)
	var typ: String = t["type"]
	match typ:
		"spike":
			var s: TextureRect = main.tex_rect(load("res://assets/ui/tiles/deco_spike.png"), Vector2(TW, 110))
			s.position = Vector2(-TW / 2.0, -80)
			root.add_child(s)
		"goal":
			var g: TextureRect = main.tex_rect(load("res://assets/ui/tiles/deco_gate.png"), Vector2(TW * 1.4, 238))
			g.position = Vector2(-TW * 0.7, -210)
			root.add_child(g)
		"walpae", "pojol":
			var eid := _enemy_id(typ)
			root.add_child(_sprite(GameData.ENEMIES[eid]["sprite"], 170))
			root.add_child(_badge("walpae" if typ == "walpae" else "pojol", Vector2(-22, -210), Color("f3d0c8")))
		"boss":
			root.add_child(_sprite(GameData.ENEMIES[t["battle"]]["sprite"], 210))
			root.add_child(_badge("walpae", Vector2(-22, -250), Color("ffb0a0")))
		"talk":
			var tk: Dictionary = _talk_at(i)
			var pic: String = tk.get("pic", WHO_PIC.get(tk.get("who", ""), ""))
			if pic != "" and main.illust(pic) != null:
				root.add_child(_sprite(pic, 165))
				root.add_child(_badge("talk", Vector2(-24, -205), Color("f3e6c8")))
			else:
				root.add_child(_badge("talk", Vector2(-24, -70), Color("f3e6c8")))
		"shop":
			root.add_child(_sprite("yakjae", 150) if main.illust("yakjae") != null else Control.new())
			root.add_child(_badge("shop", Vector2(-24, -190), Color("f3e6c8")))
		"item", "buff", "debuff", "trap", "rest":
			root.add_child(_badge(typ, Vector2(-24, -70), Color("f3e6c8")))
	if t.get("herb", false):
		var h: TextureRect = main.tex_rect(load("res://assets/ui/tiles/deco_herb.png"), Vector2(64, 78))
		h.position = Vector2(-10, -64)
		h.name = "Herb"
		root.add_child(h)
		if typ == "empty":
			pass
	world.add_child(root)
	ent_nodes[i] = root
	if cleared.has(i):
		_hide_ent(i, false)

func _badge(ic: String, at: Vector2, bgcol: Color) -> PanelContainer:
	var badge := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = bgcol; sb.border_color = Color("5a3a1e"); sb.set_border_width_all(3)
	sb.set_corner_radius_all(40); sb.set_content_margin_all(4)
	sb.shadow_color = Color(0, 0, 0, 0.4); sb.shadow_size = 5
	badge.add_theme_stylebox_override("panel", sb)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_child(main.tex_rect(main.icon(ic), Vector2(40, 40)))
	badge.position = at
	return badge

func _make_guard(gi: int) -> void:
	var g: Dictionary = guards[gi]
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.position = _guard_center(g)
	root.add_child(_sprite(GameData.ENEMIES[_enemy_id(g["kind"])]["sprite"], 165))
	var eye: Label = main.make_label("!", 40, Color("ff6a5a"), true)
	main.ink_text(eye, 10)
	eye.position = Vector2(-8, -220)
	root.add_child(eye)
	world.add_child(root)
	guard_nodes[gi] = root
	if guards_done.has(gi):
		root.visible = false

func _make_token() -> Control:
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sh := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0.4); sb.set_corner_radius_all(30)
	sh.add_theme_stylebox_override("panel", sb)
	sh.size = Vector2(70, 22); sh.position = Vector2(-35, -10)
	sh.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(sh)
	token_pic = main.tex_rect(main.illust(main.token_name()), Vector2(132, 140))
	token_pic.position = Vector2(-66, -132)
	token_pic.pivot_offset = Vector2(66, 140)
	root.add_child(token_pic)
	return root

func _diamond(c: Vector2, shrink := 0.0) -> PackedVector2Array:
	var hw := TW / 2.0 - shrink; var hh := TH / 2.0 - shrink / 2.0
	return PackedVector2Array([c + Vector2(0, -hh), c + Vector2(hw, 0), c + Vector2(0, hh), c + Vector2(-hw, 0)])

func _draw_overlay() -> void:
	for gi in guards.size():
		if guards_done.has(gi):
			continue
		for k in guards[gi]["zone"]:
			overlay.draw_colored_polygon(_diamond(tile_center(int(k)), 6), Color(0.85, 0.15, 0.1, 0.45))
	for i in tiles.size():
		if i < pos:
			overlay.draw_colored_polygon(_diamond(tile_center(i), 30), Color(0.15, 0.1, 0.05, 0.25))
	overlay.draw_colored_polygon(_diamond(tile_center(pos), 4), Color(0.3, 0.85, 0.4, 0.4))
	overlay.draw_polyline(_closed(_diamond(tile_center(pos), 4)), Color(0.5, 1, 0.6, 0.9), 3.0)

func _closed(p: PackedVector2Array) -> PackedVector2Array:
	var q := p.duplicate(); q.append(p[0]); return q

func _enemy_id(t: String) -> String:
	return StoryData.ENEMY_MAP.get(main.chapter, {}).get(t, t)

# ── 배치 / 카메라 ───────────────────────────────────────
func _layout() -> void:
	var top := hud.position.y + hud.size.y
	var bottom := tray.position.y
	view.position = Vector2(0, top)
	view.size = Vector2(size.x, max(200.0, bottom - top))
	_focus(tile_center(pos), false)

func _clamp_world(p: Vector2) -> Vector2:
	var vs := view.size
	p.x = clamp(p.x, min(0.0, vs.x - world.size.x), 0.0)
	p.y = clamp(p.y, min(0.0, vs.y - world.size.y), 0.0)
	return p

func _focus(target: Vector2, animate := true, dur := 0.45) -> void:
	if view == null or view.size == Vector2.ZERO:
		return
	var want := _clamp_world(view.size / 2.0 - target + Vector2(0, 60))
	if cam_tween and cam_tween.is_valid():
		cam_tween.kill()
	if not animate:
		world.position = want
		return
	cam_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	cam_tween.tween_property(world, "position", want, dur)

func _on_view_input(e: InputEvent) -> void:
	if busy:
		return
	if e is InputEventScreenDrag:
		world.position = _clamp_world(world.position + e.relative)
	elif e is InputEventMouseMotion and (e.button_mask & MOUSE_BUTTON_MASK_LEFT):
		world.position = _clamp_world(world.position + e.relative)

# ── HUD ─────────────────────────────────────────────────
func _build_hud() -> void:
	hud = PanelContainer.new()
	hud.add_theme_stylebox_override("panel", main.bar_style())
	hud.anchor_right = 1.0
	hud.offset_left = 4; hud.offset_right = -4; hud.offset_top = 4
	add_child(hud)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 2)
	hud.add_child(vb)
	var head := HBoxContainer.new()
	vb.add_child(head)
	title_lbl = main.make_label(cfg.get("title", ""), 30, main.GOLD, true)
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title_lbl)
	var me: Button = main.make_button("◎", 24)
	me.custom_minimum_size = Vector2(64, 62)
	head.add_child(me)
	me.pressed.connect(func(): _focus(tile_center(pos)))
	var menu: Button = main.make_button("메뉴", 24)
	menu.custom_minimum_size = Vector2(100, 62)
	head.add_child(menu)
	menu.pressed.connect(func():
		if not busy:
			main.open_menu())
	var bag: Button = main.make_button("보따리", 24)
	bag.custom_minimum_size = Vector2(130, 62)
	head.add_child(bag)
	bag.pressed.connect(func():
		if not busy:
			main.show_bag())
	var sname: Label = main.make_label("〈%s〉  %d / %d" % [stage_cfg["name"], main.stage_idx + 1, cfg["stages"].size()], 24, Color("e9c9a0"))
	vb.add_child(sname)
	var row := HBoxContainer.new()
	vb.add_child(row)
	clock_lbl = main.make_label("", 26, main.LIGHT, true)
	clock_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(clock_lbl)
	info_lbl = main.make_label("", 22, main.LIGHT)
	row.add_child(info_lbl)
	_update_hud()

func _update_hud() -> void:
	clock_lbl.text = "남은 시각 %d" % turns_left
	clock_lbl.add_theme_color_override("font_color", main.LIGHT if turns_left > 3 else Color("ff8a70"))
	info_lbl.text = "약초 %d/%d · 체력 %d/%d · 엽전 %d · 약병 %d" % [herbs_got, herbs_total, main.hp, main.max_hp, main.coins, main.potions]

func _build_tray() -> void:
	tray = PanelContainer.new()
	tray.add_theme_stylebox_override("panel", main.bar_style())
	tray.anchor_top = 1.0; tray.anchor_bottom = 1.0; tray.anchor_right = 1.0
	tray.offset_left = 4; tray.offset_right = -4
	tray.offset_top = -384; tray.offset_bottom = -4
	add_child(tray)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	tray.add_child(vb)
	hint_label = main.make_label("행보 상소를 고르십시오", 26, main.GOLD, true)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(hint_label)
	card_row = HBoxContainer.new()
	card_row.alignment = BoxContainer.ALIGNMENT_CENTER
	card_row.add_theme_constant_override("separation", 18)
	card_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(card_row)

func _intro() -> void:
	main.bgm("travel")
	busy = true
	_update_hud()
	await get_tree().process_frame
	await get_tree().process_frame
	_layout()
	if pos == 0 and restore.is_empty():
		await get_tree().create_timer(0.3).timeout
		main.popup("〈%s〉\n\n붉은 칸은 감시꾼의 눈길입니다. 그 칸에서 멈추면 들킵니다.\n남은 시각 안에 대문까지 가십시오." % stage_cfg["name"], "출발", func():
			busy = false
			_deal(), cfg.get("title", ""))
		return
	await get_tree().create_timer(0.4).timeout
	_deal()
	busy = false

func get_state() -> Dictionary:
	return {"pos": pos, "turns": turns_left, "herbs": herbs_got, "talk_idx": talk_idx,
		"cleared": cleared.keys(), "guards_done": guards_done.keys(), "days_left": turns_left}

func place_name() -> String:
	return stage_cfg.get("name", "")

func _deal() -> void:
	for c in card_row.get_children():
		c.queue_free()
	for i in 3:
		var v: int = STEP_VALUES.pick_random()
		var b: Button = main.step_card(v, 186, 282)
		b.modulate.a = 0.0
		card_row.add_child(b)
		b.pressed.connect(func(): _play(v, b))
		b.pivot_offset = Vector2(93, 141)
		b.scale = Vector2(0.8, 0.8)
		var tw := create_tween().set_parallel()
		tw.tween_property(b, "modulate:a", 1.0, 0.28).set_delay(0.1 + i * 0.15)
		tw.tween_property(b, "scale", Vector2.ONE, 0.28).set_delay(0.1 + i * 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	hint_label.text = "행보 상소를 고르십시오 · 대문까지 %d칸" % (tiles.size() - 1 - pos)

# ── 이동 ────────────────────────────────────────────────
func _blocks(i: int) -> bool:
	return tiles[i]["type"] in BLOCKERS and not cleared.has(i)

func _play(steps: int, chosen: Button) -> void:
	if busy:
		return
	busy = true
	main.sfx("card_play")
	for c in card_row.get_children():
		c.disabled = true
		if c != chosen:
			create_tween().tween_property(c, "modulate:a", 0.25, 0.25)
	var lift := create_tween().set_parallel()
	lift.tween_property(chosen, "scale", Vector2(1.12, 1.12), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await lift.finished
	await get_tree().create_timer(0.2).timeout
	turns_left -= 1
	_update_hud()
	hint_label.text = "%s 걸음 나아갑니다…" % main.STEP_WORD[steps]
	_focus(tile_center(pos), true, 0.3)
	await get_tree().create_timer(0.3).timeout
	for s in steps:
		if pos >= tiles.size() - 1:
			break
		pos += 1
		var target := tile_center(pos)
		_focus(target, true, HOP_TIME + STEP_PAUSE)
		var tw := create_tween()
		tw.tween_property(token, "position", token.position.lerp(target, 0.5) - Vector2(0, 40), HOP_TIME * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(token, "position", target, HOP_TIME * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_callback(func(): main.sfx("step", -4.0))
		tw.tween_property(token_pic, "scale", Vector2(1.08, 0.92), 0.06)
		tw.tween_property(token_pic, "scale", Vector2.ONE, 0.08)
		await tw.finished
		overlay.queue_redraw()
		await get_tree().create_timer(STEP_PAUSE).timeout
		if _blocks(pos):
			break
	await get_tree().create_timer(0.35).timeout
	_pick_herb(pos)  # 약초는 그 칸에 딱 멈춰야 얻는다
	_resolve()

func _pick_herb(i: int) -> void:
	var t: Dictionary = tiles[i]
	if not t.get("herb", false) or ent_nodes[i].get_node_or_null("Herb") == null:
		return
	var h: Control = ent_nodes[i].get_node("Herb")
	h.name = "HerbTaken"
	herbs_got += 1
	main.coins += 2
	main.sfx("item")
	var tw := create_tween().set_parallel()
	tw.tween_property(h, "position:y", h.position.y - 60, 0.4)
	tw.tween_property(h, "modulate:a", 0.0, 0.4)
	_update_hud()

const WHO_PIC := {"약재 상인": "yakjae", "엿장수": "yeotjangsu", "주막 주모": "jumo", "주모": "jumo", "물장수": "muljangsu",
	"포졸": "pojol", "백성": "addict", "다래": "friend", "순라꾼": "sunra", "청나라 약재상": "yakjae", "항구 주모": "jumo"}

## 이 칸에서 만날 사람 (칸마다 정해져 있어 맵에 미리 보인다)
func _talk_at(i: int) -> Dictionary:
	var pool: Array = StoryData.talks(main.chapter)
	var k := 0
	for j in i:
		if tiles[j]["type"] == "talk":
			k += 1
	return pool[(main.stage_idx * 3 + k) % pool.size()]

func _resolve() -> void:
	var t: String = tiles[pos]["type"]
	if cleared.has(pos):
		t = "empty"
	match t:
		"walpae", "pojol":
			var eid := _enemy_id(t)
			var e: Dictionary = GameData.ENEMIES[eid]
			var idx := pos
			main.sfx("alarm")
			var talk: Array = [{"who": e["name"], "pic": e["sprite"], "text": BLOCK_LINES.get(eid, "%s이(가) 길을 막아섰다!" % e["name"])}]
			var disg: bool = main.chapter in main.DISGUISED
			for ln in BLOCK_REPLY.get(eid, BLOCK_REPLY["_"]):
				var l2: Dictionary = ln.duplicate()
				if not disg:
					l2["who"] = l2["who"].replace("{alias}", "{name}")
					l2["pic"] = l2["pic"].replace("hero_disguise", "hero")
				talk.append(l2)
			main.dialog_chain(talk, func():
				main.popup("피할 길이 없다. 맞서 싸우자!", "맞서 싸운다", func():
					main.start_battle(eid, func():
						_clear(idx)
						_after_land(true)), e["name"], e["sprite"]))
			return
		"boss":
			var nd: Dictionary = tiles[pos]
			var idx := pos
			main.sfx("alarm")
			main.dialog_chain(StoryData.lines(nd.get("pre", "")), func():
				main.start_battle(nd["battle"], func():
					_clear(idx)
					main.dialog_chain(StoryData.lines(nd.get("post", "")), func(): _after_land(true))))
			return
		"spike":
			main.hp = max(1, main.hp - 6)
			main.sfx("hurt")
			_shake()
			main.popup("숨겨진 죽창 함정을 밟았다!\n\n(체력 -6)", "이를 악물고 간다", func(): _after_land(false), "함정")
			return
		"talk":
			_clear(pos)
			var talk: Dictionary = _talk_at(pos)
			talk_idx += 1
			var extra := ""
			main.sfx("coin" if talk.has("coin") else "item")
			if talk.has("coin"):
				main.coins += talk["coin"]; extra += "\n\n(엽전 +%d냥)" % talk["coin"]
			if talk.has("potion"):
				main.potions += talk["potion"]; extra += "\n\n(약병 +%d)" % talk["potion"]
			main.popup(talk["text"] + extra, "고맙습니다", func(): _after_land(false), talk["who"], talk.get("pic", ""))
			return
		"item":
			_clear(pos)
			main.potions += 1
			main.sfx("item")
			main.popup("길섶에서 약초 주머니를 주웠다!\n곧 약병 하나로 달여 냈다.\n\n(약병 +1)", "챙긴다", func(): _after_land(false), "약초")
			return
		"buff":
			_clear(pos); _apply_event(GameData.BUFFS.pick_random()); return
		"debuff":
			_clear(pos); _apply_event(GameData.DEBUFFS.pick_random()); return
		"trap":
			_clear(pos); _apply_event(GameData.TRAPS.pick_random()); return
		"rest":
			_clear(pos); _apply_event(GameData.REST); return
		"shop":
			main.popup("길가에 장이 섰다.\n약재와 물건을 사고팔 수 있다.", "둘러본다", func():
				main.open_shop(func(): _after_land(false)), "장터", "", "jangteo")
			return
		"goal":
			_stage_clear()
			return
	_after_land(false)

## 사건 뒤: 감시꾼 눈길 확인 → 차례 끝
func _after_land(_fought: bool) -> void:
	_update_hud()
	for gi in guards.size():
		if guards_done.has(gi):
			continue
		if pos in guards[gi]["zone"].map(func(z): return int(z)):
			var eid := _enemy_id(guards[gi]["kind"])
			var e: Dictionary = GameData.ENEMIES[eid]
			var g := gi
			main.sfx("alarm")
			_alert(gi)
			main.popup("들켰다!\n%s이(가) 이쪽을 노려보며 다가온다." % e["name"], "맞서 싸운다", func():
				main.start_battle(eid, func():
					guards_done[g] = true
					create_tween().tween_property(guard_nodes[g], "modulate:a", 0.0, 0.4)
					overlay.queue_redraw()
					_end_turn()), e["name"], e["sprite"])
			return
	_end_turn()

func _alert(gi: int) -> void:
	var n: Control = guard_nodes[gi]
	var tw := create_tween()
	tw.tween_property(n, "position:y", n.position.y - 24, 0.12)
	tw.tween_property(n, "position:y", n.position.y, 0.12)

func _shake() -> void:
	var tw := create_tween()
	tw.tween_property(token, "position:x", token.position.x + 10, 0.05)
	tw.tween_property(token, "position:x", token.position.x - 10, 0.08)
	tw.tween_property(token, "position:x", token.position.x, 0.05)

## 길막이와 마주쳤을 때 주고받는 짧은 이야기
const BLOCK_REPLY := {
	"_": [{"who": "{alias}", "pic": "hero_disguise_angry", "text": "(돌아갈 길도 없어… 여기서 물러설 순 없어!)"}],
	"pojol": [{"who": "{alias}", "pic": "hero_disguise_sad", "text": "저는 그냥 약초 팔러 가는 길인데요…"},
		{"who": "포졸", "pic": "pojol", "text": "약초꾼이 왜 그리 눈을 피해? 수상하다, 이리 와 봐라!"}],
	"walpae": [{"who": "{alias}", "pic": "hero_disguise_angry", "text": "가진 거라곤 약초 몇 뿌리뿐이에요. 비켜 주세요."},
		{"who": "왈패", "pic": "walpae", "text": "흐흐, 약초도 돈이지. 순순히 안 내놓겠다 이거냐?"}],
	"mob": [{"who": "{name}", "pic": "hero_physician", "text": "진정하세요! 제가 고쳐 드릴 수 있어요!"},
		{"who": "중독된 사내", "pic": "addict", "text": "약…! 그 약 냄새… 내놔아아!"}],
	"haejeok": [{"who": "{alias}", "pic": "hero_disguise_angry", "text": "역병 도는 마을에 약을 가져가는 길이에요. 비켜요!"},
		{"who": "뱃사람", "pic": "walpae", "text": "약이라고? 그럼 더 값나가겠군. 내놔라!"}],
}

const BLOCK_LINES := {
	"pojol": "포졸이 길을 막아섰다!\n\"거기 너, 잠깐 서 봐라!\"",
	"walpae": "왈패가 길을 턱 막아섰다!\n\"어이, 가진 거 다 내놓고 가라.\"",
	"rival": "흑룡파 왈패들이 몰려왔다!\n\"청안파 꼬마 의원이 너냐?\"",
	"sanjeok": "산적이 뛰쳐나왔다!\n\"가진 것 다 내놓고 가라!\"",
	"mob": "청심보명단에 중독된 사내가 달려든다!\n\"약… 약을 내놔…!\"",
	"haejeok": "칼을 찬 뱃사람 무리가 길을 막았다!\n\"이방인, 가진 걸 내놔라!\"",
	"rat": "역병을 옮기는 쥐떼가 우르르 몰려왔다!",
}

func _apply_event(ev: Dictionary) -> void:
	if ev.has("battle"):
		main.sfx("alarm")
	elif ev.has("hp") or ev.has("day") or (ev.has("coin") and int(ev["coin"]) < 0):
		main.sfx("bad")
	else:
		main.sfx("good")
	if ev.has("heal"): main.hp = min(main.max_hp, main.hp + int(ev["heal"]))
	if ev.has("maxhp"): main.max_hp += int(ev["maxhp"])
	if ev.has("hp"): main.hp = max(1, main.hp + int(ev["hp"]))
	if ev.has("energy"): main.next_energy += int(ev["energy"])
	if ev.has("guard"): main.next_guard += int(ev["guard"])
	if ev.has("day"): turns_left = max(1, turns_left + int(ev["day"]))
	if ev.has("coin"): main.coins = max(0, main.coins + int(ev["coin"]))
	_update_hud()
	var text: String = ev["text"].replace("남은 날", "남은 시각").replace("하루를 더 허비했다", "시간을 허비했다").replace("이틀을 잃었다", "시간을 잃었다")
	if ev.has("battle"):
		var eid: String = ev["battle"]
		main.popup(text, "맞서 싸운다", func():
			main.start_battle(eid, func(): _end_turn()), ev["title"], GameData.ENEMIES[eid]["sprite"])
	else:
		main.popup(text, "계속 간다", func(): _after_land(false), ev["title"], ev.get("pic", ""))

func _clear(i: int) -> void:
	cleared[i] = true
	_hide_ent(i, true)

func _hide_ent(i: int, animate: bool) -> void:
	if not ent_nodes.has(i):
		return
	var n: Control = ent_nodes[i]
	for ch in n.get_children():
		if ch.name.begins_with("Herb"):
			continue
		if animate:
			create_tween().tween_property(ch, "modulate:a", 0.0, 0.4)
		else:
			ch.modulate.a = 0.0

func _end_turn() -> void:
	_update_hud()
	overlay.queue_redraw()
	main.bgm("travel")
	if turns_left <= 0:
		main.sfx("gong")
		main.game_over("시각이 다 되었다.\n\"게 섰거라! 통금 시각에 어딜 쏘다니느냐!\"\n순라꾼에게 붙잡히고 말았다…", "sunra")
		return
	busy = false
	_focus(tile_center(pos))
	_deal()

func _stage_clear() -> void:
	main.sfx("victory")
	var bonus: int = turns_left
	main.coins += bonus
	var stages: Array = cfg["stages"]
	var last: bool = main.stage_idx >= stages.size() - 1
	var msg: String = "〈%s〉 통과!\n\n남은 시각 보너스 엽전 +%d냥\n모은 약초 %d/%d" % [stage_cfg["name"], bonus, herbs_got, herbs_total]
	if herbs_got >= herbs_total and herbs_total > 0:
		main.potions += 1
		msg += "\n약초를 모두 모았다! (약병 +1)"
	main.popup(msg, "계속", func():
		if last:
			_reach_goal()
		else:
			main.dialog_chain(StoryData.lines(stage_cfg.get("after", "")), main.next_stage), "", "", data.get("bg", ""))

func _reach_goal() -> void:
	if cfg.has("goal_battle"):
		main.sfx("alarm")
		main.dialog_chain(StoryData.lines(cfg.get("goal_pre", "")), func():
			main.start_battle(cfg["goal_battle"], main.chapter_clear,
				{"lose_ok": cfg.get("goal_lose_ok", false), "ally": cfg.get("goal_ally", ""), "no_reward": true}))
	else:
		main.popup(cfg.get("goal_text", "목적지에 도착했다!"), "들어간다", main.chapter_clear,
			cfg.get("goal_title", ""), cfg.get("goal_pic", ""), cfg.get("goal_bg", ""))
