extends Control
## 차례제 상소 전투
## 내 차례: 기력 3으로 상소(카드)를 낸다 → "차례 넘기기" → 상대 차례: 예고한 행동을 한다.
## 상대는 차례마다 기세가 한 칸씩 오르고, 다 차면 필살기를 쓴다. 고춧가루·곁치기로 기세를 꺾는다.

var main
var enemy_id := "walpae"
var on_win: Callable
var opts: Dictionary = {}
var ally: Dictionary = {}
const BATTLE_BG := {"jeong_shadow1": "naeuiwon", "jeong_shadow": "mapo_warehouse", "mapo_thug": "mapo_warehouse", "merchant_gang": "yanjing", "naegeumwi": "palace_night", "masked_henchman": "palace_night", "seohwi3": "castle", "haejeok": "sea", "cheong_merchant": "yanjing", "pirate_boss": "deck", "gatekeeper": "vault", "heukdu": "corridor", "heukdu1": "alley", "heukdu2": "den", "dogyeol": "alley", "baegun_mask": "stream", "shadow_s": "namsan_night", "baegun": "cheonsugak", "darae": "cheonsugak", "shadow": "yakbang", "seohwi": "yakbang", "seohwi2": "namsan_night"}

const BASE_ENERGY := 3
const HAND_SIZE := 5
const BEAT := 0.55          # 연출 한 박자

var enemy: Dictionary
var e_hp := 0
var e_block := 0
var e_charge := 0
var e_move_idx := 0
var intent: Dictionary
var energy := 0
var shield := 0
var turn := 0
var my_turn := false
var over := false
var draw_pile: Array = []
var discard: Array = []
var hand: Array = []

var enemy_sprite: TextureRect
var enemy_base := Vector2.ZERO
var e_hp_bar: ProgressBar
var e_hp_lbl: Label
var e_block_lbl: Label
var my_panel: Control
var top_panel: Control
var ip_panel: Control
var charge_row: HBoxContainer
var intent_lbl: Label
var p_hp_bar: ProgressBar
var p_hp_lbl: Label
var energy_lbl: Label
var shield_lbl: Label
var potion_btn: Button
var end_btn: Button
var flash: ColorRect
var card_row: HBoxContainer
var banner: Label

