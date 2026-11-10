extends Control
## 화면 전환과 조선풍 공용 UI (한지·목각 테두리·놋쇠 장석·상소문 카드)

var TITLE_FONT: FontFile = load("res://assets/fonts/SongMyung-Regular.ttf")
var BODY_FONT: FontFile = load("res://assets/fonts/GowunBatang-Bold.ttf")
var HANJA_FONT: FontFile = load("res://assets/fonts/Hanja-Subset.otf")
const StoryScreen := preload("res://scripts/story_screen.gd")
const BoardScreen := preload("res://scripts/board_screen.gd")
const StageScreen := preload("res://scripts/stage_screen.gd")
const BattleScreen := preload("res://scripts/battle_screen.gd")
const TitleScreen := preload("res://scripts/title_screen.gd")
const AudioMgr := preload("res://scripts/audio.gd")

const INK := Color("231a14")
const INK_SOFT := Color("5a4030")
const GOAL_BROWN := Color("6b3a1e")
const RED := Color("9a2c22")
const GOLD := Color("d9b45a")
const LIGHT := Color("f3e6c8")
const STEP_WORD := ["", "한", "두", "세", "네", "다섯", "여섯"]

# 진행 상태
var hero_name := "연이"
var max_hp := 50
var hp := 50
var coins := 0
var potions := 2        # 진한 탕약(3단계, 체력 +40)
var potions_small := 0  # 묽은 탕약(2단계, 체력 +20)
var herbs := 0          # 약초 주머니 (맵에서 주운 약초가 계속 쌓임)
var deck: Array = []
var chapter := 1
var stage_idx := 0
var flags := {}
var next_energy := 0   # 다음 전투 첫 차례 기력 보너스
var next_guard := 0    # 다음 전투 시작 막기

var current: Control
var board: Control  # 전투 동안 보드를 숨겨 두었다가 되돌림

var audio: Node

func _ready() -> void:
	get_tree().create_timer(3.0).timeout.connect(func(): load("res://scripts/boot.gd").mark_ok())
	BODY_FONT.fallbacks = [HANJA_FONT]
	TITLE_FONT.fallbacks = [BODY_FONT, HANJA_FONT]
	audio = AudioMgr.new()
	add_child(audio)
	load_settings()
	var bg := TextureRect.new()
	bg.texture = ui("hanji_dark")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.modulate = Color(0.45, 0.36, 0.3)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_setup_autosave()
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
		"settings":
			font_idx = int(args.get("font", "0")); apply_font()
			open_settings()
		"story": play_story(GameData.PROLOGUE.slice(int(args.get("from", "5"))), show_title)
		"end": play_story(GameData.CHAPTER1_END.slice(int(args.get("from", "0"))), show_title)
		"board":
			chapter = int(args.get("ch", "1"))
			stage_idx = int(args.get("st", "0"))
			start_board()
		"flow":
			# 자동으로 버튼·대사를 넘기며 흐름이 끊기지 않는지 확인
			chapter = int(args.get("ch", "1"))
			stage_idx = int(args.get("st", "0"))
			start_board()
			await get_tree().create_timer(1.5).timeout
			if args.has("clear"):
				board._stage_clear()
			if args.has("chclear"):
				chapter_clear()
			for k in int(args.get("steps", "40")):
				await get_tree().create_timer(0.5).timeout
				var clicked := false
				for l in get_tree().root.find_children("*", "CanvasLayer", true, false):
					for b in l.find_children("*", "Button", true, false):
						if b.is_visible_in_tree() and not b.disabled:
							b.pressed.emit(); clicked = true; break
					if clicked: break
				if not clicked and current and current.has_method("_advance"):
					current.typing = false
					if current.waiting_choice:
						for b in current.choice_box.get_children():
							b.pressed.emit(); break
					else:
						current._advance()
			print("FLOW chapter=", chapter, " stage=", stage_idx, " phase=", phase, " screen=", current.get_script().resource_path.get_file() if current else "none")
		"stagewalk":
			chapter = int(args.get("ch", "1"))
			stage_idx = int(args.get("st", "0"))
			start_board()
			await get_tree().create_timer(1.0).timeout
			if is_instance_valid(get_tree().root.find_child("Panel", true, false)):
				pass
			await get_tree().create_timer(1.2).timeout
			for l in get_tree().root.find_children("*", "CanvasLayer", true, false):
				l.queue_free()
			board.busy = false
			if args.has("fork"):
				for i in board.tiles.size():
					if board.tiles[i]["next"].size() > 1:
						board.pos = i; board.token.position = board.tile_center(i); break
			board._deal()
			if args.has("brew"):
				herbs = 6; coins = 12
				show_brew(board._update_hud)
			await get_tree().create_timer(0.8).timeout
			if not args.has("still"):
				board.card_row.get_child(0).pressed.emit()
		"voyage":
			chapter = 7; stage_idx = 0
			start_board()
			await get_tree().create_timer(1.5).timeout
			for l in get_tree().root.find_children("*", "CanvasLayer", true, false):
				l.queue_free()
			var vi := -1
			for i in board.nodes.size():
				if board.nodes[i].get("type", "") == "voyage":
					vi += 1
					if vi == int(args.get("v", "0")):
						start_voyage(board.nodes[i]["stage"], func(): print("VOYAGE_BACK"))
						break
			await get_tree().create_timer(1.8).timeout
			for l in get_tree().root.find_children("*", "CanvasLayer", true, false):
				l.queue_free()
			board.busy = false
			board._deal()
			if args.has("finish"):
				board._stage_clear()
				await get_tree().create_timer(0.5).timeout
				for k in 20:
					for cl in get_tree().root.find_children("*", "CanvasLayer", true, false):
						var bs: Array = cl.find_children("*", "Button", true, false)
						if bs.size() > 0:
							bs[0].pressed.emit(); break
					await get_tree().create_timer(0.25).timeout
				print("BOARD_IS_WORLD ", board.get_script().resource_path, " cleared=", board.cleared.keys())
		"cards":
			var bg := ColorRect.new(); bg.color = Color("3a2c22"); bg.set_anchors_preset(Control.PRESET_FULL_RECT); add_child(bg)
			var hb := HBoxContainer.new(); hb.position = Vector2(20, 200); hb.add_theme_constant_override("separation", 14); add_child(hb)
			for lv in [1, 2, 3, 4]:
				hb.add_child(card_button({"id": "jumeok", "lv": lv}))
			var hb2 := HBoxContainer.new(); hb2.position = Vector2(20, 520); hb2.add_theme_constant_override("separation", 14); add_child(hb2)
			for lv in [1, 2, 3, 4]:
				hb2.add_child(card_button({"id": "pum", "lv": lv}))
		"chstory":
			chapter = int(args.get("ch", "2"))
			play_story(StoryData.lines(args.get("key", "CH2_INTRO")).slice(int(args.get("from", "0"))), show_title)
		"chpop":
			chapter = int(args.get("ch", "2"))
			start_board()
			await get_tree().create_timer(0.6).timeout
			dialog_chain(StoryData.lines(args.get("key", "C2_DOGYEOL")).slice(int(args.get("from", "0"))), Callable())
		"battle":
			start_board()
			chapter = int(args.get("ch", "1"))
			stage_idx = int(args.get("st", "0"))
			start_battle(args.get("enemy", "pojol"), Callable(), {"ally": args.get("ally", ""), "lose_ok": args.has("lose")})
			if args.has("clean"):
				await get_tree().create_timer(0.5).timeout
				for l in get_tree().root.find_children("*", "CanvasLayer", true, false):
					l.queue_free()
			if args.has("sp"):
				await get_tree().create_timer(0.6).timeout
				current.e_turn_no = 2
				current._pick_intent()
				current._refresh()
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
		"menu":
			start_board()
			await get_tree().create_timer(1.0).timeout
			save_game("1")
			open_slots("load")
		"loadtest":
			coins = 7; hero_name = "수정"; alias_name = "막동"
			start_board()
			await get_tree().create_timer(1.5).timeout
			board.pos = 12; board.days_left = 20
			save_game("2")
			hero_name = "x"; coins = 0
			load_game("2")
			await get_tree().create_timer(1.5).timeout
			print("LOADTEST ", hero_name, " ", alias_name, " ", coins, " pos=", board.pos, " days=", board.days_left)
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
		max_hp = 50; hp = 50; coins = 0; potions = 2; potions_small = 0; herbs = 0
		chapter = 1; stage_idx = 0; flags = {"hp_plus10": true}; next_energy = 0; next_guard = 0
		deck = make_deck(GameData.START_DECK)
		phase = "prologue"
		play_story(chapter_lines("intro"), start_board))

