extends Control
## 수선전도(首善全圖) 보드: 행보 상소를 골라 칸을 이동

var main

const TURN_LIMIT := 14
const STEP_VALUES := [1, 2, 2, 3, 3, 4]
const ENEMY_TYPES := ["pojol", "walpae"]

var nodes: Array = []
var pos := 0
var turns_left := TURN_LIMIT
var busy := false
var cleared := {}
var talk_idx := 0

var map_frame: PanelContainer
var map_rect: TextureRect
var overlay: Control
var token: Control
var markers := {}
var hud_label: Label
var hp_label: Label
var hint_label: Label
var card_row: HBoxContainer
var hud: PanelContainer
var tray: PanelContainer

func _ready() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/board1.json"))
	nodes = data["nodes"]

	map_frame = PanelContainer.new()
	var fs: StyleBoxTexture = main.tex_box("panel", 74, 26)
	map_frame.add_theme_stylebox_override("panel", fs)
	map_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(map_frame)
	map_rect = TextureRect.new()
	map_rect.texture = load("res://assets/ui/" + data["map"])
	map_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	map_rect.stretch_mode = TextureRect.STRETCH_SCALE
	map_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	map_frame.add_child(map_rect)

	overlay = Control.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
	overlay.draw.connect(_draw_path)

	for i in nodes.size():
		var t: String = nodes[i]["type"]
		var m := Control.new()
		m.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var coin_name := "node"
		if t in ENEMY_TYPES: coin_name = "node_enemy"
		elif t in ["goal", "start"]: coin_name = "node_goal"
		var big := t == "goal"
		var coin: TextureRect = main.tex_rect(main.ui(coin_name), Vector2(56, 56) if big else Vector2(38, 38))
		coin.position = -coin.size / 2
		m.add_child(coin)
		var ic := ""
		match t:
			"talk": ic = "talk"
			"item": ic = "item"
			"shop": ic = "shop"
			"goal": ic = "goal"
			"pojol": ic = "pojol"
			"walpae": ic = "walpae"
		if ic != "":
			var badge := PanelContainer.new()
			var sb := StyleBoxFlat.new()
			sb.bg_color = Color("f3e6c8"); sb.border_color = Color("5a3a1e"); sb.set_border_width_all(3)
			sb.set_corner_radius_all(40); sb.set_content_margin_all(4)
			badge.add_theme_stylebox_override("panel", sb)
			badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			badge.add_child(main.tex_rect(main.icon(ic), Vector2(38, 38)))
			badge.position = Vector2(-23, -80 if big else -68)
			m.add_child(badge)
		overlay.add_child(m)
		markers[i] = m

	token = _make_token()
	overlay.add_child(token)

	_build_hud()
	_build_tray()
	resized.connect(_layout)
	_layout.call_deferred()
	_deal()

func _make_token() -> Control:
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var face: Texture2D = main.illust("face_token")
	if face:
		var fr: TextureRect = main.tex_rect(face, Vector2(88, 88))
		fr.position = Vector2(-44, -100)
		root.add_child(fr)
		var pin0 := ColorRect.new()
		pin0.color = Color("d9b45a"); pin0.size = Vector2(6, 16); pin0.position = Vector2(-3, -14)
		root.add_child(pin0)
		return root
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("9a2c22"); sb.border_color = Color("d9b45a"); sb.set_border_width_all(5)
	sb.set_corner_radius_all(48); sb.shadow_color = Color(0, 0, 0, 0.5); sb.shadow_size = 8; sb.shadow_offset = Vector2(0, 5)
	p.add_theme_stylebox_override("panel", sb)
	p.custom_minimum_size = Vector2(76, 76)
	p.size = Vector2(76, 76)
	p.position = Vector2(-38, -84)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l: Label = main.make_label(main.hero_name.left(1), 40, main.GOLD, true)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	p.add_child(l)
	root.add_child(p)
	var pin := ColorRect.new()
	pin.color = Color("d9b45a"); pin.size = Vector2(6, 14); pin.position = Vector2(-3, -10)
	root.add_child(pin)
	return root

# ── 배치 ────────────────────────────────────────────────
func _map_area() -> Rect2:
	var top := hud.position.y + hud.size.y + 6
	var bottom := tray.position.y - 6
	return Rect2(Vector2(0, top), Vector2(size.x, max(200.0, bottom - top)))

func _layout() -> void:
	var area := _map_area()
	var tex_size: Vector2 = map_rect.texture.get_size()
	var pad := 26.0
	var avail := area.size - Vector2(pad, pad) * 2 - Vector2(8, 8)
	var sc: float = min(avail.x / tex_size.x, avail.y / tex_size.y)
	var msz := (tex_size * sc).floor()
	map_frame.size = msz + Vector2(pad, pad) * 2
	map_frame.position = (area.position + (area.size - map_frame.size) / 2).floor()
	map_rect.custom_minimum_size = msz
	overlay.position = map_frame.position + Vector2(pad, pad)
	overlay.size = msz
	for i in nodes.size():
		markers[i].position = _node_px(i)
	token.position = _node_px(pos)
	overlay.queue_redraw()

func _node_px(i: int) -> Vector2:
	return Vector2(nodes[i]["x"], nodes[i]["y"]) * overlay.size