func _ready() -> void:
	enemy = GameData.ENEMIES[enemy_id].duplicate(true)
	# 난이도: 전체적으로 더 단단하고 아프게 + 장이 오를수록 잡졸은 더 강해진다
	var boss: bool = enemy.get("boss", false)
	var hk: float = 1.3 if boss else 1.4
	var dk: float = 1.2 if boss else 1.25
	if not boss and main.chapter > 1:
		hk *= 1.0 + 0.15 * (main.chapter - 1)
		dk *= 1.0 + 0.12 * (main.chapter - 1)
	if enemy_id != "darae":
		enemy["hp"] = int(round(enemy["hp"] * hk))
		for mv in enemy["moves"] + [enemy["heavy"]]:
			mv["v"] = int(round(mv["v"] * dk))
			if boss and mv["t"] == "atk":
				mv["v"] += 5   # 중간보스·대장은 공격이 더 아프게
		# 일반 적·중간보스 강화: 체력 +15%, 공격 +2, 장마다 공격 +1 더
		if not enemy_id in FINALS:
			enemy["hp"] = int(round(enemy["hp"] * 1.15))
			for mv in enemy["moves"] + [enemy["heavy"]]:
				if mv["t"] == "atk":
					mv["v"] += 2 + max(0, main.chapter - 1)
	# 난이도 조정: 모든 적 공격 -2 (최소 2)
	var cut := 2 + (5 if main.chapter == 7 else 0)   # 한양→화란 뱃길(7장)은 공격 -5 더
	for mv in enemy["moves"] + [enemy["heavy"]]:
		if mv["t"] == "atk":
			mv["v"] = max(2, int(mv["v"]) - cut)
	is_mid = boss and (not enemy_id in FINALS or enemy_id == "seohwi")
	e_hp = enemy["hp"]
	ally = {}   # 동료는 전투에 끼어들지 않는다 (대화로만 함께한다)

	var bg := TextureRect.new()
	var bgname: String = BATTLE_BG.get(enemy_id, "alley")
	# 백운의 성 안에서 싸울 때는 그 층 배경(성 안) 그대로
	if main.board != null and is_instance_valid(main.board) and "data" in main.board and main.board.data is Dictionary:
		var sbg: String = main.board.data.get("bg", "")
		if sbg in ["vault", "corridor", "cheonsugak", "podocheong"] and not (bgname in ["vault", "corridor", "cheonsugak"]):
			bgname = sbg
		elif sbg != "" and not enemy.get("boss", false):
			# 일반 적은 지금 걷고 있는 맵의 배경에서 싸운다 (보스는 정해 둔 장소 그대로)
			bgname = "mountain" if sbg == "title" else sbg
	# 싸우기 직전 대화에서 장소 그림을 보여 줬으면 그 그림에서 싸운다
	if main.last_dialog_bg != "":
		bgname = main.last_dialog_bg
		main.last_dialog_bg = ""
	var bt: Texture2D = main.backdrop(bgname)
	bg.texture = bt if bt else load("res://assets/ui/board_map.jpg")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.anchor_right = 1.0; bg.anchor_bottom = 1.0
	add_child(bg)
	var low := ColorRect.new()
	low.color = Color(0.1, 0.06, 0.04, 0.72)
	low.anchor_top = 1.0; low.anchor_right = 1.0; low.anchor_bottom = 1.0
	low.offset_top = -PANEL_TOP - 20
	low.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(low)

	var et: Texture2D = main.illust(enemy["sprite"])
	enemy_sprite = main.tex_rect(et if et else main.icon(enemy_id), Vector2(560, 700) if et else Vector2(360, 360))
	enemy_sprite.pivot_offset = enemy_sprite.size * Vector2(0.5, 1.0)
	add_child(enemy_sprite)
	main.tag_placeholder(enemy_sprite, enemy["sprite"])

	# 상대 정보
	var top := PanelContainer.new()
	top.add_theme_stylebox_override("panel", main.bar_style())
	top.anchor_right = 1.0
	top.offset_left = 4; top.offset_right = -4; top.offset_top = 4
	add_child(top)
	top_panel = top
	top.resized.connect(_layout)
	var tv := VBoxContainer.new()
	tv.add_theme_constant_override("separation", 4)
	top.add_child(tv)
	var nrow := HBoxContainer.new()
	tv.add_child(nrow)
	var nm: Label = main.make_label(enemy["name"], 36, main.GOLD, true)
	nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nrow.add_child(nm)
	e_block_lbl = main.make_label("", 26, Color("b8d4f0"), true)
	nrow.add_child(e_block_lbl)
	e_hp_bar = _bar(Color("a8261c"), 28)
	tv.add_child(e_hp_bar)
	e_hp_lbl = main.make_label("", 22, main.LIGHT)
	tv.add_child(e_hp_lbl)
	var crow := HBoxContainer.new()
	crow.add_theme_constant_override("separation", 8)
	tv.add_child(crow)
	crow.add_child(main.make_label("기세", 24, Color("e9c9a0"), true))
	charge_row = HBoxContainer.new()
	charge_row.add_theme_constant_override("separation", 6)
	charge_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	crow.add_child(charge_row)
	for i in int(enemy["charge"]):
		var seg := Panel.new()
		seg.custom_minimum_size = Vector2(0, 20)
		seg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		seg.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		charge_row.add_child(seg)

	# 상대 예고
	var ip := PanelContainer.new()
	ip.add_theme_stylebox_override("panel", main.plaque_style())
	ip.anchor_left = 0.5; ip.anchor_right = 0.5
	ip.anchor_top = 1.0; ip.anchor_bottom = 1.0
	ip.offset_top = -PANEL_TOP - 96; ip.offset_left = -250; ip.offset_right = 250; ip.offset_bottom = -PANEL_TOP - 26
	ip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ip)
	intent_lbl = main.make_label("", 28, main.GOLD, true)
	intent_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ip.add_child(intent_lbl)

	# 나
	var pp := PanelContainer.new()
	pp.add_theme_stylebox_override("panel", main.bar_style())
	pp.anchor_top = 1.0; pp.anchor_right = 1.0; pp.anchor_bottom = 1.0
	pp.offset_left = 4; pp.offset_right = -4; pp.offset_top = -PANEL_TOP; pp.offset_bottom = -CARD_H - 22
	pp.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 패널 빈 곳이 상소 터치를 가로채지 않게
	pp.grow_vertical = Control.GROW_DIRECTION_BEGIN  # 내용이 커져도 위로만 자라서 상소를 덮지 않음
	my_panel = pp
	ip_panel = ip
	pp.resized.connect(_layout)
	add_child(pp)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 14)
	pp.add_child(hb)
	var face: Texture2D = main.illust(main.face_name()) if not opts.has("me_name") else null
	if face:
		var fr: TextureRect = main.tex_rect(face, Vector2(116, 116))
		fr.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hb.add_child(fr)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	hb.add_child(info)
	var r1 := HBoxContainer.new()
	info.add_child(r1)
	var me: Label = main.make_label(opts.get("me_name", main.alias() if main.disguised() else main.hero_name), 30, main.GOLD, true)
	me.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r1.add_child(me)
	shield_lbl = main.make_label("", 26, Color("b8d4f0"), true)
	r1.add_child(shield_lbl)
	p_hp_bar = _bar(Color("4f7a4a"), 24)
	info.add_child(p_hp_bar)
	p_hp_lbl = main.make_label("", 22, main.LIGHT)
	info.add_child(p_hp_lbl)
	energy_lbl = main.make_label("", 30, Color("f0c040"), true)
	info.add_child(energy_lbl)
	var btns := VBoxContainer.new()
	btns.add_theme_constant_override("separation", 6)
	hb.add_child(btns)
	end_btn = main.make_button("차례\n넘기기", 24)
	end_btn.custom_minimum_size = Vector2(132, 100)
	btns.add_child(end_btn)
	end_btn.pressed.connect(_end_my_turn)
	potion_btn = main.make_button("", 22)
	potion_btn.custom_minimum_size = Vector2(132, 62)
	btns.add_child(potion_btn)
	potion_btn.pressed.connect(_use_potion)

	# 손패
	card_row = HBoxContainer.new()
	card_row.alignment = BoxContainer.ALIGNMENT_CENTER
	card_row.add_theme_constant_override("separation", 6)
	card_row.anchor_top = 1.0; card_row.anchor_bottom = 1.0; card_row.anchor_right = 1.0
	card_row.offset_top = -CARD_H - 14; card_row.offset_bottom = -14
	add_child(card_row)

	flash = ColorRect.new()
	flash.color = Color(0.7, 0.08, 0.05, 0.0)
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)

	banner = main.ink_text(main.make_label("", 80, main.LIGHT, true), 20)
	banner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(banner)

	for e in main.deck:
		draw_pile.append(e)
	draw_pile.shuffle()
	_pick_intent()
	resized.connect(_layout)
	_layout()
	_refresh()
	_start.call_deferred()