func ch_cfg() -> Dictionary:
	return StoryData.CHAPTERS.get(chapter, StoryData.CHAPTERS[1])

func chapter_lines(key: String) -> Array:
	return StoryData.lines(ch_cfg().get(key, ""))

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
	board = BoardScreen.new() if ch_cfg().get("world", false) else StageScreen.new()
	phase = "board"
	_swap(board)
	autosave.call_deferred("자동 저장")

## opts: {"lose_ok": 져도 이야기 진행, "ally": 동료 id}
## 지금 함께 다니는 동료 (전투 도움 대신 대화로 함께한다)
func companion() -> String:
	if not sub_stage.is_empty():
		return ""
	var st: Array = ch_cfg().get("stages", [])
	if stage_idx < st.size() and st[stage_idx].has("ally"):
		return st[stage_idx]["ally"]
	return ch_cfg().get("stage_ally", "")

var comp_k := 0
func comp_line(kind: String) -> String:
	var c: Dictionary = StoryData.COMPANION.get(companion(), {})
	var arr: Array = c.get(kind, [])
	if arr.is_empty():
		return ""
	comp_k += 1
	return arr[comp_k % arr.size()]

const FINAL_COMP := {
	"baegun": [{"who": "{alias}", "pose": "hero_disguise_angry", "text": "서휘. 이건… 내가 끝내야 해."},
		{"who": "서휘", "pose": "seohwi", "text": "…그래. 이건 네 싸움이다.\n나는 저 문 앞에서 흑룡파 놈들을 막겠다. 하나도 못 들어오게."}],
	"shadow": [{"who": "{name}", "pose": "hero_angry", "text": "나리, 저 사람의 패거리를 막아 주세요.\n아버지는… 제가 되찾을 거예요."},
		{"who": "윤도결", "pose": "jongsagwan", "text": "가라. 포졸들과 내가 뒤를 막는다.\n네 아버지는 네가 데려와라."}],
}

func start_battle(enemy_id: String, on_win: Callable, opts := {}) -> void:
	var comp := companion()
	if comp != "" and not opts.get("comp_done", false) and not opts.has("me_name"):
		var c: Dictionary = StoryData.COMPANION.get(comp, {})
		opts = opts.duplicate(); opts["comp_done"] = true
		var me := "{alias}" if chapter in DISGUISED else "{name}"
		var pre: Array = FINAL_COMP.get(enemy_id, [])
		if pre.is_empty() and c.has("pre"):
			pre = [{"who": me, "text": comp_line("pre_me")}, {"who": c["name"], "pic": c["pic"], "text": comp_line("pre")}]
		var post_line: String = comp_line("post") if not FINAL_COMP.has(enemy_id) else ""
		var win := on_win
		if post_line != "":
			win = func(): dialog_chain([{"who": c["name"], "pic": c["pic"], "text": post_line}], on_win)
		dialog_chain(pre, func(): start_battle(enemy_id, win, opts))
		return
	var b := BattleScreen.new()
	var stl: Array = ch_cfg().get("stages", [])
	if stage_idx < stl.size() and stl[stage_idx].has("me_name") and not opts.has("me_name"):
		opts = opts.duplicate(); opts["me_name"] = stl[stage_idx]["me_name"]
	if not opts.has("ally"):
		var st: Array = ch_cfg().get("stages", [])
		if stage_idx < st.size() and st[stage_idx].has("ally"):
			opts = opts.duplicate(); opts["ally"] = st[stage_idx]["ally"]
		elif ch_cfg().has("stage_ally"):
			opts = opts.duplicate(); opts["ally"] = ch_cfg()["stage_ally"]
	b.enemy_id = enemy_id
	b.on_win = on_win
	b.opts = opts
	autosave()
	_swap(b, true)

## 만리길 판 → 여정 맵(작은 맵) → 다시 판으로
var sub_stage: Dictionary = {}
var world_board: Control = null
var voyage_done: Callable

func start_voyage(cfg: Dictionary, on_done: Callable) -> void:
	world_board = board
	sub_stage = cfg
	voyage_done = on_done
	var s := StageScreen.new()
	board = s
	_swap(s, true)
	autosave.call_deferred()

func end_voyage() -> void:
	if board and is_instance_valid(board):
		board.queue_free()
	board = world_board
	world_board = null
	sub_stage = {}
	current = board
	board.process_mode = Node.PROCESS_MODE_INHERIT
	board.show()
	if voyage_done.is_valid():
		voyage_done.call()
	autosave.call_deferred()

func end_battle(battle: Control) -> void:
	battle.queue_free()
	current = board
	board.process_mode = Node.PROCESS_MODE_INHERIT
	board.show()
	autosave.call_deferred()

func chapter_clear() -> void:
	if board:
		board.queue_free(); board = null
	current = null
	phase = "ending"
	var cfg := ch_cfg()
	play_story(chapter_lines("end"), func():
		if cfg.has("end_battle"):
			_end_duel(cfg)
		elif cfg.has("epilogue"):
			play_story(StoryData.lines(cfg["epilogue"]), func():
				phase = "title"
				show_title())
		else:
			_next_chapter())

## 장 끝의 싸움(예: 다래와의 다툼) — 이기든 지든 이야기는 이어진다
func _end_duel(cfg: Dictionary) -> void:
	var holder := Control.new()
	board = holder
	add_child(holder)
	start_battle(cfg["end_battle"], func():
		holder.queue_free(); board = null
		play_story(StoryData.lines(cfg.get("end_after", "")), _next_chapter), {"lose_ok": true, "no_reward": true})

