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
## 엽전: 들어오고 나간 양을 엔딩 기록용으로 함께 센다 (불러오기·새 게임 중에는 세지 않음)
var track_stats := false
var coins := 0:
	set(v):
		if track_stats:
			if v > coins:
				stat_add("coin_in", v - coins)
			elif v < coins:
				stat_add("coin_out", coins - v)
		coins = v

## 플레이 기록 (세이브마다 따로)
var play_sec := 0.0
var stats := {}
var app_active := true

func stat_add(key: String, n := 1) -> void:
	stats[key] = int(stats.get(key, 0)) + n

func stat_card(id: String) -> void:
	var cu: Dictionary = stats.get("cards", {})
	cu[id] = int(cu.get(id, 0)) + 1
	stats["cards"] = cu

func _process(delta: float) -> void:
	if app_active and phase != "title":
		play_sec += delta

static func fmt_time(sec: float) -> String:
	var m := int(sec) / 60
	return "%d시간 %d분" % [m / 60, m % 60] if m >= 60 else "%d분" % m
var potions := 2        # 진한 탕약(3단계, 체력 회복 +40)
var potions_small := 0  # 묽은 탕약(2단계, 체력 회복 +20)
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
	get_tree().create_timer(1.0).timeout.connect(func(): load("res://scripts/boot.gd").mark_ok())
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
			if args.has("pos"):   # 확인용: 그 칸에 말을 세워 본다
				await get_tree().create_timer(0.3).timeout
				board.pos = int(args["pos"]); board.token.position = board._node_px(board.pos)
				board._set_ship(board._at_sea(board.pos), false)
				board.token_pic.flip_h = board.on_ship and board._node_px(board.pos + 1).x < board._node_px(board.pos).x
				board._focus(board.token.position, false, 0.0)
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
		"stageintro":   # 맵 시작 목표 팝업 확인용
			chapter = int(args.get("ch", "1"))
			stage_idx = int(args.get("st", "0"))
			last_goal = args.get("goal", "")
			start_board()
			await get_tree().create_timer(1.5).timeout
			if args.has("next"):
				for b in get_tree().root.find_children("*", "Button", true, false):
					if b.text == "다음" or b.name == "TapNext":
						b.pressed.emit(); break
				await get_tree().create_timer(0.8).timeout
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
			if args.has("boss"):   # 확인용: 보스 칸을 화면에 비춰 본다
				for i in board.tiles.size():
					if board.tiles[i]["type"] == "boss":
						board._focus(board.tile_center(i), false); break
			if args.has("boss"):
				args["still"] = "1"
			if args.has("brewhint"):
				herbs = 6
				board._brew_hint()
			if args.has("brew"):
				herbs = 6; coins = 12
				show_brew(board._update_hud)
			await get_tree().create_timer(0.8).timeout
			if not args.has("still"):
				board.card_row.get_child(0).pressed.emit()
			if args.has("pop"):   # 이야기 칸 팝업 확인용
				var tk: Dictionary = board._talk_at(int(args["pop"]))
				if args.has("pic"): tk = {"who": "복면 하수인", "pic": args["pic"], "text": "비켜라. 대비마마께 가는 길은 여기서 끝이다."}
				popup(tk["text"] + "\n\n(약병 +1)", "고맙습니다", Callable(), tk["who"], tk.get("pic", ""))
			if args.has("say"):   # 동행 말주머니 확인용
				await get_tree().create_timer(2.5).timeout
				if args.has("long"):
					board._bubble(board.follower, "할아버지가 늘 그랬어. 바닷바람 맞고 자란 약초가 제일 독하고 제일 귀하다고. 조심해서 캐야 해!")
				else:
					board.comp_say("herb")
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
		"records":
			hero_name = "연이"; play_sec = 26640.0
			stats = {"brew_small": 18, "brew_big": 9, "herbs": 212, "coin_in": 864, "coin_out": 731, "wins": 96, "losses": 2, "cards": {"jumeok": 48, "pum": 30}}
			show_records(func(): open_title_book())
		"titlebook":
			open_title_book()
		"titlebg":
			seed(int(args.get("seed", "1")))
			show_title()
			if args.has("gal"):
				await get_tree().create_timer(0.5).timeout
				current._open_gallery()
		"slots":
			show_title()
		"cards":
			var bg := ColorRect.new(); bg.color = Color("3a2c22"); bg.set_anchors_preset(Control.PRESET_FULL_RECT); add_child(bg)
			var hb := HBoxContainer.new(); hb.position = Vector2(12, 120); hb.add_theme_constant_override("separation", 10); add_child(hb)
			for lv in [1, 2, 3]:
				hb.add_child(card_button({"id": "baldda", "lv": lv}))
			var hb2 := HBoxContainer.new(); hb2.position = Vector2(12, 420); hb2.add_theme_constant_override("separation", 10); add_child(hb2)
			for lv in [4, 5]:
				hb2.add_child(card_button({"id": "baldda", "lv": lv}))
		"chstory":
			chapter = int(args.get("ch", "2"))
			stage_idx = int(args.get("st", str(stage_idx)))
			if args.has("flag"): flags[args["flag"]] = true
			var all_l: Array = StoryData.lines(args.get("key", "CH2_INTRO"))
			var fr := int(args.get("from", "0"))
			var sl: Array = all_l.slice(fr)
			if not sl.is_empty() and not sl[0].has("bg"):   # 중간부터 볼 때도 그 장면의 배경을 이어서
				for j in range(fr - 1, -1, -1):
					if all_l[j].has("bg"):
						sl[0] = sl[0].duplicate(); sl[0]["bg"] = all_l[j]["bg"]; break
			play_story(sl, show_title)
		"chpop":
			chapter = int(args.get("ch", "2"))
			start_board()
			await get_tree().create_timer(0.6).timeout
			dialog_chain(StoryData.lines(args.get("key", "C2_DOGYEOL")).slice(int(args.get("from", "0"))), Callable())
		"battle":
			chapter = int(args.get("ch", "1"))
			stage_idx = int(args.get("st", "0"))
			start_board()
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
			await get_tree().create_timer(0.9).timeout
			for l in get_tree().root.find_children("*", "CanvasLayer", true, false):
				l.queue_free()
			show_bag()
		"shop":
			coins = 9
			start_board()
			await get_tree().create_timer(0.9).timeout
			for l in get_tree().root.find_children("*", "CanvasLayer", true, false):
				l.queue_free()
			coins = 60; goods = {"smoke": 2, "charm": 1}
			open_shop(Callable(), "보따리장수", board.data.get("bg", "jangteo"))
			if args.has("bag"):
				for l in get_tree().root.find_children("*", "CanvasLayer", true, false):
					l.queue_free()
				show_goods()
			elif args.has("buy"):
				await get_tree().create_timer(0.3).timeout
				var bs: Array = get_tree().root.find_children("*", "Button", true, false).filter(func(b): return b.text.ends_with("냥"))
				bs[1].pressed.emit()
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
		"loadtest2":
			chapter = int(args.get("ch", "3")); stage_idx = int(args.get("st", "1"))
			start_board()
			await get_tree().create_timer(1.5).timeout
			for l in get_tree().root.find_children("*", "CanvasLayer", true, false):
				l.queue_free()
			board.pos = 9; board.turns_left = 7; board.cleared[3] = true
			print("BEFORE pos=", board.pos, " turns=", board.turns_left, " seed=", board.map_seed, " phase=", phase)
			save_game("3")
			var sd := read_save("3")
			print("SAVED phase=", sd.get("phase"), " has_board=", sd.has("board"), " ver=", sd.get("ver"))
			load_game("3")
			await get_tree().create_timer(1.5).timeout
			print("AFTER pos=", board.pos, " turns=", board.turns_left, " seed=", board.map_seed, " cleared=", board.cleared.keys())
		"loadtest3":
			chapter = 7; stage_idx = 0
			start_board()
			await get_tree().create_timer(1.5).timeout
			for l in get_tree().root.find_children("*", "CanvasLayer", true, false):
				l.queue_free()
			var vi := -1
			for i in board.nodes.size():
				if board.nodes[i].get("type", "") == "voyage":
					vi = i; break
			board.pos = vi
			start_voyage(board.nodes[vi]["stage"], func(): print("BACK"))
			await get_tree().create_timer(1.5).timeout
			for l in get_tree().root.find_children("*", "CanvasLayer", true, false):
				l.queue_free()
			board.pos = 7; board.turns_left = 5
			print("BEFORE vi=", vi, " sub=", sub_stage.get("map"), " pos=", board.pos)
			save_game("3")
			load_game("3")
			await get_tree().create_timer(2.0).timeout
			print("AFTER sub=", sub_stage.get("map"), " pos=", board.pos, " turns=", board.turns_left, " world_pos=", world_board.pos if world_board else -1)
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
		track_stats = false
		max_hp = 50; hp = 50; coins = 0; potions = 2; potions_small = 0; herbs = 0
		play_sec = 0.0; stats = {}; track_stats = true
		chapter = 1; stage_idx = 0; flags = {"hp_plus10": true}; next_energy = 0; next_guard = 0; goods = {}
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

