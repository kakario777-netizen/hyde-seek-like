extends Control
## 화면 전환과 공용 UI 도우미

const SERIF := preload("res://assets/fonts/NotoSerifKR-Bold.otf")
const StoryScreen := preload("res://scripts/story_screen.gd")
const BoardScreen := preload("res://scripts/board_screen.gd")
const BattleScreen := preload("res://scripts/battle_screen.gd")
const TitleScreen := preload("res://scripts/title_screen.gd")

const INK := Color("2a1d1a")
const PAPER := Color("efe3c8")
const PAPER_DARK := Color("d9c9a6")
const RED := Color("b8352f")

# 진행 상태
var max_hp := 40
var hp := 40
var coins := 0
var potions := 2
var deck: Array = []

var current: Control
var board: Control  # 전투 동안 보드를 숨겨 두었다가 되돌림

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color("1b1418")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	show_title()
	_debug_capture()

# 개발용: godot ... -- capture=board out=파일.png  → 해당 화면을 찍고 종료
func _debug_capture() -> void:
	var args := {}
	for a in OS.get_cmdline_user_args():
		var kv: PackedStringArray = a.split("=")
		if kv.size() == 2:
			args[kv[0]] = kv[1]
	if not args.has("capture"):
		return
	deck = make_deck(GameData.START_DECK)
	match args["capture"]:
		"story": play_story(GameData.PROLOGUE.slice(4), show_title)
		"board": start_board()
		"battle":
			start_board()
			start_battle("pojol", Callable())
		"bag":
			deck.append({"id": "jumeok", "lv": 2})
			start_board()
			show_bag()
		"shop":
			coins = 9
			start_board()
			open_shop(Callable())
		"reward":
			start_board()
			choose_reward(Callable())
	await get_tree().create_timer(float(args.get("wait", "1.6"))).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(args.get("out", "user://shot.png"))
	get_tree().quit()

# ── 화면 전환 ───────────────────────────────────────────
func _swap(screen: Control, keep_old := false) -> void:
	if current and not keep_old:
		current.queue_free()
	elif current:
		current.hide()
		current.process_mode = Node.PROCESS_MODE_DISABLED
	current = screen
	screen.set("main", self)
	add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func show_title() -> void:
	if board:
		board.queue_free(); board = null
	_swap(TitleScreen.new())

func new_game() -> void:
	max_hp = 40; hp = 40; coins = 0; potions = 2
	deck = make_deck(GameData.START_DECK)
	play_story(GameData.PROLOGUE, start_board)

func make_deck(ids: Array) -> Array:
	var d := []
	for id in ids:
		d.append({"id": id, "lv": 1})
	return d

func play_story(lines: Array, on_done: Callable) -> void:
	var s := StoryScreen.new()
	s.lines = lines
	s.on_done = on_done
	_swap(s)

func start_board() -> void:
	hp = max_hp
	board = BoardScreen.new()
	_swap(board)

func start_battle(enemy_id: String, on_win: Callable) -> void:
	var b := BattleScreen.new()
	b.enemy_id = enemy_id
	b.on_win = on_win
	_swap(b, true)

func end_battle(battle: Control) -> void:
	battle.queue_free()
	current = board
	board.process_mode = Node.PROCESS_MODE_INHERIT
	board.show()

func chapter_clear() -> void:
	if board:
		board.queue_free(); board = null
	current = null
	play_story(GameData.CHAPTER1_END, show_title)

func game_over(reason: String) -> void:
	popup(reason + "\n\n다시 도전할까요?", "다시 하기", func():
		if board and current != board:
			current.queue_free()
		if board:
			board.queue_free(); board = null
		current = null
		start_board())

# ── 공용 UI ─────────────────────────────────────────────
func paper_box(bg := PAPER, border := INK, width := 4) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(width)
	sb.set_content_margin_all(18)
	sb.shadow_color = Color(0, 0, 0, 0.35)
	sb.shadow_offset = Vector2(0, 6)
	return sb

