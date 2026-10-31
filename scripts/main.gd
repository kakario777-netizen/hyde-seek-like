extends Control
## 화면 전환과 조선풍 공용 UI (한지·목각 테두리·놋쇠 장석·상소문 카드)

var TITLE_FONT: FontFile = load("res://assets/fonts/SongMyung-Regular.ttf")
var BODY_FONT: FontFile = load("res://assets/fonts/GowunBatang-Bold.ttf")
const StoryScreen := preload("res://scripts/story_screen.gd")
const BoardScreen := preload("res://scripts/board_screen.gd")
const BattleScreen := preload("res://scripts/battle_screen.gd")
const TitleScreen := preload("res://scripts/title_screen.gd")

const INK := Color("231a14")
const INK_SOFT := Color("5a4030")
const RED := Color("9a2c22")
const GOLD := Color("d9b45a")
const LIGHT := Color("f3e6c8")
const STEP_WORD := ["", "한", "두", "세", "네", "다섯"]

# 진행 상태
var hero_name := "연이"
var max_hp := 40
var hp := 40
var coins := 0
var potions := 2
var deck: Array = []
var chapter := 1
var flags := {}
var next_energy := 0   # 다음 전투 첫 차례 기력 보너스
var next_guard := 0    # 다음 전투 시작 막기

var current: Control
var board: Control  # 전투 동안 보드를 숨겨 두었다가 되돌림

func _ready() -> void:
	TITLE_FONT.fallbacks = [BODY_FONT]
	var bg := TextureRect.new()
	bg.texture = ui("hanji_dark")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.modulate = Color(0.45, 0.36, 0.3)
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
		"name": ask_name(Callable())
		"story": play_story(GameData.PROLOGUE.slice(int(args.get("from", "5"))), show_title)
		"end": play_story(GameData.CHAPTER1_END.slice(int(args.get("from", "0"))), show_title)
		"board": start_board()
		"battle":
			start_board()
			start_battle(args.get("enemy", "pojol"), Callable())
			if args.has("auto"):
				var bs = current
				await get_tree().create_timer(3.0).timeout
				for k in 3:
					var kids: Array = bs.card_row.get_children()
					for b in kids:
						if not b.disabled:
							b.pressed.emit(); break
					await get_tree().create_timer(1.0).timeout
				bs._end_my_turn()
		"walk":
			start_board()
			await get_tree().create_timer(2.0).timeout
			var kids: Array = board.card_row.get_children()
			kids[0].pressed.emit()
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
		"talk":
			start_board()
			var t: Dictionary = GameData.TALKS[int(args.get("n", "0"))]
			popup(t["text"], "고맙습니다", Callable(), t["who"], t["pic"])
		"event":
			start_board()
			await get_tree().create_timer(0.5).timeout
			dialog_chain(GameData.STORY2 if args.get("n", "1") == "2" else GameData.STORY1, Callable())
		"over":
			start_board()
			game_over("해가 저물었다.\n\"게 섰거라! 통금 시각에 어딜 쏘다니느냐!\"\n순라꾼에게 붙잡히고 말았다…", "sunra")
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
	ask_name(func():
		max_hp = 40; hp = 40; coins = 0; potions = 2
		chapter = 1; flags = {}; next_energy = 0; next_guard = 0
		deck = make_deck(GameData.START_DECK)
		play_story(GameData.PROLOGUE, start_board))

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
	next_energy = 0; next_guard = 0
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

func game_over(reason: String, pic := "") -> void:
	popup(reason + "\n\n다시 도전하시겠습니까?", "다시 하기", func():
		if board and current != board:
			current.queue_free()
		if board:
			board.queue_free(); board = null
		current = null
		max_hp = 40; coins = 0; potions = 2
		start_board(), "", pic)

# ── 이름 ────────────────────────────────────────────────
func alias() -> String:
	return hero_name.left(1) + "돌이"