## 지금 맵이 세계 지도 보드인가 (7장 전체, 또는 장 중간의 귀향 만리길 같은 보드 맵)
func board_cfg() -> Dictionary:
	var c := ch_cfg()
	var st: Array = c.get("stages", [])
	if not c.get("world", false) and stage_idx < st.size() and st[stage_idx].has("board"):
		var d: Dictionary = st[stage_idx].duplicate()
		d["title"] = c.get("title", "")
		d["stage_board"] = true
		return d
	return c

func is_world_board() -> bool:
	return ch_cfg().get("world", false) or board_cfg().get("stage_board", false)

func start_board() -> void:
	hp = max_hp
	last_dialog_bg = ""
	next_energy = 0; next_guard = 0
	board = BoardScreen.new() if is_world_board() else StageScreen.new()
	phase = "board"
	_swap(board)
	autosave.call_deferred("자동 저장")

## opts: {"lose_ok": 져도 이야기 진행, "ally": 동료 id}
## 지금 함께 다니는 동료 (전투 도움 대신 대화로 함께한다)
func companion() -> String:
	if not sub_stage.is_empty():   # 항해 중 들르는 맵: 그 장의 동행이 따라온다
		return sub_stage.get("ally", ch_cfg().get("stage_ally", ""))
	var st: Array = ch_cfg().get("stages", [])
	var a: String = ch_cfg().get("stage_ally", "")
	if stage_idx < st.size() and st[stage_idx].has("ally"):
		a = st[stage_idx]["ally"]
	elif a == "seohwi" and flags.has("wed_dogyeol"):
		a = "dogyeol"   # 윤도결을 고른 뒤의 추억 길은 윤도결과 함께
	return a

## 동행 그림: 맵에 따라 옷차림이 다르면(ally_pic) 그 그림으로
func comp_pic() -> String:
	var c: Dictionary = StoryData.COMPANION.get(companion(), {})
	var st: Array = ch_cfg().get("stages", [])
	if not sub_stage.is_empty() and sub_stage.has("ally_pic"):
		return sub_stage["ally_pic"]
	if sub_stage.is_empty() and stage_idx < st.size() and st[stage_idx].has("ally_pic"):
		return st[stage_idx]["ally_pic"]
	return c.get("pic", "")

var last_dialog_bg := ""
var comp_k := 0
## 동행이 말없이 따라오는 맵 (예: 6장 비 내리는 밤길의 서휘)
func quiet_ally() -> bool:
	var ch: Dictionary = StoryData.CHAPTERS.get(chapter, {})
	var sts: Array = ch.get("stages", [])
	return stage_idx >= 0 and stage_idx < sts.size() and sts[stage_idx].get("quiet_ally", false)

func comp_line(kind: String) -> String:
	if quiet_ally():
		return ""
	var c: Dictionary = StoryData.COMPANION.get(companion(), {})
	var arr: Array = c.get(kind, [])
	if arr.is_empty():
		return ""
	comp_k += 1
	return arr[comp_k % arr.size()]

const FINAL_COMP := {
	"baegun": [{"who": "{alias}", "pose": "hero_disguise_angry", "text": "서휘. 이건… 내가 끝내야 해."},
		{"who": "서휘", "pose": "seohwi", "text": "…그래. 이건 네 싸움이다.\n나는 저 문 앞을 지키겠다. 아무도 못 들어오게."}],
	"shadow": [{"who": "{name}", "pose": "hero_angry", "text": "나리, 저 사람의 패거리를 막아 주세요.\n아버지는… 제가 되찾을 거예요."},
		{"who": "윤도결", "pose": "jongsagwan", "text": "가라. 포졸들과 내가 뒤를 막는다.\n허 의원은 네가 데려와라."}],
}

func start_battle(enemy_id: String, on_win: Callable, opts := {}) -> void:
	var comp := companion()
	if enemy_id == "shadow_s":
		comp = ""   # 화엄골 대숲의 한밤: 주인공 혼자 검은 사내와 맞선다 (동행 대사 없음)
	if comp != "" and not opts.get("comp_done", false) and not opts.has("me_name") and not quiet_ally():
		var c: Dictionary = StoryData.COMPANION.get(comp, {})
		opts = opts.duplicate(); opts["comp_done"] = true
		var me := "{alias}" if disguised() else "{name}"
		var pre: Array = FINAL_COMP.get(enemy_id, [])
		if pre.is_empty() and c.has("pre"):
			pre = [{"who": me, "pic": hero_pose(), "text": comp_line("pre_me")}, {"who": c["name"], "pic": comp_pic(), "text": comp_line("pre")}]
		# 대장(보스·중간보스)과 싸운 뒤에는 동행의 한마디를 띄우지 않는다 (싸우기 전 대사는 그대로)
		var is_boss: bool = GameData.ENEMIES.get(enemy_id, {}).get("boss", false)
		var post_line: String = comp_line("post") if not (is_boss or FINAL_COMP.has(enemy_id) or enemy_id in ["jeong_shadow1", "jeong_shadow"]) else ""
		var win := on_win
		if post_line != "":
			win = func(): dialog_chain([{"who": c["name"], "pic": comp_pic(), "text": post_line}], on_win)
		dialog_chain(pre, func(): start_battle(enemy_id, win, opts))
		return
	if goods_count("charm") > 0:
		use_goods("charm"); next_guard += 10
	if goods_count("pill") > 0:
		use_goods("pill"); next_energy += 1
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

## 쉼터 칸: 조선 땅에서는 주막(주모), 그 밖에서는 장소에 맞게
func rest_event(bg := "") -> Dictionary:
	var ev: Dictionary = GameData.REST.duplicate()
	if bg in ["deck", "deck_night", "sea", "port", "holland_port"]:
		ev["title"] = "선실"; ev.erase("pic")
		ev["text"] = "선실 해먹에 몸을 누이고 한숨 푹 잤다.\n뱃사람이 끓여 준 수프에 기운이 돈다.\n\n(체력 회복 +20)"
	elif chapter == 7 or bg in ["yanjing"]:
		ev["title"] = "객잔"; ev.erase("pic")
		ev["text"] = "길가 객잔에서 하룻밤 묵어 갔다.\n낯선 땅의 따뜻한 국수에 기운이 돈다.\n\n(체력 회복 +20)"
	elif chapter == 8 or bg in ["holland"]:
		ev["title"] = "여관"; ev.erase("pic")
		ev["text"] = "풍차 옆 작은 여관에서 하룻밤 묵어 갔다.\n따끈한 빵과 수프에 기운이 돈다.\n\n(체력 회복 +20)"
	elif bg in ["castle", "vault", "corridor", "cheonsugak"]:
		ev["title"] = "숨 고르기"; ev.erase("pic")
		ev["text"] = "빈 곳간 구석에 몸을 숨기고 잠시 숨을 골랐다.\n\n(체력 회복 +20)"
	return ev

