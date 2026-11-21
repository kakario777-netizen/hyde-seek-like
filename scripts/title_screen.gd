extends Control
## 타이틀 화면

var main

var cleared := false
var unlocked: Array = []
## 일러스트 보기: 순서대로 (열린 것만 보인다)
const ILLUST := [["title_clear", "허 의원과 잠든 연이"], ["wedding", "서휘와의 혼례"], ["family", "서휘와 연이의 가족"],
	["wedding_dogyeol", "윤도결과의 혼례"], ["family_dogyeol", "윤도결과 연이의 가족"], ["title_both", "세 사람"], ["title_group", "허씨 약방 앞에서"]]
var seen: Array = []

func _ready() -> void:
	# 한 번 끝까지 하면 처음 화면이 허 의원과 잠든 어린 주인공 그림으로 바뀐다
	var book: Dictionary = main.title_book()
	cleared = int(book.get("_clears", 0)) > 0
	var bg := TextureRect.new()
	var ends: Array = book.get("_endings", [])
	# 엔딩 기록이 생기기 전에 깬 판은 '반려' 칭호로 알아본다
	var saw_s: bool = "seohwi" in ends or book.has("서휘의 반려")
	var saw_d: bool = "dogyeol" in ends or book.has("윤도결의 반려")
	# 처음 화면 그림 모음: 조건을 이룰 때마다 하나씩 열리고, 켤 때마다 무작위(또는 고른 그림)
	unlocked = []
	if cleared: unlocked.append("title_clear")
	if saw_s: unlocked.append("wedding")
	if saw_d: unlocked.append("wedding_dogyeol")
	if saw_s and saw_d: unlocked.append("title_both")
	if int(book.get("_clears", 0)) >= 5 and main.backdrop("title_group"): unlocked.append("title_group")   # 다섯 번 완주: 단체 사진
	seen = unlocked.duplicate()
	if saw_s: seen.append("family")
	if saw_d: seen.append("family_dogyeol")
	var pick := ""
	if not unlocked.is_empty():
		pick = unlocked[randi() % unlocked.size()]
	if OS.has_environment("TITLE_PIC"): pick = OS.get_environment("TITLE_PIC")   # 캡처 확인용
	if pick != "" and main.backdrop(pick):
		bg.texture = main.backdrop(pick)
	else:
		bg.texture = main.backdrop("title") if main.backdrop("title") else load("res://assets/ui/board_map.jpg")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.modulate = Color(0.62, 0.55, 0.5) if bg.texture == null else Color.WHITE
	add_child(bg)
	main.shrink_overlay(self, pick, bg)
	main.align_cover(pick, bg)
	if cleared:   # 글자가 잘 보이게 아래쪽만 살짝 어둡게
		var g2 := Gradient.new()
		g2.set_color(0, Color(0.06, 0.04, 0.03, 0.0)); g2.set_color(1, Color(0.06, 0.04, 0.03, 0.55))
		var gt2 := GradientTexture2D.new(); gt2.gradient = g2
		gt2.fill_from = Vector2(0.5, 0.35); gt2.fill_to = Vector2(0.5, 1.0); gt2.width = 64; gt2.height = 256
		var sh2 := TextureRect.new(); sh2.texture = gt2; sh2.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sh2.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); sh2.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(sh2)

	var shadow: Texture2D = main.illust("shadow") if not cleared else null
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
	var hero: Texture2D = main.illust("hero") if not cleared else null
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
	if cleared:
		var done: Label = main.ink_text(main.make_label("완주 %d번" % int(main.title_book().get("_clears", 0)), 30, main.GOLD, true), 8)
		done.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT   # 그림 속 허 의원 얼굴을 가리지 않게 오른쪽으로
		var drow := MarginContainer.new()
		drow.add_theme_constant_override("margin_right", 40)
		drow.add_child(done)
		vb.add_child(drow)
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
	if not seen.is_empty():
		var ib: Button = main.make_button("일러스트 보기", 30)
		ib.custom_minimum_size = Vector2(420, 90)
		ib.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		vb.add_child(ib)
		ib.pressed.connect(_open_gallery)
	var setb: Button = main.make_button("설정", 30)
	setb.custom_minimum_size = Vector2(420, 90)
	setb.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vb.add_child(setb)
	setb.pressed.connect(func(): main.open_settings())
	main.bgm("yakbang_day" if cleared else "title")

	var ver: Label = main.ink_text(main.make_label("v2.3 · 빌드 %d" % load("res://scripts/boot.gd").running_build(), 24, Color("e0d0b0")), 6)
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(ver)
	var cr: Label = main.ink_text(main.make_label("아이콘 game-icons.net(CC BY 3.0)\n질감 ambientCG(CC0) · 글꼴 송명·고운바탕(OFL)", 18, Color("cbb898")), 4)
	cr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(cr)


## 열린 일러스트를 한 장씩 크게 본다 (좌우로 넘기기)
func _open_gallery() -> void:
	var list: Array = []
	for it in ILLUST:
		if it[0] in seen and main.backdrop(it[0]):
			list.append(it)
	if list.is_empty():
		return
	var layer := CanvasLayer.new()
	layer.layer = 50
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)
	var dark := ColorRect.new()
	dark.color = Color(0.03, 0.02, 0.02, 0.96)
	dark.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dark)
	var pic := TextureRect.new()
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pic.offset_top = 110; pic.offset_bottom = -170
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(pic)
	var cap: Label = main.make_label("", 32, main.GOLD, true)
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cap.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	cap.offset_top = 30; cap.offset_bottom = 100
	root.add_child(cap)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	row.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	row.offset_top = -140; row.offset_bottom = -40
	root.add_child(row)
	var prev: Button = main.make_button("◀", 34)
	var close: Button = main.make_button("닫기", 30)
	var nxt: Button = main.make_button("▶", 34)
	for b in [prev, close, nxt]:
		b.custom_minimum_size = Vector2(150 if b != close else 220, 90)
		row.add_child(b)
	var locked := ILLUST.size() - list.size()
	var st := {"i": 0}
	var show := func():
		var it: Array = list[st["i"]]
		pic.texture = main.backdrop(it[0])
		cap.text = "%s  (%d / %d)" % [it[1], st["i"] + 1, list.size()]
		if locked > 0:
			cap.text += "\n아직 열리지 않은 그림 %d장" % locked
	show.call()
	prev.pressed.connect(func(): st["i"] = (st["i"] - 1 + list.size()) % list.size(); show.call())
	nxt.pressed.connect(func(): st["i"] = (st["i"] + 1) % list.size(); show.call())
	close.pressed.connect(func(): layer.queue_free())