const CARD_H := 286
const PANEL_TOP := CARD_H + 22 + 196   # 화면 아래에서 내 정보 패널 윗변까지

const HIT_SFX := {"jumeok": "punch", "baldda": "kick", "gyeot": "punch_heavy", "nalchi": "punch"}

func _start() -> void:
	main.bgm("boss_battle" if enemy.get("boss", false) else "battle")
	main.sfx("drum_start")
	await _show_banner("맞서 싸워라!")
	shield = main.next_guard
	main.next_guard = 0
	var bonus: int = main.next_energy
	main.next_energy = 0
	_begin_my_turn(bonus)

var enemy_full := Vector2.ZERO   # 적 그림 원래 크기 (줄일 때 기준)

func _layout() -> void:
	if size.y < 200:
		return
	if enemy_full == Vector2.ZERO:
		enemy_full = enemy_sprite.custom_minimum_size if enemy_sprite.custom_minimum_size != Vector2.ZERO else enemy_sprite.size
	# 내 정보 패널 윗변 = 화면 아래 - 상소 줄 - 패널 높이 (패널 높이가 아직 0이면 기본값)
	var ph: float = my_panel.size.y if my_panel and my_panel.size.y > 40 else 196.0
	var ptop: float = size.y - CARD_H - 22 - ph
	# 다음 수 알림: 적 이름·체력 띠 바로 아래
	var tbot: float = (top_panel.position.y + top_panel.size.y) if top_panel and top_panel.size.y > 20 else 150.0
	if ip_panel:
		ip_panel.position.y = tbot + 8
	# 적 그림: 발끝이 내 정보 패널 바로 위에 닿게
	var bottom: float = ptop - 6
	var room: float = max(220.0, bottom - (tbot + 8 + (ip_panel.size.y if ip_panel else 70) + 8))
	var k: float = min(1.0, room / max(1.0, enemy_full.y))
	var sz := enemy_full * k
	enemy_sprite.custom_minimum_size = sz
	enemy_sprite.size = sz
	enemy_sprite.pivot_offset = sz * Vector2(0.5, 1.0)
	enemy_base = Vector2((size.x - sz.x) / 2.0, bottom - sz.y).floor()
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
	b.add_theme_stylebox_override("background", bgs)
	b.add_theme_stylebox_override("fill", fs)
	b.max_value = 1.0
	b.step = 0.0
	return b