## 맵 사건 고르기: 다래가 곁에 없으면 다래가 나오는 사건은 빼고
func pick_event(pool: Array) -> Dictionary:
	if companion() == "darae":
		return pool.pick_random()
	var ok: Array = pool.filter(func(ev): return ev.get("pic", "") != "friend" and not str(ev.get("text", "")).contains("다래"))
	return (ok if not ok.is_empty() else pool).pick_random()

func start_voyage(cfg: Dictionary, on_done: Callable, restore := {}) -> void:
	world_board = board
	sub_stage = cfg
	voyage_done = on_done
	var s := StageScreen.new()
	s.restore = restore
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
				show_records(func():
					phase = "title"
					show_title()))
		else:
			_next_chapter())

## 엔딩 기록 화면
const CARD_TITLE := {"jumeok": "붓끝이 매서운 의원", "baldda": "붓끝이 매서운 의원", "gyeot": "붓끝이 매서운 의원", "nalchi": "붓끝이 매서운 의원",
	"pum": "철벽 상소의 의원", "gochu": "꾀 많은 의원"}

## 칭호 목록: 위에 있을수록 먼저 붙는 칭호. 한 번 끝낼 때 조건이 맞는 칭호는 모두 모음에 들어간다.
const TITLES := [
	["불패의 어의", "한 번도 쓰러지지 않고 끝내기"],
	["꺾이지 않는 의원", "쓰러진 전투 1~3번으로 끝내기"],
	["칠전팔기 의원", "쓰러진 전투 10번 이상으로 끝내기"],
	["내의원 탕약 장인", "탕약 30첩 이상 달이기"],
	["진한 탕약의 대가", "진한 탕약을 묽은 탕약보다 많이 달이기"],
	["팔도 약초꾼", "약초 150뿌리 이상 모으기"],
	["한양 제일 알뜰 의원", "모은 엽전의 절반 이상 남기기"],
	["통 큰 의원", "모은 엽전의 90% 이상 쓰기"],
	["붓끝이 매서운 의원", "공격 상소를 가장 많이 올리기"],
	["철벽 상소의 의원", "품밟기를 가장 많이 올리기"],
	["꾀 많은 의원", "고춧가루를 가장 많이 올리기"],
	["한 방의 의원", "첫 차례 안에 적을 쓰러뜨린 전투 30번"],
	["상처 하나 없이", "체력이 하나도 안 깎인 채 이긴 전투 20번"],
	["아슬아슬한 의원", "체력 5 이하로 버티다 이긴 전투 10번"],
	["대장 사냥꾼", "한 판에서 대장전을 한 번도 지지 않고 모두 이기기"],
	["골목의 해결사", "일반 적 50명 쓰러뜨리기 (대장 제외)"],
	["한양 왈패들의 악몽", "일반 적 120명 쓰러뜨리기 (대장 제외)"],
	["팔도에 이름난 주먹 의원", "일반 적 200명 쓰러뜨리기 (대장 제외)"],
	["발 빠른 의원", "남은 시각 보너스를 300냥 이상 받기"],
	["들키지 않는 그림자", "감시꾼 눈에 한 번도 들키지 않고 끝내기"],
	["참견쟁이 의원", "동네 사람 말 거는 칸 40번 밟기"],
	["느긋한 여행자", "플레이 시간 10시간 넘기기"],
	["돌아온 의원", "완주 3번"],
	["서휘의 반려", "서휘와 혼례를 올리기"],
	["윤도결의 반려", "윤도결과 혼례를 올리기"],
	["두 길을 걸은 의원", "서휘 결말과 윤도결 결말을 둘 다 보기 (여러 판에 걸쳐 모음)"],
	["한양의 의원", "다른 칭호 없이 끝내기"],
	["한양 숨바꼭질의 주인", "다른 칭호를 모두 모으기 (「한양의 의원」 제외)"],
]

func _title_ok(name: String) -> bool:
	var lost := int(stats.get("losses", 0))
	var bs := int(stats.get("brew_small", 0)); var bb := int(stats.get("brew_big", 0))
	var cin := int(stats.get("coin_in", 0)); var cout := int(stats.get("coin_out", 0))
	var top := _top_card()
	match name:
		"불패의 어의": return lost == 0
		"꺾이지 않는 의원": return lost >= 1 and lost <= 3
		"칠전팔기 의원": return lost >= 10
		"내의원 탕약 장인": return bs + bb >= 30
		"진한 탕약의 대가": return bb > bs and bb > 0
		"팔도 약초꾼": return int(stats.get("herbs", 0)) >= 150
		"한양 제일 알뜰 의원": return cin > 0 and cout * 2 <= cin
		"통 큰 의원": return cin > 0 and cout * 10 >= cin * 9
		"붓끝이 매서운 의원", "철벽 상소의 의원", "꾀 많은 의원": return top != "" and CARD_TITLE.get(top, "") == name
		"한 방의 의원": return int(stats.get("one_turn", 0)) >= 30
		"상처 하나 없이": return int(stats.get("no_dmg", 0)) >= 20
		"아슬아슬한 의원": return int(stats.get("close_call", 0)) >= 10
		"대장 사냥꾼": return int(stats.get("boss_losses", 0)) == 0
		"골목의 해결사": return int(stats.get("kills", 0)) >= 50
		"한양 왈패들의 악몽": return int(stats.get("kills", 0)) >= 120
		"팔도에 이름난 주먹 의원": return int(stats.get("kills", 0)) >= 200
		"발 빠른 의원": return int(stats.get("time_bonus", 0)) >= 300
		"들키지 않는 그림자": return int(stats.get("spotted", 0)) == 0
		"참견쟁이 의원": return int(stats.get("talks", 0)) >= 40
		"느긋한 여행자": return play_sec >= 36000.0
		"돌아온 의원": return int(title_book().get("_clears", 0)) + 1 >= 3
		"두 길을 걸은 의원":
			var bk := title_book()
			var ends: Array = bk.get("_endings", [])
			var me := "dogyeol" if flags.has("wed_dogyeol") else "seohwi"
			return ("seohwi" in ends or bk.has("서휘의 반려") or me == "seohwi") and ("dogyeol" in ends or bk.has("윤도결의 반려") or me == "dogyeol")
		"서휘의 반려": return not flags.has("wed_dogyeol")
		"윤도결의 반려": return flags.has("wed_dogyeol")
	return false

func earned_titles() -> Array:
	var out: Array = []
	var spouse: Array = []
	for t in TITLES:
		if not t[0] in ["한양의 의원", "한양 숨바꼭질의 주인"] and _title_ok(t[0]):
			(spouse if t[0].ends_with("의 반려") else out).append(t[0])
	if out.is_empty():
		out.append("한양의 의원")
	# 최종 칭호: 이번 판 칭호와 칭호 모음을 합쳐 다른 칭호를 모두 모았으면
	var book := title_book()
	var all_ok := true
	for t in TITLES:
		if not t[0] in ["한양 숨바꼭질의 주인", "한양의 의원"] and not (book.has(t[0]) or t[0] in out or t[0] in spouse):
			all_ok = false
	if all_ok:
		out.push_front("한양 숨바꼭질의 주인")
	return out + spouse   # 반려 칭호는 대표 칭호가 되지 않고 모음에만 들어간다

func ending_title() -> String:
	return earned_titles()[0]