func _has_batchim(word: String) -> bool:
	if word.is_empty():
		return false
	var c := word.unicode_at(word.length() - 1)
	return c >= 0xAC00 and c <= 0xD7A3 and (c - 0xAC00) % 28 != 0

## "{name}", "{alias}", "{name|은}" 처럼 조사까지 맞춰 바꿔 준다
func fmt(text: String) -> String:
	const PAIRS := {"은": ["은", "는"], "이": ["이", "가"], "을": ["을", "를"], "과": ["과", "와"], "아": ["아", "야"], "이다": ["이다", "다"]}
	var re := RegEx.new()
	re.compile("\\{(name|alias)(?:\\|([^}]+))?\\}")
	var out := text
	for m in re.search_all(text):
		var word: String = hero_name if m.get_string(1) == "name" else alias()
		var josa := ""
		if m.get_string(2) != "" and PAIRS.has(m.get_string(2)):
			josa = PAIRS[m.get_string(2)][0 if _has_batchim(word) else 1]
		out = out.replace(m.get_string(0), word + josa)
	return out

func ask_name(cb: Callable) -> void:
	var o := _overlay("주인공의 이름")
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	vb.add_child(_note("누명을 쓰고 쫓기게 될 소녀의 이름을 지어 주세요.\n(한두 글자, 최대 네 글자)"))
	var edit := LineEdit.new()
	edit.text = hero_name
	edit.max_length = 4
	edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	edit.custom_minimum_size = Vector2(360, 96)
	edit.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	edit.add_theme_font_override("font", TITLE_FONT)
	edit.add_theme_font_size_override("font_size", 52)
	edit.add_theme_color_override("font_color", INK)
	edit.add_theme_color_override("caret_color", RED)
	var sb := tex_box("button", 34, 18)
	edit.add_theme_stylebox_override("normal", sb)
	edit.add_theme_stylebox_override("focus", sb)
	vb.add_child(edit)
	var hint := _note("")
	vb.add_child(hint)
	var refresh := func(_t := ""):
		var n := edit.text.strip_edges()
		hint.text = "남장한 뒤 이름은 '%s'" % ((n.left(1) if n != "" else "?") + "돌이")
	edit.text_changed.connect(refresh)
	refresh.call()
	var ok := make_button("이 이름으로 시작", 32)
	ok.custom_minimum_size = Vector2(0, 100)
	vb.add_child(ok)
	ok.pressed.connect(func():
		var n := edit.text.strip_edges()
		if n == "":
			n = "연이"
		hero_name = n
		layer.queue_free()
		if cb.is_valid():
			cb.call())

func token_name() -> String:
	return "token_hero" if chapter < 2 else "token_disguise"

## 팝업으로 이어지는 짧은 이야기. line: {who, pic, text, bg, choices:[{text,set}], if, ifnot}
func dialog_chain(lines: Array, cb: Callable, i := 0, bg := "") -> void:
	while i < lines.size():
		var ln: Dictionary = lines[i]
		if ln.has("if") and not flags.has(ln["if"]):
			i += 1; continue
		if ln.has("ifnot") and flags.has(ln["ifnot"]):
			i += 1; continue
		break
	if i >= lines.size():
		if cb.is_valid():
			cb.call()
		return
	var line: Dictionary = lines[i]
	var nbg: String = line.get("bg", bg)
	var next := func(): dialog_chain(lines, cb, i + 1, nbg)
	if line.has("choices"):
		popup_choices(line["text"], line["choices"], func(k: int):
			var st: String = line["choices"][k].get("set", "")
			if st != "":
				flags[st] = true
			next.call(), fmt(line.get("who", "")), line.get("pic", ""), nbg)
	else:
		popup(line["text"], "다음", next, fmt(line.get("who", "")), line.get("pic", ""), nbg)

