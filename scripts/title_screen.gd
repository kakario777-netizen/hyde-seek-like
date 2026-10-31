extends Control
## 타이틀 화면

var main

func _ready() -> void:
	var bg := TextureRect.new()
	bg.texture = main.backdrop("title") if main.backdrop("title") else load("res://assets/ui/board_map.jpg")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.modulate = Color(0.62, 0.55, 0.5) if main.backdrop("title") == null else Color.WHITE
	add_child(bg)

	var shadow: Texture2D = main.illust("shadow")
	if shadow:
		var sh: TextureRect = main.tex_rect(shadow, Vector2(900, 1300))
		sh.anchor_left = 0.5; sh.anchor_right = 0.5; sh.anchor_top = 1.0; sh.anchor_bottom = 1.0
		sh.offset_left = -330; sh.offset_right = 570; sh.offset_top = -1480; sh.offset_bottom = -180
		sh.modulate = Color(0.55, 0.4, 0.42, 0.75)
		add_child(sh)
	var hero: Texture2D = main.illust("hero")
	if hero:
		var h: TextureRect = main.tex_rect(hero, Vector2(720, 1100))
		h.anchor_left = 0.5; h.anchor_right = 0.5; h.anchor_top = 1.0; h.anchor_bottom = 1.0
		h.offset_left = -470; h.offset_right = 250; h.offset_top = -1080; h.offset_bottom = 20
		h.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		add_child(h)

	var shade := ColorRect.new()
	shade.color = Color(0.1, 0.06, 0.03, 0.35)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var vb := VBoxContainer.new()
	vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vb.offset_top = 140; vb.offset_bottom = -120
	vb.add_theme_constant_override("separation", 18)
	add_child(vb)

	var sub: Label = main.ink_text(main.make_label("조선 활극 보드 어드벤처", 32, main.GOLD, true), 8)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(sub)
	var title: Label = main.ink_text(main.make_label("한양 숨바꼭질", 104, main.LIGHT, true), 22)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(title)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(spacer)

	var start: Button = main.make_button("이야기 시작", 40)
	start.custom_minimum_size = Vector2(420, 120)
	start.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vb.add_child(start)
	start.pressed.connect(main.new_game)

	var ver: Label = main.ink_text(main.make_label("v0.3 조선 한지 판", 24, Color("e0d0b0")), 6)
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(ver)
	var cr: Label = main.ink_text(main.make_label("지도 수선전도(퍼블릭 도메인) · 아이콘 game-icons.net(CC BY 3.0)\n질감 ambientCG(CC0) · 글꼴 송명·고운바탕(OFL)", 18, Color("cbb898")), 4)
	cr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(cr)
