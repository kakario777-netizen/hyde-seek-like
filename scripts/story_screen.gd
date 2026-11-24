extends Control
## 대화·선택지로 진행되는 이야기 화면 (일러스트 + 한지 대화창)

var main
var lines: Array = []
var on_done: Callable

var idx := -1
var bg: TextureRect
var portrait: TextureRect
var name_tag: PanelContainer
var name_lbl: Label
var text_lbl: Label
var arrow: Label
var choice_box: VBoxContainer
var typing := false
var waiting_choice := false
var ended := false
var last_pose := ""
var box: PanelContainer
var goal_panel: PanelContainer
var goal_lbl: Label

const TYPE_SPEED := 28.0  # 초당 글자 수
const BOX_H := 430
const SCENE_BOX_H := 360

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	bg = TextureRect.new()
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	portrait = TextureRect.new()
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.anchor_left = 0.5; portrait.anchor_right = 0.5
	portrait.anchor_top = 1.0; portrait.anchor_bottom = 1.0
	portrait.offset_left = -380; portrait.offset_right = 380
	portrait.offset_top = -BOX_H - 980; portrait.offset_bottom = -BOX_H + 60
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(portrait)

	# 대화창
	box = PanelContainer.new()
	box.add_theme_stylebox_override("panel", main.panel_style())
	box.anchor_left = 0.0; box.anchor_right = 1.0
	box.anchor_top = 1.0; box.anchor_bottom = 1.0
	box.offset_left = 8; box.offset_right = -8
	box.offset_top = -BOX_H; box.offset_bottom = -16
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)
	# 대사 4줄이 딱 들어가게 위아래 여백을 줄인다
	var bs: StyleBoxTexture = main.panel_style()
	bs.content_margin_top = 52; bs.content_margin_bottom = 78   # 이름칸은 위로, 아래는 넘김 화살표 자리를 비워 글을 가리지 않게   # 위·아래·좌우 모두 붉은 안쪽 테두리와 같은 간격
	bs.content_margin_left = 74; bs.content_margin_right = 74   # 글이 붉은 안쪽 테두리 안에 넉넉히
	box.add_theme_stylebox_override("panel", bs)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(vb)

	name_tag = PanelContainer.new()
	name_tag.add_theme_stylebox_override("panel", main.plaque_style())
	name_tag.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	name_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(name_tag)
	name_lbl = main.make_label("", 32, main.GOLD, true)
	name_tag.add_child(name_lbl)

	text_lbl = main.make_label("", 33)
	text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_lbl.add_theme_constant_override("line_spacing", 8)
	vb.add_child(text_lbl)

	arrow = main.make_label("▼", 32, main.RED)
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# 넘김 표시는 줄을 차지하지 않고 대화창 오른쪽 아래 모퉁이에
	# 대화창 글 칸에 붙여 두는 판: 넘김 화살표는 글 바로 아래 오른쪽 (테두리·글을 가리지 않게)
	var holder := Control.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(holder)
	arrow.anchor_left = 1.0; arrow.anchor_right = 1.0; arrow.anchor_top = 1.0; arrow.anchor_bottom = 1.0
	arrow.offset_left = -40; arrow.offset_right = 0; arrow.offset_top = 2; arrow.offset_bottom = 40
	holder.add_child(arrow)

	choice_box = VBoxContainer.new()
	choice_box.add_theme_constant_override("separation", 16)
	choice_box.anchor_left = 0.0; choice_box.anchor_right = 1.0
	choice_box.anchor_top = 0.0; choice_box.anchor_bottom = 1.0
	choice_box.offset_left = 50; choice_box.offset_right = -50
	choice_box.offset_bottom = -BOX_H - 40
	choice_box.alignment = BoxContainer.ALIGNMENT_END
	choice_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(choice_box)

	# 【목표】는 화면 한가운데 큰 판으로
	goal_panel = PanelContainer.new()
	goal_panel.add_theme_stylebox_override("panel", main.panel_style())
	goal_panel.anchor_left = 0.0; goal_panel.anchor_right = 1.0
	goal_panel.anchor_top = 0.5; goal_panel.anchor_bottom = 0.5
	goal_panel.offset_left = 40; goal_panel.offset_right = -40
	goal_panel.offset_top = -200; goal_panel.offset_bottom = 200
	goal_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	goal_panel.visible = false
	add_child(goal_panel)
	var gv := VBoxContainer.new()
	gv.alignment = BoxContainer.ALIGNMENT_CENTER
	gv.add_theme_constant_override("separation", 22)
	gv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	goal_panel.add_child(gv)
	var gt: Label = main.make_label("목표", 40, main.RED, true)
	gt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gv.add_child(gt)
	goal_lbl = main.make_label("", 36, Color("6b3a1e"))
	goal_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	goal_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	goal_lbl.add_theme_constant_override("line_spacing", 14)
	gv.add_child(goal_lbl)
	var tap: Label = main.make_label("화면을 누르면 시작합니다", 24, main.INK)
	tap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tap.modulate.a = 0.6
	gv.add_child(tap)

	_set_bg("yakbang")
	_next()

