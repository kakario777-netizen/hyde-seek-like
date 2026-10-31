extends Control
## 카드 전투: 적 공격 게이지가 차기 전에 기력을 써서 카드를 낸다

var main
var enemy_id := "walpae"
var on_win: Callable

const MAX_ENERGY := 3
const ENERGY_TIME := 1.1   # 기력 1칸 차는 시간(초)
const HAND_SIZE := 4

var enemy: Dictionary
var e_hp := 0
var e_gauge := 0.0
var energy := 2.0
var shield := 0
var running := false
var hand: Array = []

var enemy_sprite: TextureRect
var enemy_base := Vector2.ZERO
var e_hp_bar: ProgressBar
var e_gauge_bar: ProgressBar
var e_hp_lbl: Label
var p_hp_bar: ProgressBar
var p_hp_lbl: Label
var energy_lbl: Label
var shield_lbl: Label
var flash: ColorRect
var card_row: HBoxContainer
var banner: Label

func _ready() -> void:
	enemy = GameData.ENEMIES[enemy_id]
	e_hp = enemy["hp"]

	var dark := ColorRect.new()
	dark.color = Color("1b1418")
	dark.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dark)

	var bg := TextureRect.new()
	bg.texture = main.tex("bg_alley")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.anchor_right = 1.0; bg.anchor_bottom = 0.56
	add_child(bg)

	# 적
	enemy_sprite = main.pixel_rect(enemy["sprite"], 11)
	add_child(enemy_sprite)

	var top := VBoxContainer.new()
	top.anchor_right = 1.0
	top.offset_left = 40; top.offset_right = -40; top.offset_top = 40
	top.add_theme_constant_override("separation", 8)
	add_child(top)
	var ename: Label = main.make_label(enemy["name"], 34, Color("f4ead2"), true)
	ename.add_theme_color_override("font_outline_color", main.INK)
	ename.add_theme_constant_override("outline_size", 10)
	top.add_child(ename)
	e_hp_bar = _bar(Color("c0392b"), 30)
	top.add_child(e_hp_bar)
	e_hp_lbl = main.make_label("", 22, Color("f4ead2"))
	top.add_child(e_hp_lbl)
	var gl: Label = main.make_label("공격 준비", 22, Color("e8d6a8"))
	top.add_child(gl)
	e_gauge_bar = _bar(Color("e8a33a"), 20)
	top.add_child(e_gauge_bar)

	# 주인공 정보
	var pp := PanelContainer.new()
	var sb: StyleBoxFlat = main.paper_box(Color("2a1d1a"), Color("d4a84a"), 3)
	sb.shadow_size = 0
	pp.add_theme_stylebox_override("panel", sb)
	pp.anchor_top = 0.56; pp.anchor_right = 1.0; pp.anchor_bottom = 0.56
	pp.offset_left = 12; pp.offset_right = -12; pp.offset_top = 12
	add_child(pp)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 18)
	pp.add_child(hb)
	hb.add_child(main.pixel_rect("token_yeoni", 7))
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 6)
	hb.add_child(info)
	info.add_child(main.make_label("연돌이", 28, Color("f4ead2"), true))
	p_hp_bar = _bar(Color("4f9a6a"), 26)
	info.add_child(p_hp_bar)
	p_hp_lbl = main.make_label("", 22, Color("f4ead2"))
	info.add_child(p_hp_lbl)
	energy_lbl = main.make_label("", 30, Color("f0c040"))
	info.add_child(energy_lbl)
	shield_lbl = main.make_label("", 22, Color("9fc3e8"))
	info.add_child(shield_lbl)

	# 손패
	card_row = HBoxContainer.new()
	card_row.alignment = BoxContainer.ALIGNMENT_CENTER
	card_row.add_theme_constant_override("separation", 12)
	card_row.anchor_top = 1.0; card_row.anchor_bottom = 1.0; card_row.anchor_right = 1.0
	card_row.offset_top = -300; card_row.offset_bottom = -24
	add_child(card_row)
	for i in HAND_SIZE:
		hand.append("")
		var b: Button = main.make_button("", 22)
		b.custom_minimum_size = Vector2(162, 270)
		card_row.add_child(b)
		var slot := i
		b.pressed.connect(func(): _play(slot))
		_draw_card(i)

	flash = ColorRect.new()
	flash.color = Color(0.8, 0.1, 0.1, 0.0)
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)

	banner = main.make_label("맞서 싸워라!", 64, Color("f4ead2"), true)
	banner.add_theme_color_override("font_outline_color", main.INK)
	banner.add_theme_constant_override("outline_size", 16)
	banner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(banner)

	resized.connect(_layout)
	_layout()
	_refresh()
	var tw := create_tween()
	tw.tween_interval(0.8)
	tw.tween_property(banner, "modulate:a", 0.0, 0.3)
	tw.tween_callback(func(): running = true)

