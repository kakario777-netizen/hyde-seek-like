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

	var bg := TextureRect.new()
	var bt: Texture2D = main.backdrop("alley")
	bg.texture = bt if bt else load("res://assets/ui/board_map.jpg")
	bg.modulate = Color.WHITE if bt else Color(0.3, 0.27, 0.3)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.anchor_right = 1.0; bg.anchor_bottom = 0.6
	add_child(bg)

	# 적 (일러스트가 없으면 먹 그림 아이콘)
	var et: Texture2D = main.illust(enemy["sprite"])
	enemy_sprite = main.tex_rect(et if et else main.icon(enemy["sprite"]), Vector2(520, 650) if et else Vector2(360, 360))
	add_child(enemy_sprite)

	var top := PanelContainer.new()
	top.add_theme_stylebox_override("panel", main.bar_style())
	top.anchor_right = 1.0
	top.offset_left = 6; top.offset_right = -6; top.offset_top = 6
	add_child(top)
	var tv := VBoxContainer.new()
	tv.add_theme_constant_override("separation", 6)
	top.add_child(tv)
	tv.add_child(main.make_label(enemy["name"], 36, main.GOLD, true))
	e_hp_bar = _bar(Color("a8261c"), 30)
	tv.add_child(e_hp_bar)
	e_hp_lbl = main.make_label("", 24, main.LIGHT)
	tv.add_child(e_hp_lbl)
	tv.add_child(main.make_label("공격 준비", 24, Color("e9c9a0")))
	e_gauge_bar = _bar(Color("d98a2a"), 22)
	tv.add_child(e_gauge_bar)

	# 주인공 정보
	var pp := PanelContainer.new()
	pp.add_theme_stylebox_override("panel", main.bar_style())
	pp.anchor_top = 0.6; pp.anchor_right = 1.0; pp.anchor_bottom = 0.6
	pp.offset_left = 6; pp.offset_right = -6; pp.offset_top = -40
	add_child(pp)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 18)
	pp.add_child(hb)
	var face_tex: Texture2D = main.illust("face_token")
	var face := PanelContainer.new()
	var fsb := StyleBoxFlat.new()
	fsb.bg_color = Color("9a2c22"); fsb.border_color = main.GOLD; fsb.set_border_width_all(4); fsb.set_corner_radius_all(60)
	face.add_theme_stylebox_override("panel", fsb)
	face.custom_minimum_size = Vector2(110, 110)
	var fl: Label = main.make_label(main.hero_name.left(1), 54, main.GOLD, true)
	fl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	face.add_child(fl)
	if face_tex:
		hb.add_child(main.tex_rect(face_tex, Vector2(120, 120)))
	else:
		hb.add_child(face)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 4)
	hb.add_child(info)
	info.add_child(main.make_label(main.alias(), 32, main.GOLD, true))
	p_hp_bar = _bar(Color("4f7a4a"), 26)
	info.add_child(p_hp_bar)
	p_hp_lbl = main.make_label("", 24, main.LIGHT)
	info.add_child(p_hp_lbl)
	var row := HBoxContainer.new()
	info.add_child(row)
	energy_lbl = main.make_label("", 30, Color("f0c040"), true)
	energy_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(energy_lbl)
	shield_lbl = main.make_label("", 26, Color("b8d4f0"), true)
	row.add_child(shield_lbl)

	# 손패 (상소문)
	card_row = HBoxContainer.new()
	card_row.alignment = BoxContainer.ALIGNMENT_CENTER
	card_row.add_theme_constant_override("separation", 10)
	card_row.anchor_top = 1.0; card_row.anchor_bottom = 1.0; card_row.anchor_right = 1.0
	card_row.offset_top = -306; card_row.offset_bottom = -16
	add_child(card_row)
	for i in HAND_SIZE:
		hand.append({})
		card_row.add_child(Button.new())
	for i in HAND_SIZE:
		_draw_card(i)

	flash = ColorRect.new()
	flash.color = Color(0.7, 0.08, 0.05, 0.0)
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)

	banner = main.ink_text(main.make_label("맞서 싸워라!", 84, main.LIGHT, true), 20)
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
	enemy_base = Vector2((size.x - enemy_sprite.size.x) / 2.0, size.y * 0.6 - enemy_sprite.size.y - 10).floor()
	enemy_sprite.position = enemy_base