const BG_MUSIC := {"alley": "night", "title": "story", "yakbang": "story", "jangteo": "story", "byeolchae": "night", "yakbang_calm": "yakbang_day", "wedding": "wedding_feast", "wedding_dogyeol": "wedding_feast", "palace": "palace", "deck": "sea_voyage", "deck_night": "sea_voyage", "ferry": "sea_voyage", "port": "sea_voyage", "holland": "holland_town", "stream_day": "yakbang_day", "dutch_child_room": "holland_town", "dutch_classroom": "holland_town", "holland_port": "holland_town", "island": "holland_town", "exile_hut": "lonely_night", "island_grave": "sad_farewell", "uigeumbu": "lonely_night", "daebi_room": "dread_shadow", "naeuiwon": "dread_shadow", "mapo_warehouse": "dread_shadow", "palace_night": "dread_shadow", "flash_plague": "lonely_night", "flash_carried": "lonely_night", "flash_seohwi_parents": "sad_farewell", "flash_dogyeol": "lonely_night", "heo_letter": "lonely_night"}

## 인물이 그려진 장면 일러스트: 이 배경일 땐 전신 인물을 띄우지 않음
const SCENE_ILLUST := ["wedding", "family", "wedding_dogyeol", "family_dogyeol", "flash_plague", "flash_carried", "flash_seohwi_parents", "flash_dogyeol", "heo_letter"]
var cur_bg := ""

func _set_bg(name: String) -> void:
	cur_bg = name
	if name in SCENE_ILLUST:
		_show_pose("")
	# 혼례·가족 같은 한 장면 그림 위에서는 인물 전신 없이, 대화창을 낮게 깔아 그림을 가리지 않는다
	box.offset_top = -SCENE_BOX_H if name in SCENE_ILLUST else -BOX_H
	main.bgm(BG_MUSIC.get(name, "story"))
	var t: Texture2D = main.backdrop(name)
	if t:
		bg.texture = t
		bg.modulate = Color.WHITE
		main.shrink_overlay(self, name, bg)
	else:
		main.shrink_overlay(self, "", bg)
		bg.texture = load("res://assets/ui/board_map.jpg")
		bg.modulate = Color(0.35, 0.3, 0.28)

func _gui_input(event: InputEvent) -> void:
	# 폰에서는 터치가 마우스 클릭으로도 한 번 더 들어온다 → 마우스 쪽만 받아 한 번만 넘김
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance()

func _advance() -> void:
	if waiting_choice or ended:
		return
	if chapter_card != null:
		if card_lock:
			return
		var c := chapter_card
		chapter_card = null
		var tw := create_tween()
		tw.tween_property(c, "modulate:a", 0.0, 0.35)
		tw.tween_callback(c.queue_free)
		box.visible = true
		if lines[idx].get("end", false):
			_finish()
		else:
			_next()
		return
	if not typing:
		main.sfx("page", -6.0)
	if typing:
		typing = false
		text_lbl.visible_ratio = 1.0
		_after_typed()
		return
	var line: Dictionary = lines[idx]
	if line.get("end", false):
		_finish()
		return
	if line.has("goto"):
		_jump(line["goto"])
	else:
		_next()

func _finish() -> void:
	ended = true
	if on_done.is_valid():
		on_done.call()