## 칭호 모음 (세이브와 상관없이 이 기기에 모두 모인다)
const TITLE_BOOK := "user://titles.json"

func title_book() -> Dictionary:
	if not FileAccess.file_exists(TITLE_BOOK):
		return {}
	var d = JSON.parse_string(FileAccess.get_file_as_string(TITLE_BOOK))
	return d if d is Dictionary else {}

func _record_titles() -> Array:
	var book := title_book()
	var fresh: Array = []
	var today := Time.get_date_string_from_system()
	for t in earned_titles():
		if not book.has(t):
			book[t] = {"date": today, "hero": hero_name}
			fresh.append(t)
	book["_clears"] = int(book.get("_clears", 0)) + 1
	var ends: Array = book.get("_endings", [])
	var me := "dogyeol" if flags.has("wed_dogyeol") else "seohwi"
	if not me in ends:
		ends.append(me)
	book["_endings"] = ends
	var f := FileAccess.open(TITLE_BOOK, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(book))
	return fresh

func open_title_book() -> void:
	var o := _overlay("칭호 모음")
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	var book := title_book()
	var got := 0
	for t in TITLES:
		if book.has(t[0]):
			got += 1
	vb.add_child(_note("모은 칭호 %d / %d  ·  완주 %d번" % [got, TITLES.size(), int(book.get("_clears", 0))], RED))
	var sc := ScrollContainer.new()
	sc.custom_minimum_size = Vector2(600, 860)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.scroll_deadzone = 8
	var list := VBoxContainer.new()
	list.mouse_filter = Control.MOUSE_FILTER_PASS
	list.add_theme_constant_override("separation", 10)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(list)
	vb.add_child(sc)
	for t in TITLES:
		var has: bool = book.has(t[0])
		var row := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("f3e6c8") if has else Color("cfccc6")
		sb.border_color = Color("b0883a") if has else Color("a3a09a")
		sb.set_border_width_all(3); sb.set_corner_radius_all(10); sb.set_content_margin_all(14)
		row.add_theme_stylebox_override("panel", sb)
		row.mouse_filter = Control.MOUSE_FILTER_PASS   # 칸 위에서 끌어도 목록이 내려가게
		var col := VBoxContainer.new()
		col.mouse_filter = Control.MOUSE_FILTER_PASS
		if has:
			col.add_child(make_label("「%s」" % t[0], 30, RED))
		# 못 얻은 칭호는 이름 없이 조건만, 회색으로
		var sub := "%s\n%s · %s 때 얻음" % [t[1], str(book[t[0]].get("date", "")), str(book[t[0]].get("hero", ""))] if has else "조건: %s" % t[1]
		var dl := make_label(sub, 22, INK_SOFT if has else Color("7d7a75"))
		dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(dl)
		row.add_child(col)
		list.add_child(row)
	var close := make_button("닫기", 30)
	close.custom_minimum_size = Vector2(300, 84)
	close.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close.pressed.connect(func(): layer.queue_free())
	vb.add_child(close)

func _top_card() -> String:
	var cu: Dictionary = stats.get("cards", {})
	var best := ""; var n := 0
	for k in cu:
		if int(cu[k]) > n:
			n = int(cu[k]); best = k
	return best

func show_records(cb: Callable) -> void:
	var top := _top_card()
	var cu: Dictionary = stats.get("cards", {})
	var card_txt := "%s (%d회)" % [GameData.CARDS[top]["name"], int(cu[top])] if top != "" else "—"
	var t := "━━ 한양 숨바꼭질 · 완 ━━\n%s\n\n" % hero_name
	t += "플레이 시간   %s\n" % fmt_time(play_sec)
	t += "달인 탕약   %d첩\n" % (int(stats.get("brew_small", 0)) + int(stats.get("brew_big", 0)))
	t += "  묽은 탕약 %d첩  ·  진한 탕약 %d첩\n" % [int(stats.get("brew_small", 0)), int(stats.get("brew_big", 0))]
	t += "모은 약초   %d뿌리\n" % int(stats.get("herbs", 0))
	t += "모은 엽전   %d냥\n" % int(stats.get("coin_in", 0))
	t += "쓴 엽전   %d냥\n" % int(stats.get("coin_out", 0))
	t += "가장 많이 올린 상소   %s\n" % card_txt
	t += "이긴 전투   %d번 · 쓰러진 전투 %d번" % [int(stats.get("wins", 0)), int(stats.get("losses", 0))]
	_record_titles()   # 칭호 모음은 뺐지만, 어떤 엔딩을 봤는지 기록은 남긴다(처음 화면 그림에 씀)
	popup(t, "처음 화면으로", cb, "여정의 기록", "", "", true)

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
		stat_add("losses")
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
	const PAIRS := {"은": ["은", "는"], "이": ["이", "가"], "을": ["을", "를"], "과": ["과", "와"], "아": ["아", "야"], "이다": ["이다", "다"], "예요": ["이에요", "예요"]}
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
		# 폰 자판에서 마지막 글자가 아직 조합 중이어도 입력을 확정시킨 뒤 읽는다
		edit.release_focus(); edit2.release_focus()
		DisplayServer.virtual_keyboard_hide()
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

## 지금 장에 맞는 주인공 전신 그림 (남장·의녀·어른·평상복)
## 지금 남장 중인가 (마지막 장도 화란에 있는 동안 — 마지막 왕진 길·떠나는 항구 — 은 아직 남장)
func disguised() -> bool:
	# 5장도 궁궐에 들어가기 전(한양으로 돌아가는 길·경복궁 가는 길)까지는 남장
	return chapter in DISGUISED or (chapter == 9 and not grown()) or (chapter == 5 and stage_idx == 0)

func hero_pose() -> String:
	if disguised():
		return "hero_disguise"
	if grown():
		return "hero_adult"
	if chapter in DISGUISED:
		return "hero_disguise"
	return "hero"   # 5장은 illust()가 의녀 옷 그림으로 바꿔 준다

## 한양 땅에 다시 발을 디딘 뒤(마지막 장 도착 장면부터) 어른 모습
func grown() -> bool:
	return chapter >= 10 or (chapter == 9 and (stage_idx >= 4 or flags.has("grown")))   # 9장: 약초 들판·왕진·항구·만리길 뒤

func token_name() -> String:
	return "token_disguise" if disguised() else "token_hero"

func face_name() -> String:
	if disguised():
		return "face_token"
	return "face_adult" if grown() else "face_hero"   # 한양에 돌아온 뒤에는 어른 얼굴

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
	if line.has("flag"): flags[line["flag"]] = true
	if line.has("coin") or line.has("potion") or line.has("maxhp"):
		sfx("good")

## 맵 대화칸: 이야기 대화창(이름 바로 아래 4줄, 화면 눌러 넘김) + 받은 것은 따로 한 줄
func talk_chain(talk: Dictionary, cb: Callable) -> void:
	var lines := [{"who": talk["who"], "pic": talk.get("pic", ""), "text": talk["text"]}]
	var got := []
	if talk.has("coin"): got.append("엽전 +%d냥" % talk["coin"])
	if talk.has("potion"): got.append("약병 +%d" % talk["potion"])
	if not got.is_empty():
		var r := {"who": "", "text": "(" + " · ".join(got) + ")"}
		for k in ["coin", "potion"]:
			if talk.has(k): r[k] = talk[k]
		lines.append(r)
	dialog_chain(lines, cb)

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
	if not line.has("choices") and not line.get("_paged", false) and not line["text"].begins_with("【목표】"):
		var pages: Array = paginate(smart_breaks(fmt(line["text"]), 30, 540.0), 30, 530.0, 4)
		if pages.size() > 1:
			lines = lines.duplicate()
			lines.remove_at(i)
			var parts: Array = split_line(line, pages)
			for k in parts.size():
				lines.insert(i + k, parts[k])
			line = lines[i]
	var nbg: String = line.get("bg", bg)
	if line.has("bg"):
		last_dialog_bg = line["bg"]   # 싸우기 직전 대화 장소 = 전투 배경
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
		if line["text"].begins_with("【목표】"):
			last_goal = line["text"].trim_prefix("【목표】").strip_edges()
		popup(line["text"], "다음", next, fmt(line.get("who", "")), line.get("pic", line.get("pose", "")), nbg,
			line["text"].begins_with("【목표】"))

