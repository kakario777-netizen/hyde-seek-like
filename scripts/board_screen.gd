extends Control
## 대동여지도 보드: 행보 상소를 골라 한 칸씩 이동. 지도는 말을 따라 움직이고 손가락으로 끌어 볼 수 있다.

var main
var restore: Dictionary = {}   # 불러오기한 진행 상태

const DAY_LIMIT := 30
const STEP_VALUES := [1, 2, 2, 3, 3, 4]
const ENEMY_TYPES := ["pojol", "walpae"]
const HOP_TIME := 0.3      # 한 칸 뛰는 시간
const STEP_PAUSE := 0.14   # 칸 사이 쉼
const LAND_PAUSE := 0.45   # 도착 후 사건까지 뜸

var nodes: Array = []
var map_scale := 1.8
var pos := 0
var days_left := DAY_LIMIT
var busy := false
var cleared := {}
var talk_idx := 0

var view: Control          # 지도가 보이는 창(잘라 냄)
var world: Control         # 지도 + 칸 + 말 (움직이는 판)
var map_rect: TextureRect
var path_layer: Control
var token: Control
var token_pic: TextureRect
var markers := {}
var cam_tween: Tween
var dragging := false
var place_label: Label
var day_label: Label
var hp_label: Label
var hint_label: Label
var card_row: HBoxContainer
var hud: PanelContainer
var tray: PanelContainer

func _ready() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/board1.json"))
	nodes = data["nodes"]
	map_scale = data.get("scale", 1.8)
	if not restore.is_empty():
		pos = int(restore.get("pos", 0))
		days_left = int(restore.get("days_left", DAY_LIMIT))
		talk_idx = int(restore.get("talk_idx", 0))
		for k in restore.get("cleared", []):
			cleared[int(k)] = true

	var bt: Texture2D = main.backdrop("street_ink")
	if bt:
		var bgr := TextureRect.new()
		bgr.texture = bt
		bgr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bgr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bgr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bgr.modulate = Color(0.45, 0.4, 0.38)
		bgr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bgr)

	_build_hud()
	_build_tray()

	# 지도 창 (목각 테두리 안쪽만 보이게)
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", main.tex_box("panel", 74, 22))
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.name = "MapFrame"
	add_child(frame)
	view = Control.new()
	view.clip_contents = true
	view.mouse_filter = Control.MOUSE_FILTER_STOP
	view.gui_input.connect(_on_view_input)
	frame.add_child(view)

	world = Control.new()
	world.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view.add_child(world)
	map_rect = TextureRect.new()
	map_rect.texture = load("res://assets/ui/" + data["map"])
	map_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	map_rect.stretch_mode = TextureRect.STRETCH_SCALE
	map_rect.size = map_rect.texture.get_size() * map_scale
	map_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	world.add_child(map_rect)
	world.size = map_rect.size

	path_layer = Control.new()
	path_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	path_layer.size = world.size
	path_layer.draw.connect(_draw_path)
	world.add_child(path_layer)

	for i in nodes.size():
		var m := _make_marker(i)
		m.position = _node_px(i)
		world.add_child(m)
		markers[i] = m
		if cleared.has(i):
			m.modulate = Color(0.7, 0.68, 0.65, 0.6)

	token = _make_token()
	token.position = _node_px(pos)
	world.add_child(token)

	resized.connect(_layout)
	_layout.call_deferred()
	_intro.call_deferred()

func _intro() -> void:
	busy = true
	_update_hud()
	path_layer.queue_redraw()
	await get_tree().create_timer(0.6).timeout
	# 불러온 자리가 아직 처리 안 된 사건 칸이면 바로 이어서 처리
	if pos > 0 and not cleared.has(pos) and _ntype(pos) != "empty":
		_resolve()
		return
	_deal()
	busy = false

func get_state() -> Dictionary:
	return {"pos": pos, "days_left": days_left, "talk_idx": talk_idx, "cleared": cleared.keys()}

func place_name() -> String:
	for i in range(pos, -1, -1):
		if nodes[i].has("name"):
			return nodes[i]["name"]
	return ""