func popup_choices(text: String, choices: Array, cb: Callable, title := "", pic := "", bg := "") -> void:
	var o := _overlay(title, bg, pic)
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	var l := make_label(fmt(text), 30)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.custom_minimum_size = Vector2(540, 0)
	l.add_theme_constant_override("line_spacing", 8)
	vb.add_child(l)
	for k in choices.size():
		var b := make_button(fmt(choices[k]["text"]), 28)
		b.custom_minimum_size = Vector2(0, 92)
		vb.add_child(b)
		var idx := k
		b.pressed.connect(func():
			layer.queue_free()
			cb.call(idx))

# ── 그림 불러오기 ───────────────────────────────────────
func ui(name: String) -> Texture2D:
	return load("res://assets/ui/%s.png" % name)

func icon(name: String) -> Texture2D:
	return load("res://assets/ui/icons/%s.png" % name)

func illust(name: String) -> Texture2D:
	var p := "res://assets/chars/%s.png" % name
	return load(p) if ResourceLoader.exists(p) else null

const BG_FALLBACK := {}

func backdrop(name: String) -> Texture2D:
	var p := "res://assets/bg/%s.jpg" % name
	if not ResourceLoader.exists(p) and BG_FALLBACK.has(name):
		p = "res://assets/bg/%s.jpg" % BG_FALLBACK[name]
	return load(p) if ResourceLoader.exists(p) else null

func tex_rect(t: Texture2D, sz: Vector2) -> TextureRect:
	var r := TextureRect.new()
	r.texture = t
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.custom_minimum_size = sz
	r.size = sz
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r

# ── 스타일 ──────────────────────────────────────────────
func tex_box(name: String, margin: int, content: int, mod := Color.WHITE) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = ui(name)
	sb.set_texture_margin_all(margin)
	sb.set_content_margin_all(content)
	sb.modulate_color = mod
	return sb

func panel_style() -> StyleBoxTexture:
	var sb := tex_box("panel", 74, 64)
	sb.content_margin_top = 58; sb.content_margin_bottom = 58
	return sb

func bar_style() -> StyleBoxTexture:
	return tex_box("bar", 46, 30)

func plaque_style() -> StyleBoxTexture:
	var sb := tex_box("plaque", 22, 14)
	sb.content_margin_left = 30; sb.content_margin_right = 30
	return sb

func make_label(text: String, size := 28, color := INK, title := false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if title:
		l.add_theme_font_override("font", TITLE_FONT)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func make_button(text: String, size := 30) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_override("font", TITLE_FONT)
	b.add_theme_font_size_override("font_size", size)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(c, INK)
	b.add_theme_color_override("font_disabled_color", Color(INK, 0.45))
	b.add_theme_stylebox_override("normal", tex_box("button", 34, 22))
	b.add_theme_stylebox_override("hover", tex_box("button", 34, 22))
	b.add_theme_stylebox_override("focus", tex_box("button", 34, 22))
	b.add_theme_stylebox_override("pressed", tex_box("button_pressed", 34, 22))
	b.add_theme_stylebox_override("disabled", tex_box("button", 34, 22, Color(1, 1, 1, 0.55)))
	return b

func ink_text(l: Label, outline := 10) -> Label:
	l.add_theme_color_override("font_outline_color", INK)
	l.add_theme_constant_override("outline_size", outline)
	return l

# ── 상소문 카드 ─────────────────────────────────────────
func _sangso_button(paper: String, w: int, h: int) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(w, h)
	for st in ["normal", "hover", "focus"]:
		b.add_theme_stylebox_override(st, tex_box(paper, 0, 0))
	b.add_theme_stylebox_override("pressed", tex_box(paper, 0, 0, Color(0.85, 0.8, 0.72)))
	b.add_theme_stylebox_override("disabled", tex_box(paper, 0, 0, Color(0.62, 0.58, 0.55)))
	return b

func _card_box(b: Button) -> VBoxContainer:
	var vb := VBoxContainer.new()
	vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vb.offset_top = 10; vb.offset_bottom = -12; vb.offset_left = 8; vb.offset_right = -8
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 2)
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(vb)
	return vb