func make_label(text: String, size := 26, color := INK, serif := false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if serif:
		l.add_theme_font_override("font", SERIF)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func make_button(text: String, size := 28) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", size)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(c, INK)
	b.add_theme_color_override("font_disabled_color", Color(INK, 0.4))
	b.add_theme_stylebox_override("normal", paper_box(PAPER))
	b.add_theme_stylebox_override("hover", paper_box(PAPER))
	b.add_theme_stylebox_override("pressed", paper_box(PAPER_DARK))
	b.add_theme_stylebox_override("focus", paper_box(PAPER))
	b.add_theme_stylebox_override("disabled", paper_box(Color(PAPER, 0.5), Color(INK, 0.5)))
	return b

func tex(name: String) -> Texture2D:
	return load("res://assets/art/%s.png" % name)

func pixel_rect(name: String, scale_px: int) -> TextureRect:
	var t := TextureRect.new()
	t.texture = tex(name)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_SCALE
	t.custom_minimum_size = t.texture.get_size() * scale_px
	t.size = t.custom_minimum_size
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t

func popup(text: String, button_text := "확인", cb := Callable()) -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", paper_box())
	center.add_child(panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 24)
	panel.add_child(vb)
	var l := make_label(text, 28)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.custom_minimum_size = Vector2(560, 0)
	vb.add_child(l)
	var b := make_button(button_text)
	b.custom_minimum_size = Vector2(0, 84)
	vb.add_child(b)
	b.pressed.connect(func():
		layer.queue_free()
		if cb.is_valid():
			cb.call())

# ── 카드 그림 ───────────────────────────────────────────
func card_button(entry: Dictionary, w := 162, h := 270) -> Button:
	var c: Dictionary = GameData.stats(entry["id"], entry["lv"])
	var b := make_button("", 22)
	b.custom_minimum_size = Vector2(w, h)
	if entry["lv"] >= 2:
		var gold := paper_box(Color("f6e6b8"), Color("b07a1a") if entry["lv"] == 2 else RED, 5)
		b.add_theme_stylebox_override("normal", gold)
		b.add_theme_stylebox_override("hover", gold)
		b.add_theme_stylebox_override("focus", gold)
	var vb := VBoxContainer.new()
	vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vb.offset_top = 8; vb.offset_bottom = -8
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 4)
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(vb)
	var small := h < 250
	var cost := make_label("●".repeat(c["cost"]), 20, Color("c08a1a"))
	cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(cost)
	var ic := CenterContainer.new()
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ic.add_child(pixel_rect(c["icon"], 4 if small else 5))
	vb.add_child(ic)
	var nm := make_label(c["name"], 22 if small else 26, INK, true)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(nm)
	if entry["lv"] >= 2:
		var st := make_label("★".repeat(entry["lv"]), 20, RED)
		st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(st)
	var ds := make_label(c["desc"], 18 if small else 20, Color("5a4030"))
	ds.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(ds)
	return b

func _overlay(title: String) -> Array:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", paper_box())
	center.add_child(panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 18)
	panel.add_child(vb)
	var t := make_label(title, 34, INK, true)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(t)
	return [layer, vb]