func _layout() -> void:
	enemy_base = Vector2((size.x - enemy_sprite.size.x) / 2.0, size.y * 0.56 - enemy_sprite.size.y - 10).floor()
	enemy_sprite.position = enemy_base

func _bar(col: Color, h: int) -> ProgressBar:
	var b := ProgressBar.new()
	b.show_percentage = false
	b.custom_minimum_size = Vector2(0, h)
	var bgs := StyleBoxFlat.new()
	bgs.bg_color = Color("1b1418"); bgs.border_color = main.INK; bgs.set_border_width_all(3)
	var fs := StyleBoxFlat.new()
	fs.bg_color = col
	b.add_theme_stylebox_override("background", bgs)
	b.add_theme_stylebox_override("fill", fs)
	b.max_value = 1.0
	b.step = 0.0
	return b

# ── 카드 ────────────────────────────────────────────────
func _draw_card(slot: int) -> void:
	var pool: Array = main.deck.duplicate()
	if main.potions > 0:
		pool.append("yak"); pool.append("yak")
	var id: String = pool.pick_random()
	hand[slot] = id
	var c: Dictionary = GameData.CARDS[id]
	var b: Button = card_row.get_child(slot)
	for ch in b.get_children():
		ch.queue_free()
	var vb := VBoxContainer.new()
	vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vb.offset_top = 10; vb.offset_bottom = -10
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 6)
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(vb)
	var cost: Label = main.make_label("●".repeat(c["cost"]), 22, Color("c08a1a"))
	cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(cost)
	var ic := CenterContainer.new()
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ic.add_child(main.pixel_rect(c["icon"], 5))
	vb.add_child(ic)
	var nm: Label = main.make_label(c["name"], 26, main.INK, true)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(nm)
	var ds: Label = main.make_label(c["desc"], 20, Color("5a4030"))
	ds.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(ds)
	b.pivot_offset = b.custom_minimum_size / 2
	b.scale = Vector2(0.6, 0.6)
	create_tween().tween_property(b, "scale", Vector2.ONE, 0.15)

func _play(slot: int) -> void:
	if not running:
		return
	var id: String = hand[slot]
	var c: Dictionary = GameData.CARDS[id]
	if energy < c["cost"]:
		return
	if c.get("potion", false) and main.potions <= 0:
		_draw_card(slot); return
	energy -= c["cost"]
	if c.has("dmg"):
		e_hp = max(0, e_hp - int(c["dmg"]))
		_float_text("-%d" % c["dmg"], enemy_sprite.position + Vector2(enemy_sprite.size.x / 2, 40), Color("ffdf6a"))
		_shake_enemy()
	if c.has("block"):
		shield += int(c["block"])
		_float_text("막기 +%d" % c["block"], Vector2(size.x / 2, size.y * 0.6), Color("9fc3e8"))
	if c.has("heal"):
		main.potions -= 1
		main.hp = min(main.max_hp, main.hp + int(c["heal"]))
		_float_text("+%d" % c["heal"], Vector2(size.x / 2, size.y * 0.6), Color("8fd0a0"))
	if c.has("slow"):
		e_gauge = max(0.0, e_gauge - float(c["slow"]))
	_draw_card(slot)
	_refresh()
	if e_hp <= 0:
		_win()

