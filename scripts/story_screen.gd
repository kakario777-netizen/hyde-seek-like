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

const TYPE_SPEED := 28.0  # 초당 글자 수
const BOX_H := 520

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
	var box := PanelContainer.new()
	box.add_theme_stylebox_override("panel", main.panel_style())
	box.anchor_left = 0.0; box.anchor_right = 1.0
	box.anchor_top = 1.0; box.anchor_bottom = 1.0
	box.offset_left = 8; box.offset_right = -8
	box.offset_top = -BOX_H; box.offset_bottom = -16
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)
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
	text_lbl.add_theme_constant_override("line_spacing", 12)
	vb.add_child(text_lbl)

	arrow = main.make_label("▼", 26, main.RED)
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vb.add_child(arrow)

	choice_box = VBoxContainer.new()
	choice_box.add_theme_constant_override("separation", 16)
	choice_box.anchor_left = 0.0; choice_box.anchor_right = 1.0
	choice_box.anchor_top = 0.0; choice_box.anchor_bottom = 1.0
	choice_box.offset_left = 50; choice_box.offset_right = -50
	choice_box.offset_bottom = -BOX_H - 40
	choice_box.alignment = BoxContainer.ALIGNMENT_END
	choice_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(choice_box)

	_set_bg("yakbang")
	_next()

const BG_MUSIC := {"alley": "night", "title": "story", "yakbang": "story", "jangteo": "story", "byeolchae": "night", "street_ink": "story"}

## 인물이 그려진 장면 일러스트: 이 배경일 땐 전신 인물을 띄우지 않음
const SCENE_ILLUST := ["wedding", "family"]
var cur_bg := ""

func _set_bg(name: String) -> void:
	cur_bg = name
	if name in SCENE_ILLUST:
		_show_pose("")
	main.bgm(BG_MUSIC.get(name, "story"))
	var t: Texture2D = main.backdrop(name)
	if t:
		bg.texture = t
		bg.modulate = Color.WHITE
	else:
		bg.texture = load("res://assets/ui/board_map.jpg")
		bg.modulate = Color(0.35, 0.3, 0.28)

func _gui_input(event: InputEvent) -> void:
	# 폰에서는 터치가 마우스 클릭으로도 한 번 더 들어온다 → 마우스 쪽만 받아 한 번만 넘김
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance()

func _advance() -> void:
	if waiting_choice or ended:
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
	text_lbl.text = main.sentence_breaks(main.fmt(line["text"]))
	var goal: bool = line["text"].begins_with("【목표】")
	text_lbl.add_theme_color_override("font_color", Color("6b3a1e") if goal else main.INK)
	text_lbl.visible_characters = 0
	type_acc = 0.0
	typing = true
	arrow.modulate.a = 0.0

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
	portrait.offset_top = -BOX_H + 60 - 1040.0 * fsc
	var old := portrait.get_node_or_null("PlaceholderTag")
	if old:
		old.queue_free()
	main.tag_placeholder(portrait, pose)
	portrait.modulate.a = 0.0
	create_tween().tween_property(portrait, "modulate:a", 1.0, 0.25)

var type_acc := 0.0

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