func _jump(label: String) -> void:
	for i in lines.size():
		if lines[i].get("label", "") == label:
			idx = i - 1
			break
	_next()

func _next() -> void:
	idx += 1
	while idx < lines.size():
		var ln: Dictionary = lines[idx]
		if (ln.has("if") and not main.flags.has(ln["if"])) or (ln.has("ifnot") and main.flags.has(ln["ifnot"])):
			idx += 1
			continue
		break
	if idx >= lines.size():
		_finish()
		return
	var line: Dictionary = lines[idx]
	main.apply_line_effects(line)
	if line.has("bg"):
		_set_bg(line["bg"])
	var who: String = main.fmt(line.get("who", ""))
	name_tag.visible = who != ""
	name_lbl.text = who
	if line.has("pose") or line.has("pic"):
		_show_pose(line.get("pose", line.get("pic", "")))
	elif who == "":
		_show_pose("")
	main.line_music(line)
	text_lbl.text = main.smart_breaks(main.fmt(line["text"]), 33, 640.0, 4)
	if cur_bg in SCENE_ILLUST:   # 한 장면 그림 위: 글줄 수만큼만 대화창을 올린다
		box.anchor_top = 1.0; box.anchor_bottom = 1.0
		box.offset_top = -maxf(SCENE_BOX_H, 230.0 + 50.0 * text_lbl.text.count("\n") + 50.0); box.offset_bottom = -16
	elif who == "" and last_pose == "":   # 인물 없는 해설·설명은 화면 가운데에
		box.anchor_top = 0.5; box.anchor_bottom = 0.5
		var nh := 150.0 + 45.0 * (text_lbl.text.count("\n") + 1)   # 글줄 수에 맞춘 높이
		box.offset_top = -nh / 2.0; box.offset_bottom = nh / 2.0
	else:
		box.anchor_top = 1.0; box.anchor_bottom = 1.0
		box.offset_top = -BOX_H; box.offset_bottom = -16
	var raw: String = line["text"]
	if raw.begins_with("― ") and raw.ends_with(" ―"):   # 장 제목: 한눈에 보이는 큰 제목 판
		_show_chapter_card(raw.substr(2, raw.length() - 4))
		return
	var goal: bool = line["text"].begins_with("【목표】")
	if goal:
		main.last_goal = line["text"].trim_prefix("【목표】").strip_edges()
	text_lbl.add_theme_color_override("font_color", Color("6b3a1e") if goal else main.INK)
	box.visible = not goal
	goal_panel.visible = goal
	if goal:
		_show_pose("")
		goal_lbl.text = main.fmt(line["text"].trim_prefix("【목표】").strip_edges())
		goal_panel.modulate.a = 0.0
		create_tween().tween_property(goal_panel, "modulate:a", 1.0, 0.3)
	text_lbl.visible_characters = 0
	type_acc = 0.0
	typing = true
	arrow.modulate.a = 0.0
	if goal:   # 목표 판은 한 번 누르면 바로 넘어가게
		typing = false
		text_lbl.visible_ratio = 1.0

var chapter_card: Control = null
var card_lock := false

## 장이 바뀔 때: 화면 가운데 큰 제목 판 ("제5장" + 「어의」)
func _show_chapter_card(t: String) -> void:
	box.visible = false
	goal_panel.visible = false
	_show_pose("")
	typing = false
	var head := t
	var sub := ""
	var k := t.find("「")
	if k > 0:
		head = t.substr(0, k).strip_edges()
		sub = t.substr(k).strip_edges()
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var dim := ColorRect.new()
	dim.color = Color(0.05, 0.03, 0.02, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(dim)
	var pc := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("2a1a12f0")
	sb.border_color = Color("d6aa50")
	sb.set_border_width_all(6)
	sb.set_corner_radius_all(18)
	sb.content_margin_left = 60; sb.content_margin_right = 60
	sb.content_margin_top = 56; sb.content_margin_bottom = 56
	sb.shadow_color = Color(0, 0, 0, 0.5); sb.shadow_size = 18
	pc.add_theme_stylebox_override("panel", sb)
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pc.custom_minimum_size = Vector2(820, 0)
	pc.set_anchors_preset(Control.PRESET_CENTER)
	pc.grow_horizontal = Control.GROW_DIRECTION_BOTH
	pc.grow_vertical = Control.GROW_DIRECTION_BOTH
	root.add_child(pc)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 18)
	pc.add_child(vb)
	var l1: Label = main.make_label(head, 56, Color("e9c97a"), true)
	l1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(l1)
	var line_r := ColorRect.new()
	line_r.color = Color("d6aa50")
	line_r.custom_minimum_size = Vector2(0, 3)
	vb.add_child(line_r)
	if sub != "":
		var l2: Label = main.make_label(sub, 88, Color("fff4dc"), true)
		l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(l2)
	var tap: Label = main.make_label("화면을 누르면 계속합니다" if t.ends_with("끝") else "화면을 누르면 시작합니다", 26, Color("c9b08a"))
	tap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(tap)
	root.modulate.a = 0.0
	chapter_card = root
	card_lock = true
	main.sfx("gong", -6.0)
	var tw := create_tween()
	tw.tween_property(root, "modulate:a", 1.0, 0.6)
	tw.tween_interval(0.4)
	tw.tween_callback(func(): card_lock = false)