func _process(delta: float) -> void:
	if not running:
		return
	energy = min(float(MAX_ENERGY), energy + delta / ENERGY_TIME)
	e_gauge += delta / float(enemy["period"])
	if e_gauge >= 1.0:
		e_gauge = 0.0
		_enemy_attack()
	_refresh()

func _enemy_attack() -> void:
	var dmg: int = max(0, int(enemy["atk"]) - shield)
	var blocked: int = int(enemy["atk"]) - dmg
	shield = 0
	main.hp = max(0, main.hp - dmg)
	var tw := create_tween()
	tw.tween_property(enemy_sprite, "position", enemy_base + Vector2(0, 40), 0.08)
	tw.tween_property(enemy_sprite, "position", enemy_base, 0.15)
	if dmg > 0:
		flash.color.a = 0.45
		create_tween().tween_property(flash, "color:a", 0.0, 0.35)
		_float_text("-%d" % dmg, Vector2(size.x / 2, size.y * 0.6), Color("ff6a5a"))
	else:
		_float_text("막아냈다! (%d)" % blocked, Vector2(size.x / 2, size.y * 0.6), Color("9fc3e8"))
	if main.hp <= 0:
		running = false
		main.game_over("연돌이는 그만 쓰러지고 말았다…")

func _win() -> void:
	running = false
	main.coins += int(enemy["coin"])
	var tw := create_tween()
	tw.tween_property(enemy_sprite, "modulate:a", 0.0, 0.5)
	tw.tween_callback(func():
		main.popup("%s을(를) 물리쳤다!\n\n(엽전 +%d)" % [enemy["name"], enemy["coin"]], "길을 계속 간다", func():
			main.end_battle(self)
			if on_win.is_valid():
				on_win.call()))

func _refresh() -> void:
	e_hp_bar.value = float(e_hp) / float(enemy["hp"])
	e_hp_lbl.text = "체력 %d / %d" % [e_hp, enemy["hp"]]
	e_gauge_bar.value = e_gauge
	p_hp_bar.value = float(main.hp) / float(main.max_hp)
	p_hp_lbl.text = "체력 %d / %d    약병 %d" % [main.hp, main.max_hp, main.potions]
	var full := int(energy)
	energy_lbl.text = "기력 " + "●".repeat(full) + "○".repeat(MAX_ENERGY - full)
	shield_lbl.text = "막기 %d" % shield if shield > 0 else " "
	for i in HAND_SIZE:
		var b: Button = card_row.get_child(i)
		if hand[i] != "":
			b.disabled = energy < GameData.CARDS[hand[i]]["cost"] or not running

# ── 연출 ────────────────────────────────────────────────
func _shake_enemy() -> void:
	enemy_sprite.modulate = Color(1.6, 1.6, 1.6)
	var tw := create_tween()
	tw.tween_property(enemy_sprite, "position", enemy_base + Vector2(14, 0), 0.04)
	tw.tween_property(enemy_sprite, "position", enemy_base - Vector2(14, 0), 0.06)
	tw.tween_property(enemy_sprite, "position", enemy_base, 0.04)
	tw.parallel().tween_property(enemy_sprite, "modulate", Color.WHITE, 0.15)

func _float_text(t: String, at: Vector2, col: Color) -> void:
	var l: Label = main.make_label(t, 44, col, true)
	l.add_theme_color_override("font_outline_color", main.INK)
	l.add_theme_constant_override("outline_size", 12)
	add_child(l)
	l.position = at - Vector2(60, 0)
	var tw := create_tween()
	tw.tween_property(l, "position:y", at.y - 90, 0.6)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.6).set_delay(0.25)
	tw.tween_callback(l.queue_free)
