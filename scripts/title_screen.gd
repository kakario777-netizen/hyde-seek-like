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
		sh.modulate = Color(0.85, 0.72, 0.76, 0.95)
		add_child(sh)
		# 얼굴만 안개로 흐릿하게 가린다
		var g := Gradient.new()
		g.set_color(0, Color(0.08, 0.05, 0.06, 0.82))
		g.set_color(1, Color(0.08, 0.05, 0.06, 0.0))
		var gt := GradientTexture2D.new()
		gt.gradient = g
		gt.fill = GradientTexture2D.FILL_RADIAL
		gt.fill_from = Vector2(0.5, 0.5); gt.fill_to = Vector2(0.5, 0.0)
		gt.width = 256; gt.height = 256
		var fog := TextureRect.new()
		fog.texture = gt
		fog.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		fog.anchor_left = 0.5; fog.anchor_right = 0.5; fog.anchor_top = 1.0; fog.anchor_bottom = 1.0
		fog.offset_left = -80; fog.offset_right = 260; fog.offset_top = -1520; fog.offset_bottom = -1180
		fog.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(fog)
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
	var cont: Button = main.make_button("이어하기", 34)
	cont.custom_minimum_size = Vector2(420, 100)
	cont.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cont.disabled = not main.has_any_save()
	vb.add_child(cont)
	cont.pressed.connect(func(): main.open_slots("load"))
	var setb: Button = main.make_button("설정", 30)
	setb.custom_minimum_size = Vector2(420, 90)
	setb.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vb.add_child(setb)
	setb.pressed.connect(func(): main.open_settings())
	main.bgm("title")

	var ver: Label = main.ink_text(main.make_label("v1.7 윤도결 이야기판", 24, Color("e0d0b0")), 6)
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(ver)
	var cr: Label = main.ink_text(main.make_label("아이콘 game-icons.net(CC BY 3.0)\n질감 ambientCG(CC0) · 글꼴 송명·고운바탕(OFL)", 18, Color("cbb898")), 4)
	cr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(cr)