func popup_choices(text: String, choices: Array, cb: Callable, title := "", pic := "", bg := "") -> void:
	var o := _overlay(title, bg, pic, true)
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	var l := make_label(smart_breaks(fmt(text), 30, 520.0), 30, GOAL_BROWN if text.begins_with("【목표】") else INK)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.custom_minimum_size = Vector2(540, 0)
	l.add_theme_constant_override("line_spacing", 8)
	if pic != "":   # 고정 크기 창: 남는 칸은 글이 채우고 글은 세로 가운데
		l.size_flags_vertical = Control.SIZE_EXPAND_FILL
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
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
	"seohwi": "seohwi_calm", "seohwi_battle": "seohwi", "seohwi_dutch": "seohwi_dutch", "seohwi_sad": "seohwi_calm", "seohwi_dutch_sad": "seohwi_dutch", "seohwi_return_sad": "seohwi_return", "jongsagwan": "dogyeol", "jongsagwan_battle": "dogyeol", "jongsagwan_blush": "dogyeol",
	"heo": "heo", "heo_ill": "heo", "pojol_battle": "pojol", "friend_worried": "friend", "darae_court": "friend", "baegun_boss": "baegun_boss", "addict": "addict", "bamtol_happy": "bamtol", "bamtol_scared": "bamtol", "shadow": "shadow", "jumo": "jumo", "yakjae": "yakjae"}

## 진짜 데포르메 그림만 (없으면 null)
## 마지막 장: 한양으로 돌아온 서휘는 새 차림으로
func _ret(name: String) -> String:
	if chapter == 8 and name in ["seohwi", "seohwi_battle"]:
		return "seohwi_dutch"   # 화란의 서휘는 화란 옷차림
	if chapter == 8 and name == "seohwi_sad":
		return "seohwi_dutch_sad"
	if chapter >= 9 and name == "seohwi_sad":
		return "seohwi_return_sad"
	if chapter >= 9 and name in ["seohwi", "seohwi_battle"]:
		return "seohwi_return"
	if chapter >= 9 and name == "friend":
		return "darae_adult"   # 돌아온 뒤의 다래는 어른 모습
	if grown() and name in ["hero", "hero_sad"]:
		return "hero_adult"   # 돌아온 뒤의 주인공은 어른 모습 (길막 대사 등에서 어린 그림이 섞이지 않게)
	if grown() and name in ["hero_angry", "hero_surprised"]:
		return "hero_adult_tense"
	if chapter >= 9 and not grown() and name.begins_with("hero_adult"):   # 돌아오는 뱃길까지는 패랭이 벗은 남장 옷 그대로
		return "hero_disguise_hair_surprised" if name == "hero_adult_tense" else "hero_disguise_hair"
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

## 문장 끝 줄바꿈을 넣되, 그러면 너무 길어질 때(max_lines 초과)는 넣지 않는다
func smart_breaks(t: String, fsize: int, width: float, max_lines := 4) -> String:
	var broken := sentence_breaks(t)
	if broken == t:
		return t
	var font: Font = ThemeDB.fallback_font   # 설정에서 고른 글꼴
	var lines := 0
	for para in broken.split("\n"):
		var w: float = font.get_string_size(para, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize).x
		lines += max(1, int(ceil(w / max(1.0, width))))
	return broken if lines <= max_lines else t

## 대화 그림 키 비율: 남자 어른 1.0 기준, 주인공·여자는 조금 작게, 아이는 더 작게
func fig_scale(name: String) -> float:
	if name == "dutch_child_sick":
		return 0.38   # 주저앉은 아이 (아래 아이 크기보다 먼저 봐야 함)
	if name.begins_with("dutch_child") or name.begins_with("island_child") or name == "children":
		return 0.66
	if name.begins_with("hero_adult"):
		return 0.92
	if name.begins_with("hero_disguise") and not name.begins_with("hero_disguise_hair"):
		return 0.88   # 남장 주인공 (패랭이 포함 원래 크기)
	if name.begins_with("hero_court"):
		return 0.82   # 의녀·어의 옷 주인공은 평상복 주인공과 같은 크기
	if name.begins_with("hero"):
		return 0.82   # 여자 옷·머리 푼 모습은 패랭이가 없으니 남장 주인공 몸 크기에 맞춤
	if name == "darae_prison":
		return 0.56   # 무릎 꿇은 모습
	if name == "daebi_ill":
		return 0.6    # 보료에 기대 앉은 모습
	if name == "daebi_smile":
		return 0.72
	# 어른 다래: 그림마다 얼굴 크기가 달라서, 서서 우는 모습 얼굴 크기에 맞춤
	if name == "darae_adult_cry": return 0.9
	if name == "darae_adult_court_cry": return 0.9
	if name == "darae_adult": return 0.9
	if name == "darae_casual": return 0.9
	if name == "darae_court": return 0.88
	if name.begins_with("friend") or name.begins_with("darae") or name == "jumo":
		return 0.86
	if name.begins_with("dutch_baker"): return 0.84
	if name.begins_with("dutch_miller"): return 0.8
	if name == "cheong_merchant": return 0.9   # 가짜 인삼 장수: 팔을 벌린 넓은 자세라 줄임
	if name.begins_with("maria_healer"): return 0.8   # 카나리아 마리아 할머니: 등이 굽은 작은 할머니
	if name == "yanjing_elder": return 0.82   # 연경 노인: 등이 굽은 할아버지
	if name == "masked_henchman": return 0.78   # 복면 하수인: 넓게 선 자세라 줄임
	if name == "pojol_battle": return 0.76   # 창 들이미는 포졸: 낮게 웅크린 자세라 줄임
	if name == "pojol": return 1.0
	if name == "seohwi_dutch_sick": return 0.72   # 의자에 앉은 모습
	if name == "dutch_fisherman": return 0.84
	if name == "dutch_woman": return 0.8
	if name == "dutch_sick_man":
		return 0.84   # 화란 사람들: 주인공과 어울리는 크기로
	if name == "dutch_sick_woman":
		return 0.8
	if name == "dutch_child_sick":
		return 0.5    # 주저앉은 아이
	if name == "rat":
		return 0.5
	if name == "addict" or name == "addict_well":
		return 0.85   # 중독된 사내: 꾸부정하게 서 있어 반듯한 어른보다 작게
	if name == "gatekeeper":
		return 0.95   # 성 문지기(흑룡파 왈패): 덩치 큰 사내
	if name == "haejeok_young":
		return 0.78   # 해적 졸개: 전투 화면과 비슷한 크기로
	if name == "baegun_exile_cry":
		return 0.8    # 허리 숙여 책 내미는 모습: 얼굴을 바구니 든 모습과 맞춤
	if name.begins_with("baegun_exile"):
		return 0.95
	if name in ["seohwi", "seohwi_battle", "seohwi_return", "seohwi_sad", "seohwi_return_sad"]:
		return 0.94   # 모자 없는 서휘: 윤도결(갓 포함)보다 조금 작게
	if name == "walpae":
		return 0.92
	if name == "baegun":
		return 0.76   # 상냥한 백운: 바위에 앉은 모습
	return 1.0

## 궁에 있는 동안(제5장)은 주인공이 궁 옷차림 그림으로 (그림이 있을 때만)
const COURT_CHAPTERS := [5]