func _show_banner(text: String) -> void:
	banner.text = text
	banner.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(banner, "modulate:a", 1.0, 0.25)
	tw.tween_interval(0.55)
	tw.tween_property(banner, "modulate:a", 0.0, 0.3)
	await tw.finished

# ── 상대 예고 ───────────────────────────────────────────
## 마지막 대결(장 끝 보스)들 — 여기는 강화·특수기 제외
const FINALS := ["baegun", "seohwi", "shadow", "darae"]
## 중간보스 특수기: 세 번째 차례마다 예고하고 쓴다
const SPECIALS := {
	"dogyeol": "pierce", "heukdu1": "multi", "heukdu2": "drain", "heukdu": "multi",
	"baegun_mask": "sap", "seohwi2": "multi",
	"shadow_s": "drain", "pirate_boss": "multi", "cheong_merchant": "sap", "seohwi": "glare", "seohwi3": "glare", "jeong_shadow": "drain"}
const SP_INFO := {
	"multi": {"n": "연타", "desc": "%d씩 세 번 공격"},
	"pierce": {"n": "방어 깨기", "desc": "막기를 무시하고 %d"},
	"drain": {"n": "흡혈", "desc": "공격 %d · 준 만큼 회복"},
	"sap": {"n": "기력 빼앗기", "desc": "공격 %d · 다음 차례 기력 -1"},
	"glare": {"n": "애체 반사", "desc": "공격 %d · 다음 상소 -1장"}}
var is_mid := false
var e_turn_no := 0
var sap_next := 0
var glare_next := 0

func _pick_intent() -> void:
	if is_mid and e_turn_no % 3 == 2 and e_charge < int(enemy["charge"]):
		var kind: String = SPECIALS.get(enemy_id, ["multi", "pierce", "drain", "sap"][enemy_id.hash() % 4])
		var base := 0
		for mv in enemy["moves"]:
			if mv["t"] == "atk":
				base = max(base, int(mv["v"]))
		var v: int = int(ceil(base * 0.45)) if kind == "multi" else (base if kind != "pierce" else int(base * 0.8))
		intent = {"n": SP_INFO[kind]["n"], "t": "atk", "v": v, "sp": kind}
		return
	if e_charge >= int(enemy["charge"]):
		intent = enemy["heavy"].duplicate()
		intent["heavy"] = true
	else:
		var moves: Array = enemy["moves"]
		intent = moves[e_move_idx % moves.size()].duplicate()

func _intent_text() -> String:
	var s := "다음 수: %s · " % intent["n"]
	if intent["t"] == "atk":
		s += "공격 %d" % intent["v"]
	else:
		s += "막기 %d" % intent["v"]
	if intent.get("heavy", false):
		s = "필살! " + s
	if intent.has("sp"):
		s = "특수기! %s · " % intent["n"] + SP_INFO[intent["sp"]]["desc"] % intent["v"]
	return s

# ── 내 차례 ─────────────────────────────────────────────
func _begin_my_turn(bonus := 0) -> void:
	if over:
		return
	turn += 1
	if turn > 1:
		await _show_banner("나의 차례")
	energy = max(1, BASE_ENERGY + bonus - sap_next)
	if sap_next > 0:
		_float_text("기력을 빼앗겼다! (-%d)" % sap_next, Vector2(size.x / 2, size.y * 0.6), Color("ff9a80"))
		sap_next = 0
	var hand_n: int = HAND_SIZE - glare_next
	if glare_next > 0:
		_float_text("애체 빛에 눈이 부시다! (상소 -1장)", Vector2(size.x / 2, size.y * 0.55), Color("ffe08a"))
		glare_next = 0
	for i in hand_n:
		_draw_one()
		await get_tree().create_timer(0.13).timeout
	my_turn = true
	_refresh()