## 작은 맵 하나를 끝내고 다음 맵으로
func next_stage() -> void:
	stage_idx += 1
	if board:
		board.queue_free(); board = null
	current = null
	start_board()

func _next_chapter() -> void:
	if StoryData.CHAPTERS.has(chapter + 1):
		chapter += 1
		stage_idx = 0
		phase = "prologue"
		play_story(chapter_lines("intro"), start_board)
		autosave.call_deferred("새 장 자동 저장")
	else:
		phase = "title"
		show_title()

func game_over(reason: String, pic := "") -> void:
	popup(reason + "\n\n다시 도전하시겠습니까?", "다시 하기", func():
		if board and current != board:
			current.queue_free()
		if board:
			board.queue_free(); board = null
		current = null
		max_hp = 50   # 다시 하기: 엽전·약병·탕약·약초는 그대로 둔다
		start_board(), "", pic, "", true)

# ── 이름 ────────────────────────────────────────────────
var alias_name := ""

func alias() -> String:
	return alias_name if alias_name != "" else hero_name.left(1) + "돌이"

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

func _name_edit(text: String, max_len: int) -> LineEdit:
	var edit := LineEdit.new()
	edit.text = text
	edit.max_length = max_len
	edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	edit.custom_minimum_size = Vector2(360, 92)
	edit.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	edit.add_theme_font_override("font", TITLE_FONT)
	edit.add_theme_font_size_override("font_size", 48)
	edit.add_theme_color_override("font_color", INK)
	edit.add_theme_color_override("caret_color", RED)
	var sb := tex_box("button", 34, 16)
	edit.add_theme_stylebox_override("normal", sb)
	edit.add_theme_stylebox_override("focus", sb)
	return edit

func ask_name(cb: Callable) -> void:
	var o := _overlay("이름 짓기")
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	vb.add_child(_note("누명을 쓰고 쫓기게 될 소녀의 이름"))
	var edit := _name_edit(hero_name, 4)
	vb.add_child(edit)
	vb.add_child(_note("사내아이로 변장했을 때 쓸 이름"))
	var edit2 := _name_edit(alias(), 5)
	vb.add_child(edit2)
	var touched := {"v": alias_name != ""}
	edit.text_changed.connect(func(t: String):
		if not touched["v"]:
			var n := t.strip_edges()
			edit2.text = (n.left(1) if n != "" else "연") + "돌이")
	edit2.text_changed.connect(func(_t): touched["v"] = true)
	var ok := make_button("이 이름으로 시작", 32)
	ok.custom_minimum_size = Vector2(0, 100)
	vb.add_child(ok)
	ok.pressed.connect(func():
		var n := edit.text.strip_edges()
		hero_name = n if n != "" else "연이"
		var a2 := edit2.text.strip_edges()
		alias_name = a2 if a2 != "" and a2 != hero_name.left(1) + "돌이" else ""
		if a2 != "" and touched["v"]:
			alias_name = a2
		layer.queue_free()
		if cb.is_valid():
			cb.call())

const DISGUISED := [2, 3, 4, 7, 8]

func token_name() -> String:
	return "token_disguise" if chapter in DISGUISED else "token_hero"

func face_name() -> String:
	return "face_token" if chapter in DISGUISED else "face_hero"

func is_placeholder(pic: String) -> bool:
	return pic in StoryData.PLACEHOLDERS

## "(준비중)" 표시 붙이기
func tag_placeholder(parent: Control, pic: String) -> void:
	if not is_placeholder(pic):
		return
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", plaque_style())
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.top_level = false
	p.set_anchors_preset(Control.PRESET_CENTER_TOP)
	p.offset_left = -90; p.offset_right = 90; p.offset_top = 8; p.offset_bottom = 68
	var l := make_label("(준비중)", 26, GOLD, true)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p.add_child(l)
	p.name = "PlaceholderTag"
	p.z_index = 5
	parent.add_child(p)

## 이야기 줄에 붙은 보상·효과 적용
func apply_line_effects(line: Dictionary) -> void:
	if line.has("coin"): coins += int(line["coin"])
	if line.has("potion"): potions += int(line["potion"])
	if line.has("guard"): next_guard += int(line["guard"])
	if line.has("maxhp"): max_hp += int(line["maxhp"])
	if line.has("heal"): hp = min(max_hp, hp + int(line["heal"]))
	if line.has("coin") or line.has("potion") or line.has("maxhp"):
		sfx("good")

## 팝업으로 이어지는 짧은 이야기. line: {who, pic, text, bg, choices:[{text,set}], if, ifnot}
## 장면 배경음: 검은 사내·삿갓 백운이 나오면 무서운 곡, "music" 줄은 그 곡으로
const SCENE_MUSIC := {"shadow": "dread_shadow", "baegun_boss": "dread_sakgat"}
var chain_music := ""
func line_music(line: Dictionary) -> void:
	if line.has("music"):
		bgm(line["music"]); return
	var p: String = line.get("pic", line.get("pose", ""))
	if SCENE_MUSIC.has(p):
		bgm(SCENE_MUSIC[p])

func dialog_chain(lines: Array, cb: Callable, i := 0, bg := "") -> void:
	while i < lines.size():
		var ln: Dictionary = lines[i]
		if ln.has("if") and not flags.has(ln["if"]):
			i += 1; continue
		if ln.has("ifnot") and flags.has(ln["ifnot"]):
			i += 1; continue
		break
	if i >= lines.size():
		if chain_music != "" and audio and audio.current_bgm != chain_music and audio.current_bgm in SCENE_MUSIC.values() + ["sad_farewell", "heart_flutter", "lonely_night", "yakbang_day", "darae_cheer"]:
			bgm(chain_music)   # 대화가 끝나면 원래 배경음으로
		chain_music = ""
		if cb.is_valid():
			cb.call()
		return
	var line: Dictionary = lines[i]
	var nbg: String = line.get("bg", bg)
	apply_line_effects(line)
	if i == 0:
		chain_music = audio.current_bgm if audio else ""
	line_music(line)
	var next := func(): dialog_chain(lines, cb, i + 1, nbg)
	if line.has("choices"):
		popup_choices(line["text"], line["choices"], func(k: int):
			var st: String = line["choices"][k].get("set", "")
			if st != "":
				flags[st] = true
			next.call(), fmt(line.get("who", "")), line.get("pic", line.get("pose", "")), nbg)
	else:
		popup(line["text"], "다음", next, fmt(line.get("who", "")), line.get("pic", line.get("pose", "")), nbg,
			line["text"].begins_with("【목표】"))

func popup_choices(text: String, choices: Array, cb: Callable, title := "", pic := "", bg := "") -> void:
	var o := _overlay(title, bg, pic, true)
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	var l := make_label(fmt(text), 30, GOAL_BROWN if text.begins_with("【목표】") else INK)
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