## 의녀 옷은 임금께 어의 소임을 받은 뒤부터 (5장 처음 한양 가는 길·궁 가는 길은 평소 옷)
func in_court() -> bool:
	return chapter in COURT_CHAPTERS and (flags.has("court") or stage_idx >= 2)

func illust(name: String) -> Texture2D:
	name = _ret(name)
	if name.begins_with("hero_girl"):   # 5장이라도 의녀복 대신 소녀 평상복 그림 그대로 (예: 허 의원 임종·빈소)
		name = "hero" + name.substr(9)
	elif in_court() and (name == "hero" or name.begins_with("hero_")) and not name.begins_with("hero_disguise") and not name.begins_with("hero_adult"):
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
const CHAR_FALLBACK := {"hero_disguise_hair": "hero_disguise_sad", "hero_adult_tense": "hero_adult"}

## 인물이 화면 가득 차서 잘리는 그림: 한 겹 작게 줄여 가운데에 얹고, 뒤는 같은 그림을 흐리게 깐다
## 화면이 그림보다 길쭉해 양옆이 잘릴 때 어느 쪽을 보여 줄지 (0 = 왼쪽 끝, 0.5 = 가운데)
const BG_ALIGN := {}

func align_cover(name: String, under: TextureRect) -> void:
	if not BG_ALIGN.has(name) or under.texture == null:
		return
	under.stretch_mode = TextureRect.STRETCH_SCALE
	var fit := func():
		var W: float = under.get_parent().size.x
		var H: float = under.get_parent().size.y
		var tw: float = under.texture.get_width()
		var th: float = under.texture.get_height()
		var k: float = max(W / tw, H / th)
		under.set_anchors_preset(Control.PRESET_TOP_LEFT)
		under.size = Vector2(tw * k, th * k)
		under.position = Vector2((W - tw * k) * float(BG_ALIGN[name]), (H - th * k) * 0.5)
	fit.call_deferred()

const BG_SHRINK := {}

func shrink_overlay(parent: Control, name: String, under: TextureRect) -> void:
	var old := parent.get_node_or_null("ShrinkPic")
	if old:
		old.queue_free()
	under.self_modulate = Color.WHITE
	if not BG_SHRINK.has(name) or under.texture == null:
		return
	var k: float = BG_SHRINK[name]
	under.self_modulate = Color(0.45, 0.4, 0.38)
	var t := TextureRect.new()
	t.name = "ShrinkPic"
	t.texture = under.texture
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.anchor_left = (1.0 - k) / 2.0; t.anchor_right = 1.0 - (1.0 - k) / 2.0
	t.anchor_top = 1.0 - k - 0.03; t.anchor_bottom = 1.0 - 0.03   # 아래로 붙여 제목 글씨와 얼굴이 안 겹치게
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(t)
	parent.move_child(t, under.get_index() + 1)

const BG_FALLBACK := {"gyeongbok_road": "jangteo", "new_home": "mountain", "dutch_classroom": "dutch_child_room", "stream_day": "jangteo", "grave_path": "grave", "yakbang_calm": "yakbang", "palace_night": "palace", "naeuiwon": "yakbang", "mapo_warehouse": "den",
	"flash_plague": "village_outside", "flash_carried": "mountain", "flash_seohwi_parents": "island", "flash_dogyeol": "alley"}

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
	# 단계가 오를수록 종이가 연한 미색에서 짙은 황토색으로 (1~5단계)
	var paper: String = ["sangso", "sangso_gold", "sangso_red", "sangso_sky", "sangso_5"][clampi(int(entry["lv"]), 1, 5) - 1]
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
## 인물이 서는 겹창 대화창의 고정 크기
const OVERLAY_TALK_W := 660
const OVERLAY_TALK_H := 480   # 제목+글 4줄+버튼이 딱 들어가는 높이
const OVERLAY_TALK_H_TAP := 372   # 버튼 없는 이어지는 대화: 이름+글 4줄이 딱 들어가는 높이

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
	var pt: Texture2D = illust(pic) if pic != "" and title != "전투" and not (bg in ["wedding", "family", "wedding_dogyeol", "family_dogyeol"]) else null
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
	if pt:   # 전신 인물이 나올 때만 대화창을 아래로, 아니면 가운데 (싸우기 직전 창은 그림 없이 가운데)
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
	if fig:   # 인물이 서는 대화창은 글 길이와 상관없이 크기 고정 (창이 들쑥날쑥하면 인물 키도 따라 바뀌므로)
		panel.custom_minimum_size = Vector2(OVERLAY_TALK_W, OVERLAY_TALK_H)
	center.add_child(panel)
	if fig:
		var fsc: float = fig_scale(pic)
		var fit := func():
			if is_instance_valid(fig) and is_instance_valid(panel):
				# 발끝은 대화창 위, 키는 인물마다 (여자·아이는 조금 작게)
				var bottom_y: float = panel.global_position.y - 6   # 발끝이 대화창 테두리에 가리지 않게
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
	var l := make_label(smart_breaks(fmt(text), 30, 520.0), 30, GOAL_BROWN if text.begins_with("【목표】") else INK)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.custom_minimum_size = Vector2(540, 0)
	l.add_theme_constant_override("line_spacing", 8)
	if pic != "" and button_text == "다음":   # 이어지는 대화: 이름 바로 아래부터 글 4줄, 창은 한 칸 낮게
		vb.get_parent().custom_minimum_size.y = OVERLAY_TALK_H_TAP
		vb.add_theme_constant_override("separation", 6)
	elif pic != "":   # 고정 크기 창: 남는 칸은 글이 채우고 글은 세로 가운데
		l.size_flags_vertical = Control.SIZE_EXPAND_FILL
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vb.add_child(l)
	if button_text == "다음":   # 이어지는 대화: 버튼 없이 화면 아무 데나 누르면 다음, 창 모서리에 붉은 ▼
		var panel: Control = vb.get_parent()
		var holder := Control.new()
		holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(holder)
		var arw := make_label("▼", 32, RED)
		arw.mouse_filter = Control.MOUSE_FILTER_IGNORE
		arw.anchor_left = 1.0; arw.anchor_right = 1.0; arw.anchor_top = 1.0; arw.anchor_bottom = 1.0
		arw.offset_left = -12; arw.offset_right = 20; arw.offset_top = -42; arw.offset_bottom = -8   # 붉은 안쪽 테두리 바로 안, 가장 구석
		holder.add_child(arw)
		var tap := Button.new()
		tap.name = "TapNext"
		tap.flat = true
		tap.focus_mode = Control.FOCUS_NONE
		tap.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var empty := StyleBoxEmpty.new()
		for st in ["normal", "hover", "pressed", "focus", "disabled"]:
			tap.add_theme_stylebox_override(st, empty)
		layer.add_child(tap)
		var done := [false]
		tap.pressed.connect(func():
			if done[0]:
				return
			done[0] = true
			layer.queue_free()
			if cb.is_valid():
				cb.call())
		return
	var b := make_button(button_text)
	b.custom_minimum_size = Vector2(0, 96)
	vb.add_child(b)
	b.pressed.connect(func():
		layer.queue_free()
		if cb.is_valid():
			cb.call())

