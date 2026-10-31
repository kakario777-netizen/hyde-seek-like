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
	deck = GameData.START_DECK.duplicate()
	match args["capture"]:
		"story": play_story(GameData.PROLOGUE.slice(4), show_title)
		"board": start_board()
		"battle":
			start_board()
			start_battle("pojol", Callable())
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
	deck = GameData.START_DECK.duplicate()
	play_story(GameData.PROLOGUE, start_board)

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