## 맵 위에 서는 데포르메(SD) 그림. 없으면 null
const CHIBI_OF := {"hero_adult": "hero_adult", "hero_angry": "hero", "hero_sad": "hero", "hero_surprised": "hero", "hero_disguise_angry": "hero_disguise", "hero_disguise_sad": "hero_disguise", "hero_disguise_surprised": "hero_disguise",
	"seohwi": "seohwi", "seohwi_battle": "seohwi", "seohwi_dutch": "seohwi_dutch", "jongsagwan": "dogyeol", "jongsagwan_blush": "dogyeol",
	"heo": "heo", "heo_ill": "heo", "pojol_battle": "pojol", "friend_worried": "friend", "darae_court": "friend", "baegun_boss": "baegun_boss", "addict": "addict", "shadow": "shadow", "jumo": "jumo", "yakjae": "yakjae"}

## 진짜 데포르메 그림만 (없으면 null)
## 마지막 장: 한양으로 돌아온 서휘는 새 차림으로
func _ret(name: String) -> String:
	if chapter >= 9 and name in ["seohwi", "seohwi_battle"]:
		return "seohwi_return"
	if chapter >= 9 and name == "friend":
		return "darae_adult"   # 돌아온 뒤의 다래는 어른 모습
	return name

func chibi_only(name: String) -> Texture2D:
	name = _ret(name)
	var p := "res://assets/chibi/%s.png" % CHIBI_OF.get(name, name)
	return load(p) if ResourceLoader.exists(p) else null

func chibi(name: String) -> Texture2D:
	name = _ret(name)
	var p := "res://assets/chibi/%s.png" % CHIBI_OF.get(name, name)
	if ResourceLoader.exists(p):
		return load(p)
	# 데포르메가 없으면 여백을 잘라 낸 전신 그림 (키를 맞추기 위해)
	var q := "res://assets/mapfig/%s.png" % name
	return load(q) if ResourceLoader.exists(q) else null

## 대화창: 문장이 끝나면(마침표·물음표·느낌표) 다음 문장은 새 줄에서
func sentence_breaks(t: String) -> String:
	var re := RegEx.new()
	re.compile("([.?!。]+[\"'」)]?) +(?=\\S)")
	return re.sub(t, "$1\n", true)

## 대화 그림 키 비율: 남자 어른 1.0 기준, 주인공·여자는 조금 작게, 아이는 더 작게
func fig_scale(name: String) -> float:
	if name.begins_with("dutch_child") or name in ["island_child", "children"]:
		return 0.66
	if name.begins_with("hero_adult"):
		return 0.92
	if name.begins_with("hero_disguise") and name != "hero_disguise_hair":
		return 0.88   # 남장 주인공 (패랭이 포함 원래 크기)
	if name.begins_with("hero_court"):
		return 0.82   # 의녀·어의 옷 주인공은 평상복 주인공과 같은 크기
	if name.begins_with("hero"):
		return 0.82   # 여자 옷·머리 푼 모습은 패랭이가 없으니 남장 주인공 몸 크기에 맞춤
	if name == "darae_prison":
		return 0.62   # 무릎 꿇은 모습
	if name == "daebi_ill":
		return 0.6    # 보료에 기대 앉은 모습
	if name == "daebi_smile":
		return 0.72
	if name.begins_with("friend") or name.begins_with("darae") or name == "jumo":
		return 0.86
	if name == "addict":
		return 0.65   # 쪼그려 앉은 중독자: 전투 화면과 같은 크기로
	if name.begins_with("baegun_exile"):
		return 0.95
	return 1.0

## 궁에 있는 동안(제5장)은 주인공이 궁 옷차림 그림으로 (그림이 있을 때만)
const COURT_CHAPTERS := [5]

func illust(name: String) -> Texture2D:
	name = _ret(name)
	if chapter in COURT_CHAPTERS and (name == "hero" or name.begins_with("hero_")) and not name.begins_with("hero_disguise") and not name.begins_with("hero_adult"):
		var cn := "hero_court" + name.substr(4)
		if ResourceLoader.exists("res://assets/chars/%s.png" % cn):
			name = cn
		elif ResourceLoader.exists("res://assets/chars/hero_court.png"):
			name = "hero_court"
	var p := "res://assets/chars/%s.png" % name
	if not ResourceLoader.exists(p) and CHAR_FALLBACK.has(name):
		p = "res://assets/chars/%s.png" % CHAR_FALLBACK[name]
	return load(p) if ResourceLoader.exists(p) else null

## 아직 그림이 없을 때 임시로 쓰는 그림
const CHAR_FALLBACK := {"hero_disguise_hair": "hero_disguise_sad"}

const BG_FALLBACK := {"yakbang_calm": "yakbang", "palace_night": "palace", "naeuiwon": "yakbang", "mapo_warehouse": "den",
	"flash_plague": "street_ink", "flash_carried": "street_ink", "flash_seohwi_parents": "island", "flash_dogyeol": "alley"}

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
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(func(): sfx("click", -8.0))
	return b

func sfx(name: String, vol_db := 0.0) -> void:
	if audio:
		audio.sfx(name, vol_db)

func bgm(name: String) -> void:
	if audio:
		audio.bgm(name)

func ink_text(l: Label, outline := 10) -> Label:
	l.add_theme_color_override("font_outline_color", INK)
	l.add_theme_constant_override("outline_size", outline)
	return l

# ── 상소문 카드 ─────────────────────────────────────────
func _sangso_button(paper: String, w: int, h: int) -> Button:
	var b := Button.new()
	b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS  # 손가락을 대는 순간 눌림
	b.focus_mode = Control.FOCUS_NONE
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
	var paper := "sangso" if entry["lv"] == 1 else ("sangso_gold" if entry["lv"] == 2 else ("sangso_red" if entry["lv"] == 3 else "sangso_sky"))
	var b := _sangso_button(paper, w, h)
	b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS  # 손가락이 조금 움직여도 눌리게
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
func _overlay(title: String, bg := "", pic := "", bottom := false) -> Array:
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
	var pt: Texture2D = illust(pic) if pic != "" and not (bg in ["wedding", "family"]) else null
	var fig: AspectRatioContainer = null
	if pt:
		# 인물은 발끝이 대화창 바로 위에 닿게 (아래 정렬)
		fig = AspectRatioContainer.new()
		fig.ratio = float(pt.get_width()) / max(1.0, float(pt.get_height()))
		fig.stretch_mode = AspectRatioContainer.STRETCH_FIT
		fig.alignment_vertical = AspectRatioContainer.ALIGNMENT_END
		fig.anchor_right = 1.0; fig.anchor_bottom = 0.6
		fig.offset_top = 40; fig.offset_left = 30; fig.offset_right = -30
		fig.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var r := TextureRect.new()
		r.texture = pt
		r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fig.add_child(r)
		fig.modulate.a = 0.0
		layer.add_child(fig)
		tag_placeholder(r, pic)
		create_tween().tween_property(fig, "modulate:a", 1.0, 0.4)
	var center: Container
	if pt:   # 전신 인물이 나올 때만 대화창을 아래로, 아니면 가운데
		# 그림이 있는 대화창은 화면 맨 아래에
		var col := VBoxContainer.new()
		col.alignment = BoxContainer.ALIGNMENT_END
		col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		col.offset_bottom = -26
		center = col
	else:
		center = CenterContainer.new()
		center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", panel_style())
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	center.add_child(panel)
	if fig:
		var fsc: float = fig_scale(pic)
		var fit := func():
			if is_instance_valid(fig) and is_instance_valid(panel):
				# 발끝은 대화창 위, 키는 인물마다 (여자·아이는 조금 작게)
				var bottom_y: float = panel.global_position.y + 6
				fig.anchor_top = 0.0; fig.anchor_bottom = 0.0
				fig.offset_bottom = bottom_y
				fig.offset_top = 40 + (bottom_y - 40) * (1.0 - fsc)
		panel.item_rect_changed.connect(fit)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 18)
	panel.add_child(vb)
	if title != "":
		var t := make_label(title, 42, RED, true)
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(t)
	sfx("scroll", -6.0)
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

