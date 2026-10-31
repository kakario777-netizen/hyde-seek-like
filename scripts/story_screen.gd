extends Control
## 대화·선택지로 진행되는 이야기 화면

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

const TYPE_SPEED := 40.0  # 초당 글자 수

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dark := ColorRect.new()
	dark.color = Color("120d10")
	dark.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dark)

	bg = TextureRect.new()
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.anchor_right = 1.0
	bg.anchor_bottom = 0.62
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	portrait = main.pixel_rect("yeoni", 10)
	portrait.anchor_top = 1.0
	portrait.anchor_bottom = 1.0
	portrait.anchor_left = 0.5
	portrait.anchor_right = 0.5
	portrait.offset_left = -120
	portrait.offset_right = 120
	portrait.offset_bottom = -556
	portrait.offset_top = -556 - 320
	add_child(portrait)

	# 대화창
	var box := PanelContainer.new()
	box.add_theme_stylebox_override("panel", main.paper_box())
	box.anchor_left = 0.0; box.anchor_right = 1.0
	box.anchor_top = 1.0; box.anchor_bottom = 1.0
	box.offset_left = 20; box.offset_right = -20
	box.offset_top = -560; box.offset_bottom = -40
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(vb)

	name_tag = PanelContainer.new()
	var ns: StyleBoxFlat = main.paper_box(main.RED, main.INK, 3)
	ns.set_content_margin_all(10)
	ns.content_margin_left = 20; ns.content_margin_right = 20
	name_tag.add_theme_stylebox_override("panel", ns)
	name_tag.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	name_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(name_tag)
	name_lbl = main.make_label("", 28, Color("f4ead2"), true)
	name_tag.add_child(name_lbl)

	text_lbl = main.make_label("", 32)
	text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_lbl.add_theme_constant_override("line_spacing", 10)
	vb.add_child(text_lbl)

	arrow = main.make_label("▼", 26, main.RED)
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vb.add_child(arrow)

	choice_box = VBoxContainer.new()
	choice_box.add_theme_constant_override("separation", 18)
	choice_box.anchor_left = 0.0; choice_box.anchor_right = 1.0
	choice_box.anchor_top = 0.0; choice_box.anchor_bottom = 1.0
	choice_box.offset_left = 60; choice_box.offset_right = -60
	choice_box.offset_bottom = -600
	choice_box.alignment = BoxContainer.ALIGNMENT_END
	choice_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(choice_box)

	_next()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance()
	elif event is InputEventScreenTouch and event.pressed:
		_advance()

func _advance() -> void:
	if waiting_choice or ended:
		return
	if typing:
		typing = false
		text_lbl.visible_ratio = 1.0
		_after_typed()
		return
	var line: Dictionary = lines[idx]
	if line.get("end", false):
		ended = true
		if on_done.is_valid():
			on_done.call()
		return
	if line.has("goto"):
		_jump(line["goto"])
	else:
		_next()

func _jump(label: String) -> void:
	for i in lines.size():
		if lines[i].get("label", "") == label:
			idx = i - 1
			break
	_next()

func _next() -> void:
	idx += 1
	if idx >= lines.size():
		ended = true
		if on_done.is_valid():
			on_done.call()
		return
	var line: Dictionary = lines[idx]
	if line.has("bg"):
		bg.texture = main.tex("bg_" + line["bg"])
	var who: String = line.get("who", "")
	name_tag.visible = who != ""
	name_lbl.text = who
	if line.has("pose"):
		portrait.texture = main.tex(line["pose"])
		portrait.show()
	elif who == "":
		portrait.hide()
	text_lbl.text = line["text"]
	text_lbl.visible_characters = 0
	typing = true
	arrow.modulate.a = 0.0

func _process(delta: float) -> void:
	if typing:
		text_lbl.visible_characters += max(1, int(TYPE_SPEED * delta + 0.5))
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
			var b: Button = main.make_button(c["text"], 30)
			b.custom_minimum_size = Vector2(0, 96)
			choice_box.add_child(b)
			var target: String = c["goto"]
			b.pressed.connect(func(): _choose(target))

func _choose(target: String) -> void:
	for ch in choice_box.get_children():
		ch.queue_free()
	waiting_choice = false
	_jump(target)