func _draw_one() -> void:
	if draw_pile.is_empty():
		draw_pile = discard.duplicate()
		discard.clear()
		draw_pile.shuffle()
	if draw_pile.is_empty():
		return
	var e: Dictionary = draw_pile.pop_back()
	hand.append(e)
	main.sfx("card_draw", -8.0)
	var w: int = 134 if hand.size() <= 5 else int((size.x - 12 - 6 * (hand.size() - 1)) / hand.size())
	var b: Button = main.card_button(e, w, CARD_H)
	b.set_meta("entry", e)
	b.modulate.a = 0.0
	card_row.add_child(b)
	b.pressed.connect(func(): _play(b, e))
	create_tween().tween_property(b, "modulate:a", 1.0, 0.22)
	_refresh()

func _play(b: Button, e: Dictionary) -> void:
	if not my_turn or over:
		return
	var c: Dictionary = GameData.stats(e["id"], e["lv"])
	if energy < int(c["cost"]):
		_float_text("기력이 모자라요", Vector2(size.x / 2, size.y * 0.62), Color("f0a080"))
		var sh := create_tween()
		sh.tween_property(b, "position:x", b.position.x + 10, 0.05)
		sh.tween_property(b, "position:x", b.position.x, 0.05)
		return
	my_turn = false
	energy -= int(c["cost"])
	main.stat_card(e["id"])
	var hi := hand.find(e)
	if hi >= 0:
		hand.remove_at(hi)
	discard.append(e)
	_refresh()
	var tw := create_tween()
	tw.tween_property(b, "modulate", Color(1.3, 1.2, 1.0, 0.0), 0.16)
	await tw.finished
	card_row.remove_child(b)
	b.queue_free()
	if c.has("dmg"):
		main.sfx(HIT_SFX.get(e["id"], "punch"))
		_hit_enemy(int(c["dmg"]))
	if c.has("block"):
		shield += int(c["block"])
		main.sfx("block")
		_float_text("막기 +%d" % c["block"], Vector2(size.x / 2, size.y * 0.62), Color("b8d4f0"))
	if c.has("slow"):
		var before := e_charge
		e_charge = max(0, e_charge - int(c["slow"]))
		main.sfx("powder" if e["id"] == "gochu" else "whoosh")
		if before != e_charge:
			_float_text("기세가 꺾였다!", Vector2(size.x / 2, size.y * 0.22), Color("f0c040"))
		_pick_intent()
	if c.has("coin"):
		main.coins += int(c["coin"])
		_float_text("엽전 +%d" % c["coin"], Vector2(size.x / 2 + 80, size.y * 0.45), Color("f0c040"))
	await get_tree().create_timer(0.4).timeout
	if e_hp <= 0:
		_win()
		return
	my_turn = true
	_refresh()

func _hit_enemy(dmg: int) -> void:
	var through := dmg
	if e_block > 0:
		var absorbed: int = min(e_block, dmg)
		e_block -= absorbed
		through = dmg - absorbed
	e_hp = max(0, e_hp - through)
	_float_text("-%d" % through if through > 0 else "막혔다", enemy_sprite.position + Vector2(enemy_sprite.size.x / 2, 120), Color("ffdf6a"))
	enemy_sprite.modulate = Color(1.7, 1.6, 1.5)
	var tw := create_tween()
	tw.tween_property(enemy_sprite, "position", enemy_base + Vector2(18, 0), 0.06)
	tw.tween_property(enemy_sprite, "position", enemy_base - Vector2(14, 0), 0.08)
	tw.tween_property(enemy_sprite, "position", enemy_base, 0.08)
	tw.parallel().tween_property(enemy_sprite, "modulate", Color.WHITE, 0.25)
	_refresh()

var potion_at := 0
func _use_potion() -> void:
	if not my_turn or over or main.potions + main.potions_small <= 0 or main.hp >= main.max_hp:
		return
	if Time.get_ticks_msec() - potion_at < 600:   # 한 번 눌렀는데 두 번 마셔지지 않게
		return
	potion_at = Time.get_ticks_msec()
	if main.potions > 0 and main.potions_small > 0:
		main.popup_choices("어떤 약을 마실까요?", [{"text": "진한 탕약 · 체력 +40 (%d병)" % main.potions},
			{"text": "묽은 탕약 · 체력 +20 (%d병)" % main.potions_small}, {"text": "그만두기"}], func(k: int):
				if k < 2:
					_drink(k == 0))
		return
	_drink(main.potions > 0)