func popup(text: String, button_text := "확인", cb := Callable(), title := "", pic := "", bg := "", centered := false) -> void:
	var o := _overlay(title, bg, pic, not centered)
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	var l := make_label(fmt(text), 30, GOAL_BROWN if text.begins_with("【목표】") else INK)
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
			sfx("card_play")
			deck.append(e)
			done.call())
	var skip := make_button("그냥 지나간다", 28)
	skip.custom_minimum_size = Vector2(0, 88)
	vb.add_child(skip)
	skip.pressed.connect(done)

# ── 엽전 표시 ───────────────────────────────────────────
func coin_plaque() -> Array:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", plaque_style())
	p.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10)
	p.add_child(hb)
	var ic := tex_rect(icon("coin"), Vector2(40, 40))
	ic.modulate = Color(1.0, 0.85, 0.45)
	hb.add_child(ic)
	var l := make_label("", 32, GOLD, true)
	hb.add_child(l)
	var upd := func():
		l.text = "엽전 %d냥 · 약초 %d · 약병 %d" % [coins, herbs, potions + potions_small]
	upd.call()
	return [p, upd]

# ── 보따리: 같은 상소 합치기 / 엽전으로 단련 ──────────────
const UPGRADE_COST := [0, 5, 10, 15]   # ★1→★2 5냥, ★2→★3 10냥, ★3→★4 15냥

## ── 약탕관: 약초 4개 + 엽전으로 탕약 달이기 ──────────────
const BREW_HERBS := 4
const BREW_SMALL := 2
const HERB_MAX := 8   # 약탕관에 보관할 수 있는 약초 수
const BREWS := [{"key": "small", "name": "묽은 탕약", "lv": "2단계", "heal": 20, "cost": 3, "herbs": 2},
	{"key": "big", "name": "진한 탕약", "lv": "3단계", "heal": 40, "cost": 6, "herbs": 4}]

func show_brew(cb := Callable()) -> void:
	var o := _overlay("약탕관")
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	var info := make_label("", 30, INK)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(info)
	var slots := GridContainer.new()
	slots.columns = 4
	slots.add_theme_constant_override("h_separation", 14)
	slots.add_theme_constant_override("v_separation", 10)
	var slot_c := CenterContainer.new()
	slot_c.add_child(slots)
	vb.add_child(slot_c)
	var herb_tex: Texture2D = load("res://assets/ui/tiles/deco_herb.png")
	var cells: Array = []
	for k in HERB_MAX:
		var pc := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("efe2c4"); sb.set_corner_radius_all(14)
		sb.border_color = Color("8a6a3a"); sb.set_border_width_all(3)
		pc.add_theme_stylebox_override("panel", sb)
		pc.custom_minimum_size = Vector2(96, 96)
		var r := TextureRect.new()
		r.texture = herb_tex
		r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		r.custom_minimum_size = Vector2(90, 100)
		pc.add_child(r)
		slots.add_child(pc)
		cells.append(r)
	var msg := make_label("", 26, INK_SOFT)
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg.custom_minimum_size = Vector2(540, 0)
	vb.add_child(msg)
	var btns: Array = []
	var refresh := func():
		info.text = "가진 약초 %d개 · 엽전 %d냥\n묽은 탕약 %d병 · 진한 탕약 %d병" % [herbs, coins, potions_small, potions]
		for k in cells.size():
			cells[k].modulate = Color(1, 1, 1, 1) if k < herbs else Color(0.3, 0.3, 0.3, 0.35)
		for b in btns:
			b.modulate = Color.WHITE if herbs >= int(b.get_meta("need")) else Color(0.6, 0.6, 0.6)
		if cb.is_valid():
			cb.call()
	for br in BREWS:
		var need: int = int(br["herbs"])
		var b := make_button("%s 달이기 (%s) · 체력 +%d\n약초 %d개 + %d냥" % [br["name"], br["lv"], br["heal"], need, br["cost"]], 26)
		b.set_meta("need", need)
		b.custom_minimum_size = Vector2(0, 104)
		vb.add_child(b)
		btns.append(b)
		b.pressed.connect(func():
			if herbs < need:
				msg.text = "약초가 %d개 더 필요합니다." % (need - herbs)
				msg.add_theme_color_override("font_color", RED)
				return
			if coins < int(br["cost"]):
				msg.text = "엽전이 모자랍니다 (%d냥 필요)" % br["cost"]
				msg.add_theme_color_override("font_color", RED)
				return
			herbs -= need
			coins -= int(br["cost"])
			if br["key"] == "small":
				potions_small += 1
			else:
				potions += 1
			sfx("potion")
			msg.text = "보글보글… %s 한 병을 달였습니다!" % br["name"]
			msg.add_theme_color_override("font_color", INK_SOFT)
			_steam(slots)
			refresh.call())
	var close := make_button("닫기", 28)
	close.custom_minimum_size = Vector2(0, 80)
	vb.add_child(close)
	close.pressed.connect(func(): layer.queue_free())
	refresh.call()

## 달일 때 김이 피어오르는 연출
func _steam(at: Control) -> void:
	for k in 5:
		var l := make_label("～", 44, Color(1, 1, 1, 0.9), true)
		at.add_child(l)
		l.top_level = true
		l.global_position = at.global_position + Vector2(at.size.x * (0.2 + 0.15 * k), 10)
		var tw := l.create_tween().set_parallel()
		tw.tween_property(l, "global_position:y", l.global_position.y - 90, 0.9).set_delay(0.08 * k)
		tw.tween_property(l, "modulate:a", 0.0, 0.9).set_delay(0.08 * k)
		tw.chain().tween_callback(l.queue_free)