func _show_pose(pose: String) -> void:
	if cur_bg in SCENE_ILLUST:
		pose = ""
	if pose == last_pose:
		return
	last_pose = pose
	if pose == "shadow":
		main.sfx("gong", -4.0)
	var t: Texture2D = main.illust(pose) if pose != "" else null
	if t == null:
		create_tween().tween_property(portrait, "modulate:a", 0.0, 0.15)
		return
	portrait.texture = t
	# 키 비율: 발끝은 그대로, 위쪽만 줄임
	var fsc: float = main.fig_scale(pose)
	var lift := _feet_lift(t, fsc)   # 발끝이 대화창 바로 위에 오도록
	portrait.offset_bottom = -BOX_H + 60 - lift
	portrait.offset_top = -BOX_H + 60 - lift - 1040.0 * fsc
	var old := portrait.get_node_or_null("PlaceholderTag")
	if old:
		old.queue_free()
	main.tag_placeholder(portrait, pose)
	portrait.modulate.a = 0.0
	create_tween().tween_property(portrait, "modulate:a", 1.0, 0.25)

var type_acc := 0.0
var _feet: Dictionary = {}

## 그림 아래 투명 여백까지 따져, 발끝이 대화창 위 8px에 서도록 올릴 높이
func _feet_lift(t: Texture2D, fsc: float) -> float:
	if _feet.is_empty():
		var j = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/fig_feet.json"))
		_feet = j if j is Dictionary else {"_": 0}
	var m: float = float(_feet.get(t.resource_path.get_file().get_basename(), 0.0))
	var w: float = t.get_width(); var h: float = t.get_height()
	var rw := 760.0; var rh := 1040.0 * fsc
	var sc: float = min(rw / w, rh / h)
	var gap: float = (rh - h * sc) / 2.0 + m * h * sc   # 그림 칸 바닥과 발끝 사이
	return max(0.0, 68.0 - gap)

func _process(delta: float) -> void:
	if typing:
		type_acc += main.text_speed() * delta
		var n := int(type_acc)
		if n > 0:
			type_acc -= n
			text_lbl.visible_characters += n
		if text_lbl.visible_characters >= text_lbl.get_total_character_count():
			typing = false
			text_lbl.visible_ratio = 1.0
			_after_typed()
	elif not waiting_choice:
		arrow.modulate.a = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 200.0)

func _after_typed() -> void:
	var line: Dictionary = lines[idx]
	if line.has("choices"):
		waiting_choice = true
		arrow.modulate.a = 0.0
		for c in line["choices"]:
			var b: Button = main.make_button(main.fmt(c["text"]), 32)
			b.custom_minimum_size = Vector2(0, 110)
			choice_box.add_child(b)
			var target: String = c.get("goto", "")
			var flag: String = c.get("set", "")
			b.pressed.connect(func(): _choose(target, flag))

func _choose(target: String, flag := "") -> void:
	for ch in choice_box.get_children():
		ch.queue_free()
	waiting_choice = false
	if flag != "":
		main.flags[flag] = true
	if target != "":
		_jump(target)
	else:
		_next()