## 긴 글을 창에 들어가는 줄 수(max_lines)씩 나눈다. 다 들어가면 그대로 한 장.
## 문단(\n)째로 넣다가 넘치면 다음 장으로, 한 문단이 너무 길면 줄 단위로 자른다.
func paginate(t: String, fsize: int, width: float, max_lines := 4) -> Array:
	var font: Font = ThemeDB.fallback_font
	var wrap := func(para: String) -> Array:
		var out := []
		var cur := ""
		for word in para.split(" "):
			var cand: String = word if cur == "" else cur + " " + word
			if cur == "" or font.get_string_size(cand, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize).x <= width:
				cur = cand
			else:
				out.append(cur)
				cur = word
		out.append(cur)
		return out
	var paras := []
	var total := 0
	for para in t.split("\n"):
		var wl: Array = wrap.call(para)
		paras.append(wl)
		total += wl.size()
	if total <= max_lines:
		return [t]
	var pages := []
	var cur_lines := []
	var cur_paras := []
	for wl in paras:
		if cur_lines.size() + wl.size() <= max_lines:
			cur_lines.append_array(wl)
			cur_paras.append(" ".join(wl))
			continue
		if not cur_paras.is_empty():
			pages.append("\n".join(cur_paras))
			cur_lines = []; cur_paras = []
		if wl.size() <= max_lines:
			cur_lines.append_array(wl)
			cur_paras.append(" ".join(wl))
		else:   # 한 문단이 창보다 길면 줄 단위로 나눈다
			var k := 0
			while k < wl.size():
				var chunk: Array = wl.slice(k, k + max_lines)
				if chunk.size() == max_lines or k + max_lines < wl.size():
					pages.append(" ".join(chunk))
				else:
					cur_lines = chunk.duplicate(); cur_paras = [" ".join(chunk)]
				k += max_lines
	if not cur_paras.is_empty():
		pages.append("\n".join(cur_paras))
	return pages

## 이야기 한 줄을 여러 장으로 나눌 때: 첫 장은 배경·음악·인물, 마지막 장은 보상 등 효과
func split_line(line: Dictionary, pages: Array) -> Array:
	var out := []
	for i in pages.size():
		var d: Dictionary
		if i == pages.size() - 1:
			d = line.duplicate()
			if i > 0:
				for k in ["bg", "music", "label"]:
					d.erase(k)
		else:
			d = {}
			for k in ["who", "pic", "pose", "if", "ifnot"] + (["bg", "music", "label"] if i == 0 else []):
				if line.has(k):
					d[k] = line[k]
		d["text"] = pages[i]
		d["_paged"] = true
		out.append(d)
	return out

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

# ── 보따리: 같은 상소 두 장을 엽전 내고 합치기 ──────────────
const UPGRADE_COST := [0, 5, 10, 15, 20]   # ★1→★2 5냥 … ★4→★5 20냥

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
		var b := make_button("%s 달이기 (체력 %d 회복)\n약초 %d개 사용 · %d냥" % [br["name"], br["heal"], need, br["cost"]], 26)
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
			stat_add("brew_small" if br["key"] == "small" else "brew_big")
			if br["key"] == "small":
				potions_small += 1
			else:
				potions += 1
			sfx("potion")
			msg.text = "보글보글… %s 한 병을 달였습니다!" % br["name"]
			msg.add_theme_color_override("font_color", INK_SOFT)
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
	var o := _overlay("상소 합치기")
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
		info.text = "상소 %d장 · 같은 상소(같은 ★) 두 장을 누르면\n엽전을 내고 한 장으로 합쳐집니다\n★2 5냥 · ★3 10냥 · ★4 15냥 · ★5 20냥" % deck.size()
		if state["msg"] != "":
			info.text = state["msg"]
		var sel: int = state["sel"]
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
		state["msg"] = "이미 가장 강한 상소입니다 (★5)"
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

## 보따리장수가 파는 물건
const SHOP_GOODS := [
	{"id": "potion_small", "name": "묽은 탕약", "price": 8, "icon": "potion", "desc": "약병 1개\n체력 회복 +20"},
	{"id": "potion_big", "name": "진한 탕약", "price": 14, "icon": "potion", "desc": "약병 1개\n체력 회복 +40"},
	{"id": "shoes", "name": "새 짚신", "price": 16, "icon": "step", "desc": "다음 맵 남은 시각 +3"},
	{"id": "smoke", "name": "연막 주머니", "price": 18, "icon": "gochu", "desc": "길막이 하나를\n싸우지 않고 지나감"},
	{"id": "hat", "name": "삿갓 그늘", "price": 15, "icon": "debuff", "desc": "감시꾼에게\n한 번 들켜도 무사"},
	{"id": "charm", "name": "호신 부적", "price": 17, "icon": "buff", "desc": "다음 전투 시작 때\n막기 10"},
	{"id": "pill", "name": "각성 환", "price": 19, "icon": "yak", "desc": "다음 전투 첫 차례\n기력 +1"},
	{"id": "ginseng", "name": "백 년 묵은 산삼", "price": 25, "icon": "herb", "desc": "최대 체력 +5\n(장마다 1개)"},
]
var goods := {}   # 가지고 있는 물건 개수

func goods_count(id: String) -> int:
	return int(goods.get(id, 0))

func use_goods(id: String) -> void:
	goods[id] = maxi(0, goods_count(id) - 1)

## 보따리: 보따리장수에게서 산 물건 보기
func show_goods(cb := Callable()) -> void:
	var o := _overlay("보따리")
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	var cp := coin_plaque()
	vb.add_child(cp[0])
	vb.add_child(_note("탕약은 [마시기]로 바로 마실 수 있고, 다른 물건은 필요할 때 저절로 쓰입니다.\n체력 %d/%d" % [hp, max_hp]))
	var any := false
	for g in SHOP_GOODS:
		if g["id"] == "ginseng":
			continue   # 인삼은 사는 즉시 먹음
		var n := goods_count(g["id"])
		if g["id"] == "potion_small":
			n = potions_small   # 약탕관에서 달인 것·이야기에서 받은 것까지 모두
		elif g["id"] == "potion_big":
			n = potions
		var pc := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("f3e6c8") if n > 0 else Color("d8d2c6"); sb.border_color = Color("9a7a4a")
		sb.set_border_width_all(3); sb.set_corner_radius_all(10); sb.set_content_margin_all(10)
		pc.add_theme_stylebox_override("panel", sb)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		pc.add_child(row)
		var tex: Texture2D = load("res://assets/ui/tiles/deco_herb.png") if g["icon"] == "herb" else icon(g["icon"])
		row.add_child(tex_rect(tex, Vector2(52, 52)))
		var col := VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(col)
		col.add_child(make_label(g["name"], 26, RED if n > 0 else INK_SOFT))
		col.add_child(make_label(str(g["desc"]).replace("\n", " "), 20, INK_SOFT))
		row.add_child(make_label("×%d" % n, 32, INK if n > 0 else INK_SOFT))
		if g["id"] in ["potion_small", "potion_big"] and n > 0:
			var big: bool = g["id"] == "potion_big"
			var drink := make_button("마시기", 22)
			drink.custom_minimum_size = Vector2(104, 60)
			drink.disabled = hp >= max_hp
			row.add_child(drink)
			drink.pressed.connect(func():
				if big:
					potions -= 1
				else:
					potions_small -= 1
				hp = mini(max_hp, hp + (40 if big else 20))
				sfx("potion")
				if current and current.has_method("_update_hud"):
					current._update_hud()
				layer.queue_free()
				show_goods(cb))
		pc.modulate = Color.WHITE if n > 0 else Color(1, 1, 1, 0.6)
		vb.add_child(pc)
		if n > 0:
			any = true
	if not any:
		vb.add_child(_note("아직 가진 물건이 없습니다.\n보따리장수를 만나면 살 수 있어요."))
	var close := make_button("닫기", 30)
	close.custom_minimum_size = Vector2(0, 86)
	vb.add_child(close)
	close.pressed.connect(func():
		layer.queue_free()
		if cb.is_valid():
			cb.call())