func _draw_path() -> void:
	for i in range(nodes.size() - 1):
		var a := _node_px(i); var b := _node_px(i + 1)
		var col := Color(0.6, 0.12, 0.08, 0.75) if i >= pos else Color(0.3, 0.25, 0.2, 0.35)
		var n := int(a.distance_to(b) / 12)
		for k in n:
			if k % 2 == 0:
				overlay.draw_line(a.lerp(b, float(k) / n), a.lerp(b, float(k + 1) / n), col, 4.0)

# ── HUD ─────────────────────────────────────────────────
func _build_hud() -> void:
	hud = PanelContainer.new()
	hud.add_theme_stylebox_override("panel", main.bar_style())
	hud.anchor_right = 1.0
	hud.offset_left = 6; hud.offset_right = -6; hud.offset_top = 6
	add_child(hud)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 2)
	hud.add_child(vb)
	var head := HBoxContainer.new()
	vb.add_child(head)
	var title: Label = main.make_label("제1장  누명", 34, main.GOLD, true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var bag: Button = main.make_button("보따리", 26)
	bag.custom_minimum_size = Vector2(150, 70)
	head.add_child(bag)
	bag.pressed.connect(func():
		if not busy:
			main.show_bag())
	hud_label = main.make_label("", 26, main.LIGHT)
	vb.add_child(hud_label)
	hp_label = main.make_label("", 26, main.LIGHT)
	vb.add_child(hp_label)
	_update_hud()

func _update_hud() -> void:
	var sun := ""
	for i in TURN_LIMIT:
		sun += "●" if i < turns_left else "○"
	hud_label.text = "남은 시각  %s" % sun
	hp_label.text = "%s  체력 %d/%d · 엽전 %d냥 · 약병 %d" % [main.alias(), main.hp, main.max_hp, main.coins, main.potions]

func _build_tray() -> void:
	tray = PanelContainer.new()
	tray.add_theme_stylebox_override("panel", main.bar_style())
	tray.anchor_top = 1.0; tray.anchor_bottom = 1.0; tray.anchor_right = 1.0
	tray.offset_left = 6; tray.offset_right = -6
	tray.offset_top = -392; tray.offset_bottom = -6
	add_child(tray)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
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
		card_row.add_child(b)
		b.pressed.connect(func(): _play(v))
		b.pivot_offset = Vector2(93, 141)
		b.scale = Vector2(0.7, 0.7)
		create_tween().tween_property(b, "scale", Vector2.ONE, 0.15).set_delay(i * 0.05)

# ── 이동 ────────────────────────────────────────────────
func _play(steps: int) -> void:
	if busy:
		return
	busy = true
	for c in card_row.get_children():
		c.disabled = true
	turns_left -= 1
	_update_hud()
	hint_label.text = "이동 중…"
	for s in steps:
		if pos >= nodes.size() - 1:
			break
		pos += 1
		var target := _node_px(pos)
		var tw := create_tween()
		tw.tween_property(token, "position", token.position.lerp(target, 0.5) - Vector2(0, 26), 0.13)
		tw.tween_property(token, "position", target, 0.13)
		await tw.finished
		overlay.queue_redraw()
		var t: String = nodes[pos]["type"]
		if t in ENEMY_TYPES and not cleared.has(pos):
			break   # 적이 길을 막으면 멈춘다
	_resolve()

func _resolve() -> void:
	var t: String = nodes[pos]["type"]
	if cleared.has(pos):
		t = "empty"
	match t:
		"talk":
			cleared[pos] = true
			_dim_marker(pos)
			var talk: Dictionary = GameData.TALKS[talk_idx % GameData.TALKS.size()]
			talk_idx += 1
			var extra := ""
			if talk.has("coin"):
				main.coins += talk["coin"]; extra += "\n\n(엽전 +%d냥)" % talk["coin"]
			if talk.has("potion"):
				main.potions += talk["potion"]; extra += "\n\n(약병 +%d)" % talk["potion"]
			main.popup(talk["text"] + extra, "고맙습니다", _end_turn, talk["who"])
		"item":
			cleared[pos] = true
			_dim_marker(pos)
			main.potions += 1
			main.popup("길가에서 약초 주머니를 주웠다!\n\n(약병 +1)", "챙긴다", _end_turn, "약초")
		"pojol", "walpae":
			var e: Dictionary = GameData.ENEMIES[t]
			var line := "포졸이 {alias|을} 수상하게 노려본다!\n\"거기 너, 잠깐 서 봐라!\"" if t == "pojol" else "왈패가 길을 턱 막아섰다!\n\"꼬마야, 가진 거 다 내놔라.\""
			var idx := pos
			main.popup(line, "맞서 싸운다", func():
				main.start_battle(t, func():
					cleared[idx] = true
					_dim_marker(idx)
					_end_turn()), e["name"])
		"shop":
			main.popup("운종가 장터에 들어섰다.\n엽전으로 상소와 약병을 살 수 있다.", "둘러본다", func():
				main.open_shop(_end_turn), "운종가")
		"goal":
			main.popup("남산 아래, 허 의원의 별채에 도착했다!", "들어간다", main.chapter_clear, "남산 별채")
		_:
			_end_turn()

func _dim_marker(i: int) -> void:
	if markers.has(i):
		create_tween().tween_property(markers[i], "modulate", Color(0.6, 0.6, 0.6, 0.55), 0.3)

func _end_turn() -> void:
	_update_hud()
	if turns_left <= 0:
		main.game_over("해가 저물었다.\n통금 순라꾼들에게 붙잡히고 말았다…")
		return
	busy = false
	hint_label.text = "행보 상소를 고르십시오"
	_deal()