func _drink(big: bool) -> void:
	if big:
		main.potions -= 1
	else:
		main.potions_small -= 1
	var before: int = main.hp
	main.hp = min(main.max_hp, main.hp + (40 if big else 20))
	main.sfx("potion")
	_float_text("+%d" % (main.hp - before), Vector2(size.x / 2, size.y * 0.62), Color("8fd0a0"))
	_refresh()

func _end_my_turn() -> void:
	if not my_turn or over:
		return
	my_turn = false
	_refresh()
	var kids := card_row.get_children()
	for i in kids.size():
		create_tween().tween_property(kids[i], "modulate:a", 0.0, 0.2).set_delay(i * 0.05)
	await get_tree().create_timer(0.5).timeout
	for b in kids:
		card_row.remove_child(b)
		b.queue_free()
	discard.append_array(hand)
	hand.clear()
	_refresh()
	if not ally.is_empty():
		await _ally_turn()
		if e_hp <= 0:
			_win()
			return
	_enemy_turn()

func _ally_turn() -> void:
	await _show_banner(ally["name"] + "의 차례")
	_float_text(ally.get("line", ""), Vector2(size.x / 2, size.y * 0.25), Color("f0c040"))
	await get_tree().create_timer(0.35).timeout
	main.sfx("punch_heavy")
	_hit_enemy(int(ally.get("dmg", 5)))
	if ally.has("block"):
		shield += int(ally["block"])
		main.sfx("block")
	_refresh()
	await get_tree().create_timer(BEAT).timeout

# ── 상대 차례 ───────────────────────────────────────────
func _enemy_turn() -> void:
	main.sfx("whoosh", -6.0)
	await _show_banner("상대의 차례")
	var act := intent
	_float_text(act["n"] + "!", Vector2(size.x / 2, size.y * 0.25), Color("ff9a80") if act.get("heavy", false) else main.LIGHT)
	await get_tree().create_timer(BEAT).timeout
	if act["t"] == "atk":
		var tw := create_tween()
		tw.tween_property(enemy_sprite, "scale", Vector2(1.06, 1.06), 0.18)
		tw.parallel().tween_property(enemy_sprite, "position", enemy_base + Vector2(0, 36), 0.18)
		tw.tween_property(enemy_sprite, "scale", Vector2.ONE, 0.22)
		tw.parallel().tween_property(enemy_sprite, "position", enemy_base, 0.22)
		await get_tree().create_timer(0.18).timeout
		var dmg := 0
		var hits: int = 3 if act.get("sp", "") == "multi" else 1
		for h in hits:
			var d: int = int(act["v"])
			if act.get("sp", "") != "pierce":
				var blocked: int = min(shield, d)
				shield -= blocked
				d -= blocked
			dmg += d
			if hits > 1 and h < hits - 1:
				main.sfx("punch")
				await get_tree().create_timer(0.15).timeout
		main.hp = max(0, main.hp - dmg)
		if dmg > 0: took_dmg = true
		if act.get("sp", "") == "drain" and dmg > 0:
			e_hp = min(int(enemy["hp"]), e_hp + dmg)
			_float_text("+%d" % dmg, enemy_sprite.position + Vector2(enemy_sprite.size.x / 2, 120), Color("9ae08a"))
		if act.get("sp", "") == "sap":
			sap_next = 1
		if act.get("sp", "") == "glare":
			glare_next = 1
		main.sfx("hurt_heavy" if act.get("heavy", false) else ("hurt" if dmg > 0 else "block"))
		if dmg > 0:
			flash.color.a = 0.45 if act.get("heavy", false) else 0.3
			create_tween().tween_property(flash, "color:a", 0.0, 0.45)
			_float_text("-%d" % dmg, Vector2(size.x / 2, size.y * 0.66), Color("ff6a5a"))
		else:
			_float_text("모두 막아냈다!", Vector2(size.x / 2, size.y * 0.66), Color("b8d4f0"))
	else:
		e_block += int(act["v"])
		main.sfx("block")
		_float_text("막기 +%d" % act["v"], enemy_sprite.position + Vector2(enemy_sprite.size.x / 2, 160), Color("b8d4f0"))
	e_turn_no += 1
	if act.get("heavy", false):
		e_charge = 0
	elif not act.has("sp"):
		e_charge += 1
		e_move_idx += 1
	_pick_intent()
	_refresh()
	await get_tree().create_timer(BEAT).timeout
	if main.hp <= 0:
		over = true
		main.sfx("gong")
		if opts.get("lose_ok", false):
			main.stat_add("losses")
			await _show_banner("패배…")
			main.hp = max(1, main.max_hp / 2)
			main.end_battle(self)
			if on_win.is_valid():
				on_win.call()
			return
		if enemy.get("boss", false): main.stat_add("boss_losses")
		main.game_over(main.fmt("{name|은} 그만 쓰러지고 말았다…"))
		return
	_begin_my_turn()