func show_bag(cb := Callable()) -> void:
	var o := _overlay("보따리")
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	var cp := coin_plaque()
	vb.add_child(cp[0])
	var info := _note("")
	vb.add_child(info)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(560, 760)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.scroll_deadzone = 18
	vb.add_child(scroll)
	var grid := GridContainer.new()
	grid.mouse_filter = Control.MOUSE_FILTER_PASS
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(grid)
	var up := make_button("", 28)
	up.custom_minimum_size = Vector2(0, 86)
	vb.add_child(up)
	var close := make_button("닫기", 30)
	close.custom_minimum_size = Vector2(0, 86)
	vb.add_child(close)
	close.pressed.connect(func():
		layer.queue_free()
		if cb.is_valid():
			cb.call())
	var state := {"sel": -1, "msg": ""}
	var rebuild := func(self_ref: Callable) -> void:
		for ch in grid.get_children():
			ch.queue_free()
		cp[1].call()
		info.text = "상소 %d장 · 하나를 고르면 엽전으로 단련할 수 있고,\n같은 상소(같은 ★)를 하나 더 누르면 엽전(★2 5냥·★3 10냥·★4 15냥)에 합쳐집니다" % deck.size()
		if state["msg"] != "":
			info.text = state["msg"]
		var sel: int = state["sel"]
		if sel >= 0 and sel < deck.size():
			var lv: int = int(deck[sel]["lv"])
			if lv >= GameData.MAX_LV:
				up.text = "이미 가장 강한 상소 (★4)"
				up.disabled = true
			else:
				up.text = "단련하기  ★%d → ★%d  (엽전 %d냥)" % [lv, lv + 1, UPGRADE_COST[lv]]
				up.disabled = false
		else:
			up.text = "상소를 골라 단련하기"
			up.disabled = true
		for i in deck.size():
			var b := card_button(deck[i], 132, 220)
			# 스크롤 안의 상소: 끌면 스크롤, 떼면 선택
			b.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
			b.mouse_filter = Control.MOUSE_FILTER_PASS
			if i == sel:
				b.modulate = Color(1.0, 0.82, 0.55)
			grid.add_child(b)
			var idx := i
			b.pressed.connect(func():
				_bag_tap(idx, state)
				self_ref.call(self_ref))
	up.pressed.connect(func():
		var sel: int = state["sel"]
		if sel < 0 or sel >= deck.size():
			return
		var lv: int = int(deck[sel]["lv"])
		if lv >= GameData.MAX_LV:
			return
		if coins < UPGRADE_COST[lv]:
			sfx("click", -4.0)
			state["msg"] = "엽전이 모자랍니다! (단련 %d냥 · 지금 %d냥)" % [UPGRADE_COST[lv], coins]
			rebuild.call(rebuild)
			return
		coins -= UPGRADE_COST[lv]
		sfx("upgrade")
		var id: String = deck[sel]["id"]
		deck[sel] = {"id": id, "lv": lv + 1}
		_sort_deck()
		state["sel"] = -1
		state["msg"] = "%s 단련 완료! %s" % [GameData.CARDS[id]["name"], "★".repeat(lv + 1)]
		rebuild.call(rebuild))
	_sort_deck()
	rebuild.call(rebuild)

func _sort_deck() -> void:
	deck.sort_custom(func(a, b): return a["id"] < b["id"] or (a["id"] == b["id"] and int(a["lv"]) > int(b["lv"])))

func _bag_tap(i: int, state: Dictionary) -> void:
	var sel: int = state["sel"]
	state["msg"] = ""
	if sel == -1 or sel == i:
		state["sel"] = -1 if sel == i else i
		return
	var a: Dictionary = deck[sel]
	var b: Dictionary = deck[i]
	if a["id"] != b["id"] or int(a["lv"]) != int(b["lv"]):
		state["sel"] = i
		return
	if int(a["lv"]) >= GameData.MAX_LV:
		state["sel"] = -1
		state["msg"] = "이미 가장 강한 상소입니다 (★4)"
		return
	if deck.size() <= GameData.MIN_DECK:
		# 상소가 너무 적으면 합치지 않고 고른 한 장만 엽전으로 단련
		var c1: int = UPGRADE_COST[int(a["lv"])]
		if coins < c1:
			state["sel"] = -1
			state["msg"] = "엽전이 모자랍니다! (단련 %d냥 · 지금 %d냥)" % [c1, coins]
			return
		coins -= c1
		deck[i] = {"id": a["id"], "lv": int(a["lv"]) + 1}
		sfx("upgrade")
		_sort_deck()
		state["sel"] = -1
		state["msg"] = "%s %s 단련! (엽전 -%d냥)\n상소가 %d장뿐이라 합치지 않고 한 장만 올렸어요" % [GameData.CARDS[a["id"]]["name"], "★".repeat(int(a["lv"]) + 1), c1, deck.size()]
		return
	var cost: int = UPGRADE_COST[int(a["lv"])]
	if coins < cost:
		state["sel"] = -1
		state["msg"] = "엽전이 모자랍니다! (합치기 %d냥 · 지금 %d냥)" % [cost, coins]
		return
	coins -= cost
	var nlv: int = int(a["lv"]) + 1
	var id: String = a["id"]
	for k in [max(sel, i), min(sel, i)]:
		deck.remove_at(k)
	deck.append({"id": id, "lv": nlv})
	sfx("upgrade")
	_sort_deck()
	state["sel"] = -1
	state["msg"] = "%s %s 완성! (엽전 -%d냥)" % [GameData.CARDS[id]["name"], "★".repeat(nlv), cost]

# ── 장터 ────────────────────────────────────────────────
const CARD_PRICE := 4
const POTION_PRICE := 10

func open_shop(cb: Callable) -> void:
	var o := _overlay("장터", "jangteo")
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	var cp := coin_plaque()
	vb.add_child(cp[0])
	var refresh: Callable = cp[1]
	var msg := _note("상소 한 장 %d냥 · 진한 탕약 %d냥 · 단련 5~15냥" % [CARD_PRICE, POTION_PRICE])
	vb.add_child(msg)
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
				msg.text = "엽전이 모자랍니다 (상소 %d냥)" % CARD_PRICE
				msg.add_theme_color_override("font_color", RED)
				b.pivot_offset = b.size / 2.0
				var sh := create_tween()
				sh.tween_property(b, "rotation", 0.06, 0.05); sh.tween_property(b, "rotation", -0.06, 0.08); sh.tween_property(b, "rotation", 0.0, 0.05)
				return
			coins -= CARD_PRICE
			sfx("coin")
			deck.append(e)
			b.disabled = true
			b.modulate = Color(0.55, 0.55, 0.55)
			msg.text = "〈%s〉 상소를 샀습니다! 보따리에 넣었어요." % GameData.stats(e["id"], 1)["name"]
			msg.add_theme_color_override("font_color", INK_SOFT)
			refresh.call())
	var pot := make_button("진한 탕약 사기 · 체력 +40 (%d냥)" % POTION_PRICE, 28)
	pot.custom_minimum_size = Vector2(0, 86)
	vb.add_child(pot)
	pot.pressed.connect(func():
		if coins < POTION_PRICE:
			msg.text = "엽전이 모자랍니다 (약병 %d냥)" % POTION_PRICE
			msg.add_theme_color_override("font_color", RED)
			return
		coins -= POTION_PRICE
		sfx("coin")
		potions += 1
		msg.text = "진한 탕약을 샀습니다! (지금 %d병)" % potions
		msg.add_theme_color_override("font_color", INK_SOFT)
		refresh.call())
	var brew := make_button("약탕관 · 약초로 약 달이기", 28)
	brew.custom_minimum_size = Vector2(0, 86)
	vb.add_child(brew)
	brew.pressed.connect(func(): show_brew(refresh))
	var bag := make_button("보따리 열기 · 상소 단련", 28)
	bag.custom_minimum_size = Vector2(0, 86)
	vb.add_child(bag)
	bag.pressed.connect(func(): show_bag(refresh))
	var leave := make_button("장터를 떠난다", 28)
	leave.custom_minimum_size = Vector2(0, 86)
	vb.add_child(leave)
	leave.pressed.connect(func():
		layer.queue_free()
		if cb.is_valid():
			cb.call())