func _note(text: String, color := Color("5a4030")) -> Label:
	var l := make_label(text, 22, color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(600, 0)
	return l

# ── 전투 보상: 카드 셋 중 하나 ───────────────────────────
func choose_reward(cb: Callable) -> void:
	var o := _overlay("전리품 고르기")
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	vb.add_child(_note("보따리에 넣을 카드를 하나 고르세요"))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	vb.add_child(row)
	var done := func():
		layer.queue_free()
		if cb.is_valid():
			cb.call()
	for i in 3:
		var e := {"id": GameData.REWARD_POOL.pick_random(), "lv": 1}
		var b := card_button(e, 190, 290)
		row.add_child(b)
		b.pressed.connect(func():
			deck.append(e)
			done.call())
	var skip := make_button("그냥 지나간다", 26)
	skip.custom_minimum_size = Vector2(0, 76)
	vb.add_child(skip)
	skip.pressed.connect(done)

# ── 보따리: 같은 카드 두 장을 합쳐 강화 ─────────────────
func show_bag(cb := Callable()) -> void:
	var o := _overlay("보따리")
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	var info := _note("")
	vb.add_child(info)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(640, 880)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vb.add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(grid)
	var close := make_button("닫기", 28)
	close.custom_minimum_size = Vector2(0, 80)
	vb.add_child(close)
	close.pressed.connect(func():
		layer.queue_free()
		if cb.is_valid():
			cb.call())
	var state := {"sel": -1, "msg": ""}
	var rebuild := func(self_ref: Callable) -> void:
		for ch in grid.get_children():
			ch.queue_free()
		deck.sort_custom(func(a, b): return a["id"] < b["id"] or (a["id"] == b["id"] and a["lv"] > b["lv"]))
		info.text = "카드 %d장 · 같은 카드(같은 ★) 두 장을 차례로 누르면 합쳐져요" % deck.size()
		if state["msg"] != "":
			info.text = state["msg"]
		for i in deck.size():
			var b := card_button(deck[i], 150, 236)
			if i == state["sel"]:
				b.modulate = Color(1.0, 0.85, 0.5)
				b.scale = Vector2(1.04, 1.04)
			grid.add_child(b)
			var idx := i
			b.pressed.connect(func():
				_bag_tap(idx, state)
				self_ref.call(self_ref))
	rebuild.call(rebuild)

func _bag_tap(i: int, state: Dictionary) -> void:
	var sel: int = state["sel"]
	state["msg"] = ""
	if sel == -1 or sel == i:
		state["sel"] = -1 if sel == i else i
		if state["sel"] != -1:
			state["msg"] = "합칠 같은 카드를 하나 더 누르세요"
		return
	var a: Dictionary = deck[sel]
	var b: Dictionary = deck[i]
	if a["id"] != b["id"] or a["lv"] != b["lv"]:
		state["sel"] = i
		state["msg"] = "같은 이름, 같은 ★ 카드끼리만 합칠 수 있어요"
		return
	if a["lv"] >= GameData.MAX_LV:
		state["sel"] = -1
		state["msg"] = "이미 가장 강한 카드예요 (★3)"
		return
	if deck.size() <= GameData.MIN_DECK:
		state["sel"] = -1
		state["msg"] = "보따리에 카드가 %d장은 남아 있어야 해요" % GameData.MIN_DECK
		return
	var nlv: int = a["lv"] + 1
	var id: String = a["id"]
	for k in [max(sel, i), min(sel, i)]:
		deck.remove_at(k)
	deck.append({"id": id, "lv": nlv})
	state["sel"] = -1
	state["msg"] = "%s %s 완성!" % [GameData.CARDS[id]["name"], "★".repeat(nlv)]

# ── 운종가 장터 ─────────────────────────────────────────
const CARD_PRICE := 4
const POTION_PRICE := 3

func open_shop(cb: Callable) -> void:
	var o := _overlay("운종가 장터")
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	var money := _note("", main_coin_color())
	vb.add_child(money)
	var refresh := func():
		money.text = "가진 엽전 %d냥 · 약병 %d개" % [coins, potions]
	refresh.call()
	vb.add_child(_note("카드 %d냥 · 약병 %d냥" % [CARD_PRICE, POTION_PRICE]))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	vb.add_child(row)
	for i in 3:
		var e := {"id": GameData.REWARD_POOL.pick_random(), "lv": 1}
		var b := card_button(e, 190, 290)
		row.add_child(b)
		b.pressed.connect(func():
			if coins < CARD_PRICE:
				money.text = "엽전이 모자라요"
				return
			coins -= CARD_PRICE
			deck.append(e)
			b.disabled = true
			b.modulate = Color(1, 1, 1, 0.35)
			refresh.call())
	var pot := make_button("약병 사기 (%d냥)" % POTION_PRICE, 26)
	pot.custom_minimum_size = Vector2(0, 76)
	vb.add_child(pot)
	pot.pressed.connect(func():
		if coins < POTION_PRICE:
			money.text = "엽전이 모자라요"
			return
		coins -= POTION_PRICE
		potions += 1
		refresh.call())
	var bag := make_button("보따리 열기", 26)
	bag.custom_minimum_size = Vector2(0, 76)
	vb.add_child(bag)
	bag.pressed.connect(func(): show_bag())
	var leave := make_button("장터를 떠난다", 26)
	leave.custom_minimum_size = Vector2(0, 76)
	vb.add_child(leave)
	leave.pressed.connect(func():
		layer.queue_free()
		if cb.is_valid():
			cb.call())

func main_coin_color() -> Color:
	return Color("8a5a10")