# ── 칸 표식 ─────────────────────────────────────────────
func _node_px(i: int) -> Vector2:
	return Vector2(nodes[i]["x"], nodes[i]["y"]) * world.size

func _ntype(i: int) -> String:
	var t: String = nodes[i]["type"]
	return "story" if t.begins_with("story") else t

func _make_marker(i: int) -> Control:
	var t := _ntype(i)
	var m := Control.new()
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var coin_name := "node"
	match t:
		"pojol", "walpae", "trap": coin_name = "node_enemy"
		"start", "goal": coin_name = "node_goal"
		"buff", "rest": coin_name = "node_buff"
		"debuff": coin_name = "node_debuff"
		"story": coin_name = "node_story"
	var big := t in ["goal", "start", "story"]
	var sz := Vector2(54, 54) if big else Vector2(40, 40)
	var coin: TextureRect = main.tex_rect(main.ui(coin_name), sz)
	coin.position = -sz / 2
	m.add_child(coin)
	var ic := ""
	match t:
		"talk", "item", "shop", "goal", "pojol", "walpae", "buff", "debuff", "trap", "rest", "story":
			ic = t
	if ic != "":
		var badge := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("f3e6c8"); sb.border_color = Color("5a3a1e"); sb.set_border_width_all(3)
		sb.set_corner_radius_all(40); sb.set_content_margin_all(3)
		sb.shadow_color = Color(0, 0, 0, 0.35); sb.shadow_size = 4
		badge.add_theme_stylebox_override("panel", sb)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.add_child(main.tex_rect(main.icon(ic), Vector2(34, 34)))
		badge.position = Vector2(-20, -(sz.y / 2) - 46)
		m.add_child(badge)
	if nodes[i].has("name"):
		var p := PanelContainer.new()
		p.add_theme_stylebox_override("panel", main.plaque_style())
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var l: Label = main.make_label(nodes[i]["name"], 20, main.GOLD, true)
		p.add_child(l)
		p.position = Vector2(-70, sz.y / 2 + 2)
		m.add_child(p)
	return m

func _make_token() -> Control:
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sh := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0.35); sb.set_corner_radius_all(30)
	sh.add_theme_stylebox_override("panel", sb)
	sh.size = Vector2(56, 16); sh.position = Vector2(-28, -6)
	sh.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(sh)
	var t: Texture2D = main.illust(main.token_name())
	token_pic = main.tex_rect(t, Vector2(108, 114))
	token_pic.position = Vector2(-54, -108)
	root.add_child(token_pic)
	return root

func _draw_path() -> void:
	for i in range(nodes.size() - 1):
		var a := _node_px(i); var b := _node_px(i + 1)
		var col := Color(0.55, 0.1, 0.06, 0.85) if i >= pos else Color(0.25, 0.2, 0.16, 0.4)
		var n := int(a.distance_to(b) / 10)
		for k in n:
			if k % 2 == 0:
				path_layer.draw_line(a.lerp(b, float(k) / n), a.lerp(b, float(k + 1) / n), col, 5.0)

# ── 배치 / 카메라 ───────────────────────────────────────
func _layout() -> void:
	var frame: Control = get_node("MapFrame")
	var top := hud.position.y + hud.size.y + 4
	var bottom := tray.position.y - 4
	frame.position = Vector2(4, top)
	frame.size = Vector2(size.x - 8, max(240.0, bottom - top))
	_focus(_node_px(pos), false)

func _clamp_world(p: Vector2) -> Vector2:
	var vs := view.size
	p.x = clamp(p.x, min(0.0, vs.x - world.size.x), 0.0)
	p.y = clamp(p.y, min(0.0, vs.y - world.size.y), 0.0)
	return p