# ── 저장 / 불러오기 ─────────────────────────────────────
const SLOTS := ["auto", "1", "2", "3"]
const AUTOSAVE_SEC := 300.0
var phase := "title"     # title / prologue / board / ending
var autosave_timer: Timer

func _setup_autosave() -> void:
	autosave_timer = Timer.new()
	autosave_timer.wait_time = AUTOSAVE_SEC
	autosave_timer.autostart = true
	autosave_timer.timeout.connect(func(): autosave("5분 자동 저장"))
	add_child(autosave_timer)
	get_tree().set_auto_accept_quit(false)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_WM_GO_BACK_REQUEST:
			autosave("종료 자동 저장")
			get_tree().quit()
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT:
			autosave("화면 전환 자동 저장")

func _save_path(slot: String) -> String:
	return "user://save_%s.json" % slot

func snapshot() -> Dictionary:
	var d := {"ver": 2, "phase": phase, "stage_idx": stage_idx, "hero_name": hero_name, "alias_name": alias_name, "max_hp": max_hp, "hp": hp,
		"coins": coins, "potions": potions, "potions_small": potions_small, "herbs": herbs, "deck": deck, "chapter": chapter, "flags": flags,
		"next_energy": next_energy, "next_guard": next_guard,
		"time": Time.get_datetime_string_from_system(false, true)}
	var bd: Control = world_board if (world_board and is_instance_valid(world_board)) else board
	if bd and is_instance_valid(bd):
		d["board"] = bd.get_state()
		d["place"] = bd.place_name()
	return d

func can_save() -> bool:
	return phase == "board" or phase == "prologue"

func save_game(slot: String) -> bool:
	if not can_save():
		return false
	var f := FileAccess.open(_save_path(slot), FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(snapshot()))
	f.close()
	return true

func autosave(reason := "") -> void:
	if save_game("auto") and reason != "":
		_toast(reason)

func read_save(slot: String) -> Dictionary:
	if not FileAccess.file_exists(_save_path(slot)):
		return {}
	var d = JSON.parse_string(FileAccess.get_file_as_string(_save_path(slot)))
	return d if d is Dictionary else {}

func has_any_save() -> bool:
	for s in SLOTS:
		if FileAccess.file_exists(_save_path(s)):
			return true
	return false

func load_game(slot: String) -> void:
	var d := read_save(slot)
	if d.is_empty():
		return
	hero_name = d.get("hero_name", "연이"); alias_name = d.get("alias_name", "")
	max_hp = int(d.get("max_hp", 40)); hp = int(d.get("hp", max_hp))
	coins = int(d.get("coins", 0)); potions = int(d.get("potions", 2))
	potions_small = int(d.get("potions_small", 0)); herbs = mini(int(d.get("herbs", 0)), HERB_MAX)
	chapter = int(d.get("chapter", 1)); flags = d.get("flags", {})
	if not flags.has("hp_plus10"):   # 체력 +10 조정 전 저장
		flags["hp_plus10"] = true; max_hp += 10; hp += 10
	stage_idx = int(d.get("stage_idx", 0))
	next_energy = int(d.get("next_energy", 0)); next_guard = int(d.get("next_guard", 0))
	deck = []
	for e in d.get("deck", []):
		deck.append({"id": str(e["id"]), "lv": int(e["lv"])})
	if deck.is_empty():
		deck = make_deck(GameData.START_DECK)
	if world_board and is_instance_valid(world_board):
		world_board.queue_free()
	world_board = null; sub_stage = {}
	if board:
		board.queue_free(); board = null
	if d.get("phase", "") == "board" and d.has("board") and int(d.get("ver", 1)) >= 2:
		phase = "board"
		board = BoardScreen.new() if ch_cfg().get("world", false) else StageScreen.new()
		board.restore = d["board"]
		_swap(board)
	else:
		phase = "prologue"
		play_story(chapter_lines("intro"), start_board)

func _slot_label(slot: String) -> String:
	var d := read_save(slot)
	var head := "자동 저장" if slot == "auto" else "%s번 칸" % slot
	if d.is_empty():
		return "%s\n— 비어 있음 —" % head
	var where := "제%d장 시작" % int(d.get("chapter", 1)) if d.get("phase", "") != "board" else "제%d장 · %s" % [int(d.get("chapter", 1)), d.get("place", "")]
	return "%s · %s\n%s · %s" % [head, d.get("hero_name", ""), where, str(d.get("time", "")).replace("T", " ").left(16)]

## mode: "save" 또는 "load"
func open_slots(mode: String, cb := Callable()) -> void:
	var o := _overlay("저장하기" if mode == "save" else "불러오기")
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	var msg := _note("5분마다, 그리고 앱을 닫거나 다른 화면으로 넘어갈 때 자동 저장됩니다.")
	vb.add_child(msg)
	for s in SLOTS:
		if mode == "save" and s == "auto":
			continue
		var b := make_button(_slot_label(s), 24)
		b.custom_minimum_size = Vector2(560, 110)
		b.disabled = mode == "load" and read_save(s).is_empty()
		vb.add_child(b)
		var slot: String = s
		b.pressed.connect(func():
			if mode == "save":
				if save_game(slot):
					b.text = _slot_label(slot)
					msg.text = "%s번 칸에 저장했습니다." % slot
			else:
				layer.queue_free()
				load_game(slot))
	var close := make_button("닫기", 28)
	close.custom_minimum_size = Vector2(0, 86)
	vb.add_child(close)
	close.pressed.connect(func():
		layer.queue_free()
		if cb.is_valid():
			cb.call())

func open_menu() -> void:
	var o := _overlay("메뉴")
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	for item in [["저장하기", "save"], ["불러오기", "load"], ["설정", "settings"], ["처음 화면으로", "title"], ["닫기", "close"]]:
		var b := make_button(item[0], 30)
		b.custom_minimum_size = Vector2(460, 92)
		vb.add_child(b)
		var act: String = item[1]
		b.pressed.connect(func():
			layer.queue_free()
			_menu_act(act))

func _menu_act(act: String) -> void:
	match act:
		"save": open_slots("save")
		"load": open_slots("load")
		"settings": open_settings()
		"title":
			autosave()
			phase = "title"
			show_title()