func _bar(col: Color, h: int) -> ProgressBar:
	var b := ProgressBar.new()
	b.show_percentage = false
	b.custom_minimum_size = Vector2(0, h)
	var bgs := StyleBoxFlat.new()
	bgs.bg_color = Color("2a1a10"); bgs.border_color = main.GOLD; bgs.set_border_width_all(3)
	bgs.set_corner_radius_all(4)
	var fs := StyleBoxFlat.new()
	fs.bg_color = col; fs.set_corner_radius_all(3)
	fs.border_color = Color(col.lightened(0.3), 0.6); fs.border_width_top = 3
	b.add_theme_stylebox_override("background", bgs)
	b.add_theme_stylebox_override("fill", fs)
	b.max_value = 1.0
	b.step = 0.0
	return b

# ── 카드 ────────────────────────────────────────────────
func _draw_card(slot: int) -> void:
	var pool: Array = main.deck.duplicate()
	if main.potions > 0:
		pool.append({"id": "yak", "lv": 1})
		pool.append({"id": "yak", "lv": 1})
	var entry: Dictionary = pool.pick_random()
	hand[slot] = entry
	var old: Button = card_row.get_child(slot)
	var b: Button = main.card_button(entry, 170, 284)
	card_row.add_child(b)
	card_row.move_child(b, slot)
	old.queue_free()
	card_row.remove_child(old)
	b.pressed.connect(func(): _play(slot))
	b.pivot_offset = b.custom_minimum_size / 2
	b.scale = Vector2(0.6, 0.6)
	create_tween().tween_property(b, "scale", Vector2.ONE, 0.15)

func _play(slot: int) -> void:
	if not running:
		return
	var entry: Dictionary = hand[slot]
	var c: Dictionary = GameData.stats(entry["id"], entry["lv"])
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
	if c.has("coin"):
		main.coins += int(c["coin"])
		_float_text("엽전 +%d" % c["coin"], Vector2(size.x / 2 + 80, size.y * 0.5), Color("f0c040"))
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
	if main.hp <= 0 and running:
		running = false
		main.game_over(main.fmt("{alias|은} 그만 쓰러지고 말았다…"))

func _win() -> void:
	running = false
	main.coins += int(enemy["coin"])
	var tw := create_tween()
	tw.tween_property(enemy_sprite, "modulate:a", 0.0, 0.5)
	tw.tween_callback(func():
		main.popup("%s을(를) 물리쳤다!\n\n(엽전 +%d냥)" % [enemy["name"], enemy["coin"]], "전리품 챙기기", func():
			main.choose_reward(func():
				main.end_battle(self)
				if on_win.is_valid():
					on_win.call())))

func _refresh() -> void:
	e_hp_bar.value = float(e_hp) / float(enemy["hp"])
	e_hp_lbl.text = "체력 %d / %d" % [e_hp, enemy["hp"]]
	e_gauge_bar.value = e_gauge
	p_hp_bar.value = float(main.hp) / float(main.max_hp)
	p_hp_lbl.text = "체력 %d / %d    약병 %d" % [main.hp, main.max_hp, main.potions]
	var full := int(energy)
	energy_lbl.text = "기력 " + "●".repeat(full) + "○".repeat(MAX_ENERGY - full)
	shield_lbl.text = "막기 %d" % shield if shield > 0 else ""
	for i in HAND_SIZE:
		var b: Button = card_row.get_child(i)
		if not hand[i].is_empty():
			b.disabled = energy < GameData.CARDS[hand[i]["id"]]["cost"] or not running

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