func _center(c: Control) -> CenterContainer:
	var cc := CenterContainer.new()
	cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cc.add_child(c)
	return cc

func card_button(entry: Dictionary, w := 162, h := 270) -> Button:
	var c: Dictionary = GameData.stats(entry["id"], entry["lv"])
	var paper := "sangso" if entry["lv"] == 1 else ("sangso_gold" if entry["lv"] == 2 else "sangso_red")
	var b := _sangso_button(paper, w, h)
	var vb := _card_box(b)
	var s := h / 270.0
	var cost := make_label("기력 " + "●".repeat(c["cost"]), int(18 * s), RED)
	cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(cost)
	vb.add_child(_center(tex_rect(icon(c["icon_ui"]), Vector2(84, 84) * s)))
	var nm := make_label(c["name"], int(30 * s), INK, true)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(nm)
	if entry["lv"] >= 2:
		var st := make_label("★".repeat(entry["lv"]), int(18 * s), RED)
		st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(st)
	var ds := make_label(c["desc"], int(19 * s), INK_SOFT)
	ds.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(ds)
	return b

func step_card(v: int, w := 196, h := 270) -> Button:
	var b := _sangso_button("sangso", w, h)
	var vb := _card_box(b)
	var t := make_label("행 보", 18, RED)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(t)
	vb.add_child(_center(tex_rect(icon("step"), Vector2(92, 92))))
	var n := make_label("%s 걸음" % STEP_WORD[v], 38, INK, true)
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(n)
	return b

# ── 겹창 ────────────────────────────────────────────────
## bg: 뒤에 깔 배경 그림 이름, pic: 위쪽에 세울 인물 일러스트 이름
func _overlay(title: String, bg := "", pic := "") -> Array:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	var bt: Texture2D = backdrop(bg) if bg != "" else null
	if bt:
		var b := TextureRect.new()
		b.texture = bt
		b.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		b.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		b.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		layer.add_child(b)
	var dim := ColorRect.new()
	dim.color = Color(0.08, 0.05, 0.03, 0.3 if bt else 0.62)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)
	var pt: Texture2D = illust(pic) if pic != "" else null
	if pt:
		var r := TextureRect.new()
		r.texture = pt
		r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		r.anchor_right = 1.0; r.anchor_bottom = 0.66
		r.offset_top = 40; r.offset_left = 30; r.offset_right = -30
		r.modulate.a = 0.0
		layer.add_child(r)
		create_tween().tween_property(r, "modulate:a", 1.0, 0.4)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if pt:
		center.anchor_top = 0.5
		center.offset_bottom = -20
	layer.add_child(center)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", panel_style())
	center.add_child(panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 18)
	panel.add_child(vb)
	if title != "":
		var t := make_label(title, 42, RED, true)
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(t)
	panel.modulate.a = 0.0
	panel.pivot_offset = Vector2(300, 300)
	var tw := create_tween()
	tw.tween_property(panel, "modulate:a", 1.0, 0.3)
	return [layer, vb]

