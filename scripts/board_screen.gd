extends Control
## 한양 지도 보드: 걸음 카드를 골라 칸을 이동

var main

const MAP_SCALE := 4
const TURN_LIMIT := 14
const STEP_VALUES := [1, 2, 2, 3, 3, 4]

var nodes: Array = []
var pos := 0
var turns_left := TURN_LIMIT
var hand: Array = []
var busy := false
var cleared := {}   # 처리 끝난 칸 번호
var talk_idx := 0

var world: Control
var token: TextureRect
var markers := {}
var hud_label: Label
var hp_label: Label
var hint_label: Label
var card_row: HBoxContainer

func _ready() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/board1.json"))
	nodes = data["nodes"]

	var ground := ColorRect.new()
	ground.color = Color("a88f68")
	ground.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ground.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ground)

	world = Control.new()
	world.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(world)
	var map: TextureRect = main.pixel_rect("board_map", MAP_SCALE)
	world.add_child(map)
	world.size = map.size

	var dots := Control.new()
	dots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dots.size = map.size
	world.add_child(dots)
	dots.draw.connect(func(): _draw_nodes(dots))

	for i in nodes.size():
		var n: Dictionary = nodes[i]
		var icon := ""
		var sc := MAP_SCALE
		match n["type"]:
			"talk": icon = "node_talk"
			"item": icon = "node_item"
			"goal": icon = "node_goal"; sc = 5
			"shop": icon = "node_shop"; sc = 5
			"pojol": icon = "token_pojol"
			"walpae": icon = "token_walpae"
		if icon == "":
			continue
		var m: TextureRect = main.pixel_rect(icon, sc)
		var p := _node_px(i)
		if n["type"] in ["pojol", "walpae"]:
			m.position = p - Vector2(m.size.x / 2, m.size.y - 8)
		else:
			m.position = p - Vector2(m.size.x / 2, m.size.y + 14)
		world.add_child(m)
		markers[i] = m

	token = main.pixel_rect("token_yeoni", MAP_SCALE)
	world.add_child(token)
	_place_token()

	_build_hud()
	_build_tray()
	resized.connect(_layout)
	_layout()
	_deal()

func _node_px(i: int) -> Vector2:
	return Vector2(nodes[i]["x"], nodes[i]["y"]) * MAP_SCALE

func _draw_nodes(c: Control) -> void:
	for i in nodes.size():
		var p := _node_px(i)
		var t: String = nodes[i]["type"]
		var col := Color("efe3c8")
		if t in ["pojol", "walpae"] and not cleared.has(i):
			col = Color("c0392b")
		elif t == "start" or t == "goal" or t == "shop":
			col = Color("d4a84a")
		c.draw_rect(Rect2(p - Vector2(14, 10), Vector2(28, 20)), Color("5a4a36"))
		c.draw_rect(Rect2(p - Vector2(10, 7), Vector2(20, 14)), col)

func _place_token() -> void:
	token.position = _node_px(pos) - Vector2(token.size.x / 2, token.size.y - 6)

func _layout() -> void:
	world.position = ((size - world.size) / 2.0).floor()