func _goods_tile(g: Dictionary, msg: Label, refresh: Callable) -> Control:
	var pc := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("f3e6c8"); sb.border_color = Color("9a7a4a")
	sb.set_border_width_all(3); sb.set_corner_radius_all(10); sb.set_content_margin_all(10)
	pc.add_theme_stylebox_override("panel", sb)
	pc.custom_minimum_size = Vector2(300, 0)
	pc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	pc.add_child(v)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	v.add_child(top)
	var tex: Texture2D = load("res://assets/ui/tiles/deco_herb.png") if g["icon"] == "herb" else icon(g["icon"])
	top.add_child(tex_rect(tex, Vector2(48, 48)))
	var nm := make_label(g["name"], 28, RED)
	nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(nm)
	# 지금 가진 개수
	var have := make_label("", 21, INK_SOFT)
	var have_n := func() -> int:
		match g["id"]:
			"potion_small": return potions_small
			"potion_big": return potions
			"ginseng": return -1
		return goods_count(g["id"])
	var show_have := func():
		var n: int = have_n.call()
		have.text = "" if n < 0 else "(보유 %d)" % n
	show_have.call()
	top.add_child(have)
	var d := make_label(g["desc"], 21, INK_SOFT)
	d.custom_minimum_size = Vector2(0, 58)
	v.add_child(d)
	var buy := make_button("%d냥" % g["price"], 24)
	buy.custom_minimum_size = Vector2(0, 56)
	v.add_child(buy)
	if g["id"] == "ginseng" and int(flags.get("ginseng_ch", 0)) == chapter:
		buy.disabled = true; buy.text = "이번 장에 샀음"; pc.modulate = Color(0.8, 0.8, 0.8)
	buy.pressed.connect(func():
		if coins < int(g["price"]):
			msg.text = "엽전이 모자랍니다 (%s %d냥)" % [g["name"], g["price"]]
			msg.add_theme_color_override("font_color", RED)
			return
		if g["id"] == "ginseng" and int(flags.get("ginseng_ch", 0)) == chapter:
			msg.text = "백 년 묵은 산삼은 이번 장에 이미 샀습니다."
			msg.add_theme_color_override("font_color", RED)
			return
		coins -= int(g["price"])
		sfx("coin")
		if g["id"] == "potion_small":
			potions_small += 1
			msg.text = "묽은 탕약을 샀습니다! (묽은 %d · 진한 %d)" % [potions_small, potions]
		elif g["id"] == "potion_big":
			potions += 1
			msg.text = "진한 탕약을 샀습니다! (묽은 %d · 진한 %d)" % [potions_small, potions]
		elif g["id"] == "ginseng":
			flags["ginseng_ch"] = chapter
			max_hp += 5; hp += 5
			msg.text = "백 년 묵은 산삼을 달여 먹었다! 최대 체력 +5 (지금 %d)" % max_hp
		else:
			goods[g["id"]] = goods_count(g["id"]) + 1
			msg.text = "〈%s〉을(를) 샀습니다! (가진 것 %d개)" % [g["name"], goods_count(g["id"])]
		# 장수를 만날 때마다 물건마다 하나씩만
		show_have.call()
		buy.disabled = true
		buy.text = "샀음"
		pc.modulate = Color(0.8, 0.8, 0.8)
		msg.add_theme_color_override("font_color", INK_SOFT)
		refresh.call())
	return pc

func open_shop(cb: Callable, place := "장터", bg := "jangteo") -> void:
	var o := _overlay(place, bg)
	var layer: CanvasLayer = o[0]
	var vb: VBoxContainer = o[1]
	var cp := coin_plaque()
	vb.add_child(cp[0])
	var refresh: Callable = cp[1]
	var msg := _note("필요한 물건을 골라 보세요.")
	vb.add_child(msg)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	vb.add_child(grid)
	for g in SHOP_GOODS:
		grid.add_child(_goods_tile(g, msg, refresh))
	var leave := make_button("%s를 떠난다" % place if place == "장터" else "다시 길을 나선다", 28)
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
			app_active = false
			autosave("화면 전환 자동 저장")
		NOTIFICATION_APPLICATION_RESUMED, NOTIFICATION_APPLICATION_FOCUS_IN:
			app_active = true

func _save_path(slot: String) -> String:
	return "user://save_%s.json" % slot

func snapshot() -> Dictionary:
	var d := {"ver": 2, "phase": phase, "stage_idx": stage_idx, "hero_name": hero_name, "alias_name": alias_name, "max_hp": max_hp, "hp": hp,
		"coins": coins, "potions": potions, "potions_small": potions_small, "herbs": herbs, "deck": deck, "chapter": chapter, "flags": flags,
		"next_energy": next_energy, "next_guard": next_guard, "goods": goods,
		"time": Time.get_datetime_string_from_system(false, true), "play_sec": play_sec, "stats": stats}
	var bd: Control = world_board if (world_board and is_instance_valid(world_board)) else board
	if bd and is_instance_valid(bd):
		d["board"] = bd.get_state()
		d["place"] = bd.place_name()
	# 만리길 판 위의 작은 맵(항구·마을) 안에서 저장하면 그 작은 맵 자리도 함께
	if not sub_stage.is_empty() and board and is_instance_valid(board) and board != bd:
		d["sub"] = sub_stage
		d["sub_board"] = board.get_state()
		d["place"] = board.place_name()
	return d

var last_goal := ""   # 이야기에서 마지막으로 보여 준 목표 (다음 맵 시작 때 다시 띄움)

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
	track_stats = false
	play_sec = float(d.get("play_sec", 0.0)); stats = d.get("stats", {}); goods = d.get("goods", {})
	hero_name = d.get("hero_name", "연이"); alias_name = d.get("alias_name", "")
	max_hp = int(d.get("max_hp", 40)); hp = int(d.get("hp", max_hp))
	coins = int(d.get("coins", 0)); potions = int(d.get("potions", 2))
	potions_small = int(d.get("potions_small", 0)); herbs = mini(int(d.get("herbs", 0)), HERB_MAX)
	chapter = int(d.get("chapter", 1)); flags = d.get("flags", {})
	track_stats = true
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
		board = BoardScreen.new() if is_world_board() else StageScreen.new()
		board.restore = d["board"].duplicate()
		if d.has("sub") and d.has("sub_board") and is_world_board():
			board.restore["in_sub"] = true
		_swap(board)
		if d.has("sub") and d.has("sub_board") and is_world_board():
			var wb: Control = board
			var vidx := int(d["board"].get("pos", 0))
			await get_tree().process_frame
			await get_tree().process_frame
			start_voyage(d["sub"], func():
				wb.cleared[vidx] = true
				wb._dim_marker(vidx)
				wb._end_turn(), d["sub_board"])
	elif stage_idx > 0:
		# 맵을 깬 뒤 이어지는 이야기 도중에 저장됨 → 장 첫 이야기로 되돌아가지 않고 그 이야기부터 다시
		phase = "board"
		var stl: Array = ch_cfg().get("stages", [])
		if stage_idx < stl.size() and stl[stage_idx].get("after_story", false):
			play_story(StoryData.lines(stl[stage_idx].get("after", "")), next_stage)
		else:
			start_board()
	else:
		phase = "prologue"
		play_story(chapter_lines("intro"), start_board)

func _slot_label(slot: String) -> String:
	var d := read_save(slot)
	var head := "자동 저장" if slot == "auto" else "%s번 칸" % slot
	if d.is_empty():
		return "%s\n— 비어 있음 —" % head
	var where := "제%d장 시작" % int(d.get("chapter", 1)) if d.get("phase", "") != "board" else "제%d장 · %s" % [int(d.get("chapter", 1)), d.get("place", "")]
	return "%s · %s · 플레이 %s\n%s · %s" % [head, d.get("hero_name", ""), fmt_time(float(d.get("play_sec", 0.0))), where, str(d.get("time", "")).replace("T", " ").left(16)]

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
	p.offset_left = -200; p.offset_right = 200; p.offset_top = 400
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