func _note(text: String, color := INK_SOFT) -> Label:
	var l := make_label(text, 26, color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(540, 0)
	return l

func popup(text: String, button_text := "확인", cb := Callable(), title := "", pic := "", bg := "") -> void:
	var o := _overlay(title, bg, pic)
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	var l := make_label(fmt(text), 30)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.custom_minimum_size = Vector2(540, 0)
	l.add_theme_constant_override("line_spacing", 8)
	vb.add_child(l)
	var b := make_button(button_text)
	b.custom_minimum_size = Vector2(0, 96)
	vb.add_child(b)
	b.pressed.connect(func():
		layer.queue_free()
		if cb.is_valid():
			cb.call())

# ── 전투 보상: 상소 셋 중 하나 ───────────────────────────
func choose_reward(cb: Callable) -> void:
	var o := _overlay("전리품")
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	vb.add_child(_note("보따리에 넣을 상소를 하나 고르십시오"))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	vb.add_child(row)
	var done := func():
		layer.queue_free()
		if cb.is_valid():
			cb.call()
	for i in 3:
		var e := {"id": GameData.REWARD_POOL.pick_random(), "lv": 1}
		var b := card_button(e, 172, 286)
		row.add_child(b)
		b.pressed.connect(func():
			deck.append(e)
			done.call())
	var skip := make_button("그냥 지나간다", 28)
	skip.custom_minimum_size = Vector2(0, 88)
	vb.add_child(skip)
	skip.pressed.connect(done)

# ── 보따리: 같은 상소 두 장을 합쳐 강화 ─────────────────
func show_bag(cb := Callable()) -> void:
	var o := _overlay("보따리")
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	var info := _note("")
	vb.add_child(info)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(560, 860)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vb.add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(grid)
	var close := make_button("닫기", 30)
	close.custom_minimum_size = Vector2(0, 90)
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
		info.text = "상소 %d장 · 같은 상소(같은 ★) 두 장을 차례로 누르면 합쳐집니다" % deck.size()
		if state["msg"] != "":
			info.text = state["msg"]
		for i in deck.size():
			var b := card_button(deck[i], 132, 220)
			if i == state["sel"]:
				b.modulate = Color(1.0, 0.82, 0.55)
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
			state["msg"] = "합칠 같은 상소를 하나 더 누르십시오"
		return
	var a: Dictionary = deck[sel]
	var b: Dictionary = deck[i]
	if a["id"] != b["id"] or a["lv"] != b["lv"]:
		state["sel"] = i
		state["msg"] = "같은 이름, 같은 ★ 상소끼리만 합칠 수 있습니다"
		return
	if a["lv"] >= GameData.MAX_LV:
		state["sel"] = -1
		state["msg"] = "이미 가장 강한 상소입니다 (★3)"
		return
	if deck.size() <= GameData.MIN_DECK:
		state["sel"] = -1
		state["msg"] = "보따리에 상소가 %d장은 남아 있어야 합니다" % GameData.MIN_DECK
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
	var o := _overlay("운종가 장터", "jangteo")
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	var money := _note("", RED)
	vb.add_child(money)
	var refresh := func():
		money.text = "가진 엽전 %d냥 · 약병 %d개" % [coins, potions]
	refresh.call()
	vb.add_child(_note("상소 %d냥 · 약병 %d냥" % [CARD_PRICE, POTION_PRICE]))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	vb.add_child(row)
	for i in 3:
		var e := {"id": GameData.REWARD_POOL.pick_random(), "lv": 1}
		var b := card_button(e, 172, 286)
		row.add_child(b)
		b.pressed.connect(func():
			if coins < CARD_PRICE:
				money.text = "엽전이 모자랍니다"
				return
			coins -= CARD_PRICE
			deck.append(e)
			b.disabled = true
			refresh.call())
	var pot := make_button("약병 사기 (%d냥)" % POTION_PRICE, 28)
	pot.custom_minimum_size = Vector2(0, 86)
	vb.add_child(pot)
	pot.pressed.connect(func():
		if coins < POTION_PRICE:
			money.text = "엽전이 모자랍니다"
			return
		coins -= POTION_PRICE
		potions += 1
		refresh.call())
	var bag := make_button("보따리 열기", 28)
	bag.custom_minimum_size = Vector2(0, 86)
	vb.add_child(bag)
	bag.pressed.connect(func(): show_bag())
	var leave := make_button("장터를 떠난다", 28)
	leave.custom_minimum_size = Vector2(0, 86)
	vb.add_child(leave)
	leave.pressed.connect(func():
		layer.queue_free()
		if cb.is_valid():
			cb.call())