# ── HUD ─────────────────────────────────────────────────
func _build_hud() -> void:
	var top := PanelContainer.new()
	var sb: StyleBoxFlat = main.paper_box(Color("2a1d1a", 0.88), Color("d4a84a"), 3)
	sb.shadow_size = 0
	top.add_theme_stylebox_override("panel", sb)
	top.anchor_right = 1.0
	top.offset_left = 12; top.offset_right = -12; top.offset_top = 12
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top)
	var vb := VBoxContainer.new()
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(vb)
	var head := HBoxContainer.new()
	vb.add_child(head)
	var title: Label = main.make_label("제1장  누명  ·  종로에서 남산까지", 26, Color("e8d6a8"), true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var bag: Button = main.make_button("보따리", 24)
	bag.custom_minimum_size = Vector2(130, 60)
	head.add_child(bag)
	bag.pressed.connect(func():
		if not busy:
			main.show_bag())
	hud_label = main.make_label("", 26, Color("f4ead2"))
	vb.add_child(hud_label)
	hp_label = main.make_label("", 26, Color("f4ead2"))
	vb.add_child(hp_label)
	_update_hud()

func _update_hud() -> void:
	var sun := ""
	for i in TURN_LIMIT:
		sun += "●" if i < turns_left else "○"
	hud_label.text = "남은 시각  %s" % sun
	hp_label.text = "체력 %d/%d    엽전 %d    약병 %d" % [main.hp, main.max_hp, main.coins, main.potions]

func _build_tray() -> void:
	var tray := PanelContainer.new()
	var sb: StyleBoxFlat = main.paper_box(Color("2a1d1a", 0.9), Color("d4a84a"), 3)
	sb.shadow_size = 0
	tray.add_theme_stylebox_override("panel", sb)
	tray.anchor_top = 1.0; tray.anchor_bottom = 1.0; tray.anchor_right = 1.0
	tray.offset_left = 12; tray.offset_right = -12
	tray.offset_top = -340; tray.offset_bottom = -12
	add_child(tray)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	tray.add_child(vb)
	hint_label = main.make_label("걸음 카드를 골라 주세요", 26, Color("e8d6a8"))
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(hint_label)
	card_row = HBoxContainer.new()
	card_row.alignment = BoxContainer.ALIGNMENT_CENTER
	card_row.add_theme_constant_override("separation", 20)
	card_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(card_row)

func _deal() -> void:
	hand.clear()
	for c in card_row.get_children():
		c.queue_free()
	for i in 3:
		var v: int = STEP_VALUES.pick_random()
		hand.append(v)
		var b: Button = main.make_button("", 26)
		b.custom_minimum_size = Vector2(196, 250)
		var inner := VBoxContainer.new()
		inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		inner.alignment = BoxContainer.ALIGNMENT_CENTER
		inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(inner)
		var ic := CenterContainer.new()
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ic.add_child(main.pixel_rect("card_step", 6))
		inner.add_child(ic)
		var num: Label = main.make_label("%d 걸음" % v, 34, main.INK, true)
		num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		inner.add_child(num)
		card_row.add_child(b)
		b.pressed.connect(func(): _play(v))

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
		var tw := create_tween()
		var target := _node_px(pos) - Vector2(token.size.x / 2, token.size.y - 6)
		tw.tween_property(token, "position", target - Vector2(0, 24), 0.12)
		tw.tween_property(token, "position", target, 0.12)
		await tw.finished
		var t: String = nodes[pos]["type"]
		if t in ["pojol", "walpae"] and not cleared.has(pos):
			break   # 적이 길을 막으면 멈춘다
	_resolve()

func _resolve() -> void:
	var t: String = nodes[pos]["type"]
	if cleared.has(pos):
		t = "empty"
	match t:
		"talk":
			cleared[pos] = true
			_hide_marker(pos)
			var talk: Dictionary = GameData.TALKS[talk_idx % GameData.TALKS.size()]
			talk_idx += 1
			var extra := ""
			if talk.has("coin"):
				main.coins += talk["coin"]; extra += "\n\n(엽전 +%d)" % talk["coin"]
			if talk.has("potion"):
				main.potions += talk["potion"]; extra += "\n\n(약병 +%d)" % talk["potion"]
			main.popup("【%s】\n%s%s" % [talk["who"], talk["text"], extra], "고맙습니다", _end_turn)
		"item":
			cleared[pos] = true
			_hide_marker(pos)
			main.potions += 1
			main.popup("길가에서 약초 주머니를 주웠다!\n\n(약병 +1)", "챙긴다", _end_turn)
		"pojol", "walpae":
			var e: Dictionary = GameData.ENEMIES[t]
			var line := "포졸이 연돌이를 수상하게 노려본다!\n\"거기 너, 잠깐 서 봐라!\"" if t == "pojol" else "왈패가 길을 턱 막아섰다!\n\"꼬마야, 가진 거 다 내놔라.\""
			var idx := pos
			main.popup("%s\n\n【%s】" % [line, e["name"]], "맞서 싸운다", func():
				main.start_battle(t, func():
					cleared[idx] = true
					_hide_marker(idx)
					_end_turn()))
		"shop":
			main.popup("운종가 장터에 들어섰다.\n엽전으로 카드와 약병을 살 수 있다.", "둘러본다", func():
				main.open_shop(_end_turn))
		"goal":
			main.popup("남산 아래, 허 의원의 별채에 도착했다!", "들어간다", main.chapter_clear)
		_:
			_end_turn()

func _hide_marker(i: int) -> void:
	if markers.has(i):
		var tw := create_tween()
		tw.tween_property(markers[i], "modulate:a", 0.0, 0.3)
	world.get_child(1).queue_redraw()

func _end_turn() -> void:
	_update_hud()
	if turns_left <= 0:
		main.game_over("해가 저물었다.\n통금 순라꾼들에게 붙잡히고 말았다…")
		return
	busy = false
	hint_label.text = "걸음 카드를 골라 주세요"
	_deal()