func _focus(target: Vector2, animate := true, dur := 0.45) -> void:
	if view == null or view.size == Vector2.ZERO:
		return
	var want := _clamp_world(view.size / 2.0 - target - Vector2(0, -40))
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
	var title: Label = main.make_label("제1장  누명", 34, main.GOLD, true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var me: Button = main.make_button("◎", 26)
	me.custom_minimum_size = Vector2(70, 66)
	head.add_child(me)
	me.pressed.connect(func(): _focus(_node_px(pos)))
	var menu: Button = main.make_button("메뉴", 26)
	menu.custom_minimum_size = Vector2(110, 66)
	head.add_child(menu)
	menu.pressed.connect(func():
		if not busy:
			main.open_menu())
	var bag: Button = main.make_button("보따리", 26)
	bag.custom_minimum_size = Vector2(140, 66)
	head.add_child(bag)
	bag.pressed.connect(func():
		if not busy:
			main.show_bag())
	place_label = main.make_label("", 24, Color("e9c9a0"))
	vb.add_child(place_label)
	var row := HBoxContainer.new()
	vb.add_child(row)
	day_label = main.make_label("", 26, main.LIGHT, true)
	day_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(day_label)
	hp_label = main.make_label("", 24, main.LIGHT)
	row.add_child(hp_label)

func _update_hud() -> void:
	day_label.text = "남은 날  %d일" % days_left
	day_label.add_theme_color_override("font_color", main.LIGHT if days_left > 7 else Color("ff8a70"))
	hp_label.text = "체력 %d/%d · 엽전 %d · 약병 %d" % [main.hp, main.max_hp, main.coins, main.potions]
	place_label.text = "%s 부근 · 화엄골까지 %d칸" % [place_name(), nodes.size() - 1 - pos]

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
	hint_label = main.make_label("행보 상소를 고르십시오", 28, main.GOLD, true)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(hint_label)
	card_row = HBoxContainer.new()
	card_row.alignment = BoxContainer.ALIGNMENT_CENTER
	card_row.add_theme_constant_override("separation", 18)
	card_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(card_row)

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
		tw.tween_property(b, "modulate:a", 1.0, 0.28).set_delay(0.12 + i * 0.16)
		tw.tween_property(b, "scale", Vector2.ONE, 0.28).set_delay(0.12 + i * 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	hint_label.text = "행보 상소를 고르십시오"

# ── 이동 ────────────────────────────────────────────────
func _play(steps: int, chosen: Button) -> void:
	if busy:
		return
	busy = true
	for c in card_row.get_children():
		c.disabled = true
		if c != chosen:
			create_tween().tween_property(c, "modulate:a", 0.25, 0.25)
	var lift := create_tween().set_parallel()
	lift.tween_property(chosen, "scale", Vector2(1.12, 1.12), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	lift.tween_property(chosen, "modulate", Color(1.15, 1.05, 0.9), 0.25)
	await lift.finished
	await get_tree().create_timer(0.25).timeout
	days_left -= 1
	_update_hud()
	hint_label.text = "%s 걸음 나아갑니다…" % main.STEP_WORD[steps]
	_focus(_node_px(pos), true, 0.35)
	await get_tree().create_timer(0.35).timeout
	for s in steps:
		if pos >= nodes.size() - 1:
			break
		pos += 1
		var target := _node_px(pos)
		_focus(target, true, HOP_TIME + STEP_PAUSE)
		var tw := create_tween()
		tw.tween_property(token, "position", token.position.lerp(target, 0.5) - Vector2(0, 34), HOP_TIME * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(token, "position", target, HOP_TIME * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_property(token_pic, "scale", Vector2(1.08, 0.92), 0.06)
		tw.tween_property(token_pic, "scale", Vector2.ONE, 0.08)
		await tw.finished
		path_layer.queue_redraw()
		_update_hud()
		await get_tree().create_timer(STEP_PAUSE).timeout
		var t := _ntype(pos)
		if (t in ENEMY_TYPES or t == "story") and not cleared.has(pos):
			break   # 적이나 이야기 칸에서는 멈춘다
	await get_tree().create_timer(LAND_PAUSE).timeout
	_resolve()

func _resolve() -> void:
	var t := _ntype(pos)
	if cleared.has(pos):
		t = "empty"
	match t:
		"talk":
			_clear(pos)
			var talk: Dictionary = GameData.TALKS[talk_idx % GameData.TALKS.size()]
			talk_idx += 1
			var extra := ""
			if talk.has("coin"):
				main.coins += talk["coin"]; extra += "\n\n(엽전 +%d냥)" % talk["coin"]
			if talk.has("potion"):
				main.potions += talk["potion"]; extra += "\n\n(약병 +%d)" % talk["potion"]
			main.popup(talk["text"] + extra, "고맙습니다", _end_turn, talk["who"], talk.get("pic", ""))
		"item":
			_clear(pos)
			main.potions += 1
			main.popup("길섶에서 약초 주머니를 주웠다!\n다래가 금세 약병 하나로 달여 냈다.\n\n(약병 +1)", "챙긴다", _end_turn, "약초", "friend")
		"buff":
			_clear(pos)
			_apply_event(GameData.BUFFS.pick_random())
		"debuff":
			_clear(pos)
			_apply_event(GameData.DEBUFFS.pick_random())
		"trap":
			_clear(pos)
			_apply_event(GameData.TRAPS.pick_random())
		"rest":
			_clear(pos)
			_apply_event(GameData.REST)
		"story":
			_clear(pos)
			var lines: Array = GameData.STORY1 if nodes[pos]["type"] == "story1" else GameData.STORY2
			main.dialog_chain(lines, _end_turn)
		"pojol", "walpae":
			var e: Dictionary = GameData.ENEMIES[t]
			var line := "포졸이 두 소녀를 수상하게 노려본다!\n\"거기 계집아이들, 잠깐 서 봐라!\"" if t == "pojol" else "왈패가 길을 턱 막아섰다!\n\"어이, 가진 거 다 내놓고 가라.\""
			var idx := pos
			main.popup(line, "맞서 싸운다", func(): _fight(t, idx), e["name"], t)
		"shop":
			main.popup("대구 약령시.\n전국의 약재와 물건이 모이는 큰 장이 섰다.", "둘러본다", func():
				main.open_shop(_end_turn), "약령시", "", "jangteo")
		"goal":
			main.popup("안개 낀 계곡 끝, 대숲 속 초당이 보인다.\n지리산 화엄골에 도착했다!", "들어간다", main.chapter_clear, "화엄골", "friend", "byeolchae")
		_:
			_end_turn()

func _fight(enemy: String, idx: int) -> void:
	main.start_battle(enemy, func():
		cleared[idx] = true
		_dim_marker(idx)
		_end_turn())

func _apply_event(ev: Dictionary) -> void:
	if ev.has("heal"):
		main.hp = min(main.max_hp, main.hp + int(ev["heal"]))
	if ev.has("maxhp"):
		main.max_hp += int(ev["maxhp"])
	if ev.has("hp"):
		main.hp = max(1, main.hp + int(ev["hp"]))
	if ev.has("energy"):
		main.next_energy += int(ev["energy"])
	if ev.has("guard"):
		main.next_guard += int(ev["guard"])
	if ev.has("day"):
		days_left += int(ev["day"])
	if ev.has("coin"):
		main.coins = max(0, main.coins + int(ev["coin"]))
	_update_hud()
	if ev.has("battle"):
		var idx := pos
		main.popup(ev["text"], "맞서 싸운다", func(): _fight(ev["battle"], idx), ev["title"], "walpae")
	else:
		main.popup(ev["text"], "계속 간다", _end_turn, ev["title"], ev.get("pic", ""))

func _clear(i: int) -> void:
	cleared[i] = true
	_dim_marker(i)

func _dim_marker(i: int) -> void:
	if markers.has(i):
		create_tween().tween_property(markers[i], "modulate", Color(0.7, 0.68, 0.65, 0.6), 0.4)

func _end_turn() -> void:
	_update_hud()
	if days_left <= 0:
		main.game_over("서른 날이 다 지났다.\n\"게 섰거라! 방에 붙은 그 계집아이로구나!\"\n뒤쫓아 온 순라꾼에게 붙잡히고 말았다…", "sunra")
		return
	busy = false
	_focus(_node_px(pos))
	_deal()