# ── 끝 ──────────────────────────────────────────────────
var took_dmg := false

func _win() -> void:
	over = true
	main.stat_add("wins")
	# 칭호용 기록
	if not enemy.get("boss", false): main.stat_add("kills")
	if turn <= 1: main.stat_add("one_turn")
	if not took_dmg: main.stat_add("no_dmg")
	if main.hp <= 5: main.stat_add("close_call")
	main.sfx("victory")
	main.coins += int(enemy["coin"])
	var tw := create_tween()
	tw.tween_property(enemy_sprite, "modulate:a", 0.0, 0.7)
	await tw.finished
	await _show_banner("승리!")
	if opts.get("no_reward", false):
		if enemy["coin"] > 0:
			main.popup("%s을(를) 물리쳤다!\n\n(엽전 +%d냥)" % [enemy["name"], enemy["coin"]], "계속", func():
				main.end_battle(self)
				if on_win.is_valid():
					on_win.call(), "", "", "", true)
		else:
			main.end_battle(self)
			if on_win.is_valid():
				on_win.call()
		return
	main.popup("%s을(를) 물리쳤다!\n\n(엽전 +%d냥)" % [enemy["name"], enemy["coin"]], "전리품 챙기기", func():
		main.choose_reward(func():
			main.end_battle(self)
			if on_win.is_valid():
				on_win.call()), "", "", "", true)

func _refresh() -> void:
	e_hp_bar.value = float(e_hp) / float(enemy["hp"])
	e_hp_lbl.text = "체력 %d / %d" % [e_hp, enemy["hp"]]
	e_block_lbl.text = "막기 %d" % e_block if e_block > 0 else ""
	for i in charge_row.get_child_count():
		var seg: Panel = charge_row.get_child(i)
		var sb := StyleBoxFlat.new()
		sb.set_corner_radius_all(3)
		sb.border_color = main.GOLD; sb.set_border_width_all(2)
		sb.bg_color = Color("d9602a") if i < e_charge else Color("2a1a10")
		seg.add_theme_stylebox_override("panel", sb)
	intent_lbl.text = _intent_text()
	intent_lbl.add_theme_color_override("font_color", Color("ff9a80") if (intent.get("heavy", false) or intent.has("sp")) else main.GOLD)
	p_hp_bar.value = float(main.hp) / float(main.max_hp)
	p_hp_lbl.text = "체력 %d / %d · 남은 상소 %d" % [main.hp, main.max_hp, draw_pile.size()]
	energy_lbl.text = "기력 " + "●".repeat(energy) + "○".repeat(max(0, BASE_ENERGY - energy))
	shield_lbl.text = "막기 %d" % shield if shield > 0 else ""
	potion_btn.text = "약병 %d" % (main.potions + main.potions_small)
	potion_btn.disabled = not my_turn or main.potions + main.potions_small <= 0
	end_btn.disabled = not my_turn
	for k in card_row.get_children():
		if k.has_meta("entry"):
			var en: Dictionary = k.get_meta("entry")
			var gone: bool = not hand.has(en)
			k.disabled = gone or not my_turn
			k.mouse_filter = Control.MOUSE_FILTER_IGNORE if gone else Control.MOUSE_FILTER_STOP
			k.self_modulate = Color(1, 1, 1) if (gone or energy >= int(GameData.stats(en["id"], en["lv"])["cost"])) else Color(0.6, 0.6, 0.6)

func _float_text(t: String, at: Vector2, col: Color) -> void:
	var l: Label = main.ink_text(main.make_label(t, 44, col, true), 12)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	l.position = at - Vector2(80, 0)
	var tw := create_tween()
	tw.tween_property(l, "position:y", at.y - 100, 0.9)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.9).set_delay(0.4)
	tw.tween_callback(l.queue_free)