func _toast(text: String) -> void:
	sfx("save", -10.0)
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", plaque_style())
	p.anchor_left = 0.5; p.anchor_right = 0.5
	p.offset_left = -200; p.offset_right = 200; p.offset_top = 200
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(p)
	var l := make_label(text, 26, GOLD, true)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p.add_child(l)
	p.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(p, "modulate:a", 1.0, 0.3)
	tw.tween_interval(1.4)
	tw.tween_property(p, "modulate:a", 0.0, 0.4)
	tw.tween_callback(layer.queue_free)

# ── 설정 (글꼴·소리·대사 속도) ──────────────────────────
const FONTS := [
	{"name": "고운바탕 (기본 · 붓 명조)", "path": "res://assets/fonts/GowunBatang-Bold.ttf"},
	{"name": "나눔명조 (단정한 명조)", "path": "res://assets/fonts/NanumMyeongjo-Bold.ttf"},
	{"name": "연성 (붓글씨 느낌)", "path": "res://assets/fonts/YeonSung-Regular.ttf"},
	{"name": "고운돋움 (읽기 쉬운 고딕)", "path": "res://assets/fonts/GowunDodum-Regular.ttf"},
	{"name": "휴대폰 기본 글꼴", "path": "system"},
]
const TEXT_SPEEDS := [["느리게", 18.0], ["보통", 28.0], ["빠르게", 45.0], ["즉시", 999.0]]
var font_idx := 0
var text_speed_idx := 1

func text_speed() -> float:
	return TEXT_SPEEDS[text_speed_idx][1]

func _font_for(i: int) -> Font:
	var path: String = FONTS[i]["path"]
	var f: Font
	if path == "system":
		var sf := SystemFont.new()
		sf.font_names = PackedStringArray(["sans-serif", "Noto Sans CJK KR", "Roboto"])
		f = sf
	elif ResourceLoader.exists(path):
		f = load(path)
	else:
		f = BODY_FONT
	if f is FontFile or f is SystemFont:
		f.fallbacks = [BODY_FONT, HANJA_FONT] if f != BODY_FONT else [HANJA_FONT]
	return f

func apply_font() -> void:
	var f := _font_for(font_idx)
	ThemeDB.fallback_font = f
	var dt := ThemeDB.get_default_theme()
	if dt:
		dt.default_font = f
	var pt := ThemeDB.get_project_theme()
	if pt:
		pt.default_font = f
	get_tree().root.propagate_notification(Control.NOTIFICATION_THEME_CHANGED)

func load_settings() -> void:
	var path := "user://settings.json"
	if FileAccess.file_exists(path):
		var d = JSON.parse_string(FileAccess.get_file_as_string(path))
		if d is Dictionary:
			font_idx = clampi(int(d.get("font", 0)), 0, FONTS.size() - 1)
			text_speed_idx = clampi(int(d.get("speed", 1)), 0, TEXT_SPEEDS.size() - 1)
			audio.bgm_volume = float(d.get("bgm", 0.7))
			audio.sfx_volume = float(d.get("sfx", 0.9))
	audio.apply_volume()
	apply_font()

func save_settings() -> void:
	var f := FileAccess.open("user://settings.json", FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"font": font_idx, "speed": text_speed_idx, "bgm": audio.bgm_volume, "sfx": audio.sfx_volume}))

func _slider(value: float, cb: Callable) -> HSlider:
	var s := HSlider.new()
	s.min_value = 0.0; s.max_value = 1.0; s.step = 0.05; s.value = value
	s.custom_minimum_size = Vector2(380, 56)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var g := StyleBoxFlat.new()
	g.bg_color = Color("6e4a2e"); g.set_corner_radius_all(6); g.content_margin_top = 8; g.content_margin_bottom = 8
	var fill := StyleBoxFlat.new()
	fill.bg_color = RED; fill.set_corner_radius_all(6); fill.content_margin_top = 8; fill.content_margin_bottom = 8
	s.add_theme_stylebox_override("slider", g)
	s.add_theme_stylebox_override("grabber_area", fill)
	s.add_theme_stylebox_override("grabber_area_highlight", fill)
	var img: Image = ui("node").get_image()
	img.resize(48, 48, Image.INTERPOLATE_LANCZOS)
	var knob := ImageTexture.create_from_image(img)
	s.add_theme_icon_override("grabber", knob)
	s.add_theme_icon_override("grabber_highlight", knob)
	s.value_changed.connect(cb)
	return s

func open_settings(cb := Callable()) -> void:
	var o := _overlay("설정")
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	vb.add_child(_note("글꼴", RED))
	var sample := make_label("", 30)
	sample.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sample.custom_minimum_size = Vector2(540, 0)
	var font_btns: Array = []
	for i in FONTS.size():
		var b := make_button("", 24)
		b.custom_minimum_size = Vector2(540, 66)
		vb.add_child(b)
		font_btns.append(b)
		var idx := i
		b.pressed.connect(func():
			font_idx = idx
			apply_font()
			_refresh_settings(font_btns, sample))
	vb.add_child(sample)
	_refresh_settings(font_btns, sample)

	vb.add_child(_note("대사 속도", RED))
	var sp := HBoxContainer.new()
	sp.add_theme_constant_override("separation", 8)
	sp.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_child(sp)
	var sp_btns: Array = []
	for i in TEXT_SPEEDS.size():
		var b := make_button(TEXT_SPEEDS[i][0], 24)
		b.custom_minimum_size = Vector2(128, 64)
		sp.add_child(b)
		sp_btns.append(b)
		var idx := i
		b.pressed.connect(func():
			text_speed_idx = idx
			for k in sp_btns.size():
				sp_btns[k].modulate = Color(1, 0.8, 0.55) if k == text_speed_idx else Color.WHITE)
	for k in sp_btns.size():
		sp_btns[k].modulate = Color(1, 0.8, 0.55) if k == text_speed_idx else Color.WHITE

	for row in [["배경음", "bgm"], ["효과음", "sfx"]]:
		var hb := HBoxContainer.new()
		hb.add_theme_constant_override("separation", 14)
		vb.add_child(hb)
		var l := make_label(row[0], 28, RED, true)
		l.custom_minimum_size = Vector2(110, 0)
		hb.add_child(l)
		var key: String = row[1]
		hb.add_child(_slider(audio.bgm_volume if key == "bgm" else audio.sfx_volume, func(v: float):
			if key == "bgm":
				audio.bgm_volume = v
			else:
				audio.sfx_volume = v
				sfx("coin")
			audio.apply_volume()))

	var close := make_button("닫기", 30)
	close.custom_minimum_size = Vector2(0, 86)
	vb.add_child(close)
	close.pressed.connect(func():
		save_settings()
		layer.queue_free()
		if cb.is_valid():
			cb.call())

func _refresh_settings(btns: Array, sample: Label) -> void:
	for i in btns.size():
		btns[i].text = ("● " if i == font_idx else "") + FONTS[i]["name"]
		btns[i].modulate = Color(1, 0.8, 0.55) if i == font_idx else Color.WHITE
	sample.add_theme_font_override("font", _font_for(font_idx))
	sample.text = "약방 문은 부서져 있었다. 흑심단(黑心丹)…"
