extends Control
## 타이틀 화면

var main

func _ready() -> void:
	var map := TextureRect.new()
	map.texture = main.tex("board_map")
	map.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	map.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	map.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map.modulate = Color(0.45, 0.42, 0.5)
	add_child(map)

	var vb := VBoxContainer.new()
	vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 28)
	add_child(vb)

	var sub: Label = main.make_label("조선 활극 보드 어드벤처", 28, Color("e8d6a8"), true)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(sub)
	var title: Label = main.make_label("한양 숨바꼭질", 84, Color("f4ead2"), true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_outline_color", Color("2a1d1a"))
	title.add_theme_constant_override("outline_size", 18)
	vb.add_child(title)

	var hero_box := CenterContainer.new()
	hero_box.custom_minimum_size = Vector2(0, 300)
	vb.add_child(hero_box)
	hero_box.add_child(main.pixel_rect("yeoni", 9))

	var start: Button = main.make_button("이야기 시작", 34)
	start.custom_minimum_size = Vector2(360, 96)
	start.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vb.add_child(start)
	start.pressed.connect(main.new_game)

	var ver: Label = main.make_label("v0.2 카드 합성·장터", 22, Color("a89a80"))
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(ver)
