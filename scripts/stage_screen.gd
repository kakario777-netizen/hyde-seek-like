extends Control
## 작은 맵(쿼터뷰) 스테이지: 행보 상소(1~6칸)로 길을 따라 나아간다.
## 붉은 칸 = 감시꾼의 눈길. 그 칸에서 멈추면 싸움. 길을 막은 적은 지나갈 수 없다.

var main
var restore: Dictionary = {}

const TW := 160.0
const TH := 80.0
const STEP_VALUES := [1, 2, 3, 4, 5, 6]
const HOP_TIME := 0.32
const STEP_PAUSE := 0.12
const BLOCKERS := ["walpae", "pojol", "boss"]

var cfg: Dictionary
var stage_cfg: Dictionary
var data: Dictionary
var tiles: Array = []
var guards: Array = []
var pos := 0
var turns_left := 10
var busy := false
var cleared := {}
var guards_done := {}
var brew_btn: Button = null
var herbs_got := 0
var herbs_total := 0
var talk_idx := 0

var view: Control
var world: Control
var overlay: Control
var token: Control
var token_pic: TextureRect
var tile_nodes := {}
var ent_nodes := {}
var guard_nodes := {}
var cam_tween: Tween
var origin := Vector2.ZERO
var hud: PanelContainer
var tray: PanelContainer
var title_lbl: Label
var info_lbl: Label
var clock_lbl: Label
var hint_label: Label
var card_row: HBoxContainer

func _ready() -> void:
	cfg = main.ch_cfg()
	if not main.sub_stage.is_empty():   # 만리길 판에서 들어온 여정 맵
		stage_cfg = main.sub_stage
	else:
		var stages: Array = cfg["stages"]
		stage_cfg = stages[clampi(main.stage_idx, 0, stages.size() - 1)]
	data = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/stages/%s.json" % stage_cfg["map"]))
	tiles = data["tiles"]
	guards = data["guards"]
	turns_left = int(data["turns"])
	map_seed = int(restore.get("seed", 0)) if not restore.is_empty() else 0
	if map_seed == 0:
		map_seed = randi() % 2000000000 + 1
	_randomize_layout(map_seed)
	for t in tiles:
		if t.get("herb", false):
			herbs_total += 1
	if not restore.is_empty():
		pos = int(restore.get("pos", 0))
		turns_left = int(restore.get("turns", turns_left))
		herbs_got = int(restore.get("herbs", 0))
		talk_idx = int(restore.get("talk_idx", 0))
		for k in restore.get("cleared", []):
			cleared[int(k)] = true
		for k in restore.get("guards_done", []):
			guards_done[int(k)] = true
		for k in restore.get("visited", []):
			visited[int(k)] = true
		errand_names = restore.get("errand", []).duplicate()
		if pos >= tiles.size():
			pos = main_len - 2
		if not restore.has("visited"):
			for i in mini(pos, main_len):
				visited[i] = true
	else:
		turns_left = (main_len + 2) / 3 + 2
	visited[pos] = true
	if "maptest" in OS.get_cmdline_user_args():
		var cs: Array = []
		for i in tiles.size():
			if tiles[i]["type"] in ["walpae", "pojol", "talk", "shop", "boss"]:
				cs.append(i)
		for g in guards:
			cs.append(int(g["at"]))
		var bad := 0
		for a in cs.size():
			for b in range(a + 1, cs.size()):
				if _cheb(cs[a], cs[b]) < 2:
					bad += 1
		var zc := {}
		for g in guards:
			for z in g["zone"]:
				if zc.has(z): bad += 100
				zc[z] = true
		var occ: Array = []
		for c in cs:
			occ.append([c, false])
		var hid := 0
		var ch_hid := 0
		for i in tiles.size():
			var ev: bool = tiles[i]["type"] in ["buff", "debuff", "item", "trap", "rest", "spike"] or tiles[i].get("herb", false)
			if ev and _behind_char(i, occ):
				hid += 1
		for a in cs.size():
			for b in cs.size():
				if a != b and _covers(cs[a], cs[b]):
					ch_hid += 1
		var evn := 0
		for t in tiles:
			if t["type"] in ["buff", "debuff", "item", "trap", "rest", "spike"]:
				evn += 1
		var orig_ev := 0
		for t in data["tiles"]:
			if t["type"] in ["buff", "debuff", "item", "trap", "rest", "spike"]:
				orig_ev += 1
		print("MAPTEST hidden_icons=", hid, " char_overlap=", ch_hid, " events=", evn, "/", orig_ev, " herbs=", herbs_total)
		print("MAPTEST ", stage_cfg["map"], " chars=", cs.size(), " guards=", guards.size(), " forks=", tiles.size() - main_len, " bad=", bad)

	var bgr := TextureRect.new()
	bgr.texture = main.backdrop(data.get("bg", "street_ink"))
	bgr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bgr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bgr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bgr.modulate = Color(0.32, 0.27, 0.28)
	bgr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bgr)

	view = Control.new()
	view.clip_contents = true
	view.mouse_filter = Control.MOUSE_FILTER_STOP
	view.gui_input.connect(_on_view_input)
	add_child(view)
	world = Control.new()
	world.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view.add_child(world)
	_build_world()

	_build_hud()
	_build_tray()
	resized.connect(_layout)
	_layout.call_deferred()
	_intro.call_deferred()

# ── 맵 그리기 ───────────────────────────────────────────
func _iso(x: float, y: float) -> Vector2:
	return origin + Vector2((x - y) * TW / 2.0, (x + y) * TH / 2.0)

func tile_center(i: int) -> Vector2:
	return _iso(tiles[i]["x"], tiles[i]["y"]) + Vector2(0, TH / 2.0)

func _guard_center(g: Dictionary) -> Vector2:
	return _iso(g["x"], g["y"]) + Vector2(0, TH / 2.0)

func _build_world() -> void:
	var cells := []
	for i in tiles.size():
		cells.append({"x": tiles[i]["x"], "y": tiles[i]["y"], "i": i})
	for g in guards:
		if not g.get("on_path", false):
			cells.append({"x": g["x"], "y": g["y"], "i": -1})
	var minx := 1e9; var maxx := -1e9; var miny := 1e9; var maxy := -1e9
	for c in cells:
		var p := Vector2((c["x"] - c["y"]) * TW / 2.0, (c["x"] + c["y"]) * TH / 2.0)
		minx = min(minx, p.x); maxx = max(maxx, p.x); miny = min(miny, p.y); maxy = max(maxy, p.y)
	origin = Vector2(-minx + TW / 2.0 + 400, -miny + 420)
	world.size = Vector2(maxx - minx + TW + 800, maxy - miny + TH + 900)

	cells.sort_custom(func(a, b): return a["x"] + a["y"] < b["x"] + b["y"])
	var tex: Texture2D = load("res://assets/ui/tiles/tile_%s.png" % data.get("tile", "stone"))
	for c in cells:
		var tr := TextureRect.new()
		tr.texture = tex
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tr.position = _iso(c["x"], c["y"]) - Vector2(TW / 2.0, 0)
		if c["i"] < 0:
			tr.modulate = Color(0.7, 0.66, 0.66)
		world.add_child(tr)
		if c["i"] >= 0:
			tile_nodes[c["i"]] = tr

	overlay = Control.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.size = world.size
	overlay.draw.connect(_draw_overlay)
	world.add_child(overlay)

	# 장식·인물: 앞뒤 순서대로
	var ents := []
	for i in tiles.size():
		ents.append({"d": tiles[i]["x"] + tiles[i]["y"], "kind": "tile", "i": i})
	for gi in guards.size():
		ents.append({"d": guards[gi]["x"] + guards[gi]["y"], "kind": "guard", "i": gi})
	ents.sort_custom(func(a, b): return a["d"] < b["d"])
	for e in ents:
		if e["kind"] == "tile":
			_make_tile_ent(e["i"])
		else:
			_make_guard(e["i"])
	var comp: String = main.companion()
	if comp != "" and main.chibi_only(comp) != null:
		follower = Control.new()
		follower.mouse_filter = Control.MOUSE_FILTER_IGNORE
		follower.add_child(_sprite(comp, 150))
		follower.position = tile_center(_behind(pos))
		world.add_child(follower)
	token = _make_token()
	token.position = tile_center(pos)
	world.add_child(token)

## 맵 위 인물은 모두 같은 키로 (보스만 조금 크게)
const MAP_H := 150.0
## 데포르메마다 그림 높이 = 몸 키가 되도록 보정 (앉은 자세·아이·소품이 머리 위로 솟은 그림)
const CHIBI_SCALE := {"cheong_merchant": 0.98, "pirate_captain": 1.04, "redhair_sailor": 0.95, "pojol": 1.12, "addict": 0.86, "baegun": 0.86, "dutch_child": 0.8, "dutch_child_sick": 0.66,
	"rat": 0.62, "king": 1.04, "seohwi": 0.96, "shadow": 1.04, "dogyeol": 1.04, "heo": 1.04, "yeotjangsu": 0.98}

func _sprite(pic: String, h: float) -> TextureRect:
	h = MAP_H
	var ck: String = main.CHIBI_OF.get(pic, pic)
	if main.chibi_only(pic) != null:
		h = MAP_H * CHIBI_SCALE.get(ck, 1.0)
	var t: Texture2D = main.chibi(pic)
	if t == null:
		t = main.illust(pic)
	if t == null:
		t = main.icon("walpae")
	var w: float = h * t.get_width() / max(1.0, float(t.get_height()))
	var r: TextureRect = main.tex_rect(t, Vector2(w, h))
	r.position = Vector2(-w / 2.0, -h + 8)
	return r

func _make_tile_ent(i: int) -> void:
	var t: Dictionary = tiles[i]
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.position = tile_center(i)
	var typ: String = t["type"]
	match typ:
		"spike":
			var s: TextureRect = main.tex_rect(load("res://assets/ui/tiles/deco_spike.png"), Vector2(TW, 110))
			s.position = Vector2(-TW / 2.0, -80)
			root.add_child(s)
		"goal":
			var g: TextureRect = main.tex_rect(load("res://assets/ui/tiles/deco_gate.png"), Vector2(TW * 1.3, TW * 1.3))
			g.position = Vector2(-TW * 0.65, -TW * 1.3 + 46)
			root.add_child(g)
		"walpae", "pojol":
			var eid := _enemy_id(typ)
			root.add_child(_sprite(GameData.ENEMIES[eid]["sprite"], 170))
			root.add_child(_badge("walpae" if typ == "walpae" else "pojol", Vector2(-22, -210), Color("f3d0c8")))
		"boss":
			root.add_child(_sprite(GameData.ENEMIES[t["battle"]]["sprite"], 210))
			root.add_child(_badge("walpae", Vector2(-22, -250), Color("ffb0a0")))
		"talk":
			var tk: Dictionary = _talk_at(i)
			var pic: String = tk.get("pic", WHO_PIC.get(tk.get("who", ""), ""))
			if pic != "" and main.illust(pic) != null:
				root.add_child(_sprite(pic, 165))
				root.add_child(_badge("talk", Vector2(-24, -MAP_H - 40), Color("f3e6c8")))
			else:
				root.add_child(_badge("talk", Vector2(-24, -70), Color("f3e6c8")))
		"patient":
			root.add_child(_sprite(_patient_pic(i), 160))
			root.add_child(_badge("rest", Vector2(-24, -MAP_H - 40), Color("f3e6c8")))
		"shop":
			root.add_child(_sprite("yakjae", 150) if main.illust("yakjae") != null else Control.new())
			root.add_child(_badge("shop", Vector2(-24, -MAP_H - 40), Color("f3e6c8")))
		"item", "buff", "debuff", "trap", "rest":
			root.add_child(_badge(typ, Vector2(-24, -70), Color("f3e6c8")))
	if t.has("errand"):
		var eb := PanelContainer.new()
		eb.add_theme_stylebox_override("panel", main.plaque_style())
		eb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var el: Label = main.make_label("약재\n" + str(t["errand"]), 22, main.GOLD, true)
		el.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		eb.add_child(el)
		eb.position = Vector2(-40, -96)
		eb.name = "Errand"
		root.add_child(eb)
		if str(t["errand"]) in errand_names:
			eb.visible = false
	if t.get("herb", false):
		var h: TextureRect = main.tex_rect(load("res://assets/ui/tiles/deco_herb.png"), Vector2(64, 78))
		h.position = Vector2(-10, -64)
		h.name = "Herb"
		root.add_child(h)
		if typ == "empty":
			pass
	world.add_child(root)
	ent_nodes[i] = root
	if cleared.has(i):
		_hide_ent(i, false)

func _badge(ic: String, at: Vector2, bgcol: Color) -> PanelContainer:
	var badge := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = bgcol; sb.border_color = Color("5a3a1e"); sb.set_border_width_all(3)
	sb.set_corner_radius_all(40); sb.set_content_margin_all(4)
	sb.shadow_color = Color(0, 0, 0, 0.4); sb.shadow_size = 5
	badge.add_theme_stylebox_override("panel", sb)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_child(main.tex_rect(main.icon(ic), Vector2(40, 40)))
	badge.position = at
	return badge

func _make_guard(gi: int) -> void:
	var g: Dictionary = guards[gi]
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.position = _guard_center(g)
	root.add_child(_sprite(GameData.ENEMIES[_enemy_id(g["kind"])]["sprite"], 165))
	world.add_child(root)
	guard_nodes[gi] = root
	if guards_done.has(gi):
		root.visible = false

func _make_token() -> Control:
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sh := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0.4); sb.set_corner_radius_all(30)
	sh.add_theme_stylebox_override("panel", sb)
	sh.size = Vector2(70, 22); sh.position = Vector2(-35, -10)
	sh.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(sh)
	var tk: Texture2D = main.illust(main.token_name())
	var ck: String = "hero_adult" if main.chapter >= 9 else ("hero_disguise" if main.chapter in main.DISGUISED else "hero")
	if main.chapter in main.COURT_CHAPTERS and ResourceLoader.exists("res://assets/chibi/hero_court.png"):
		ck = "hero_court"
	if stage_cfg.has("token"):   # 이 맵은 다른 인물로 걷는다 (예: 포도청 수련의 서휘)
		ck = stage_cfg["token"]
	if main.chibi_only(ck) != null:
		tk = main.chibi_only(ck)
	token_pic = main.tex_rect(tk, Vector2(132, 140))
	token_pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	token_pic.position = Vector2(-66, -132)
	token_pic.pivot_offset = Vector2(66, 140)
	# 주인공 말도 다른 인물과 같은 키
	var tw_: float = MAP_H * tk.get_width() / max(1.0, float(tk.get_height()))
	token_pic.custom_minimum_size = Vector2(tw_, MAP_H); token_pic.size = Vector2(tw_, MAP_H)
	token_pic.position = Vector2(-tw_ / 2.0, -MAP_H + 8); token_pic.pivot_offset = Vector2(tw_ / 2.0, MAP_H)
	root.add_child(token_pic)
	return root

func _diamond(c: Vector2, shrink := 0.0) -> PackedVector2Array:
	var hw := TW / 2.0 - shrink; var hh := TH / 2.0 - shrink / 2.0
	return PackedVector2Array([c + Vector2(0, -hh), c + Vector2(hw, 0), c + Vector2(0, hh), c + Vector2(-hw, 0)])

func _draw_overlay() -> void:
	for gi in guards.size():
		if guards_done.has(gi):
			continue
		for k in guards[gi]["zone"]:
			overlay.draw_colored_polygon(_diamond(tile_center(int(k)), 6), Color(0.85, 0.15, 0.1, 0.45))
	for i in visited:
		if i != pos:
			overlay.draw_colored_polygon(_diamond(tile_center(i), 30), Color(0.15, 0.1, 0.05, 0.25))
	for o in way_opts:
		overlay.draw_colored_polygon(_diamond(tile_center(o), 4), Color(1, 0.85, 0.3, 0.45))
		overlay.draw_polyline(_closed(_diamond(tile_center(o), 4)), Color(1, 0.9, 0.4, 1), 4.0)
	overlay.draw_colored_polygon(_diamond(tile_center(pos), 4), Color(0.3, 0.85, 0.4, 0.4))
	overlay.draw_polyline(_closed(_diamond(tile_center(pos), 4)), Color(0.5, 1, 0.6, 0.9), 3.0)

func _closed(p: PackedVector2Array) -> PackedVector2Array:
	var q := p.duplicate(); q.append(p[0]); return q

func _enemy_id(t: String) -> String:
	var f: Dictionary = stage_cfg.get("foes", {})
	if f.has(t):
		return f[t]
	return StoryData.ENEMY_MAP.get(main.chapter, {}).get(t, t)

## 들어올 때마다 길 모양·사건·적 배치를 새로 섞는다 (저장하면 같은 배치로 이어짐)
## 칸 수는 그대로 두고, 길 2~3군데를 두 갈래로 갈라졌다 다시 합쳐지게 만든다.
var map_seed := 0
var main_len := 0          # 본길 칸 수 (0..main_len-1, 마지막이 대문)
var dist_goal: Array = []  # 각 칸에서 대문까지 최단 칸 수
var visited := {}
var way_opts: Array = []
signal way_chosen(i: int)

func _d(arr: Array, i: int) -> Vector2i:
	return Vector2i(int(arr[i + 1]["x"]) - int(arr[i]["x"]), int(arr[i + 1]["y"]) - int(arr[i]["y"]))

func _shuffle(rng: RandomNumberGenerator, a: Array) -> void:
	for i in range(a.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = a[i]; a[i] = a[j]; a[j] = tmp

func nbrs(i: int) -> Array:
	return tiles[i]["next"] + tiles[i]["prev"]

func _bfs(from: Array, undirected: bool, back := false) -> Array:
	var dist: Array = []
	dist.resize(tiles.size()); dist.fill(9999)
	var q: Array = []
	for f in from:
		dist[f] = 0; q.append(f)
	while not q.is_empty():
		var c: int = q.pop_front()
		var ns: Array = nbrs(c) if undirected else (tiles[c]["prev"] if back else tiles[c]["next"])
		for x in ns:
			if dist[x] > dist[c] + 1:
				dist[x] = dist[c] + 1; q.append(x)
	return dist

func _randomize_layout(s: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = s
	var orig: Array = tiles
	var n := orig.size()
	var boss_i := -1
	for i in n:
		if orig[i]["type"] == "boss":
			boss_i = i
	var stuff: Array = []
	var herb_cnt := 0
	for i in range(2, n - 2):
		if orig[i]["type"] == "boss":
			continue
		stuff.append(orig[i]["type"])
		if orig[i].get("herb", false):
			herb_cnt += 1
	# 갈림길 고르기: 꺾이는 모퉁이 하나를 사이에 둔 직사각형 → 반대쪽 두 변으로 도는 샛길
	var corners: Array = []
	for c in range(3, n - 3):
		if _d(orig, c - 1) != _d(orig, c):
			corners.append(c)
	_shuffle(rng, corners)
	var want := 2 + rng.randi() % 2
	var forks: Array = []
	var extra := 0
	for minside in [2, 1]:
		for c: int in corners:
			if forks.size() >= want:
				break
			var kb := 0
			var j: int = c - 1
			while j >= 0 and _d(orig, j) == _d(orig, c - 1):
				kb += 1; j -= 1
			var ma := 0
			j = c
			while j < n - 1 and _d(orig, j) == _d(orig, c):
				ma += 1; j += 1
			var k := mini(kb, 2 + rng.randi() % 2)
			var m := mini(ma, 2 + rng.randi() % 2)
			if k < minside or m < minside or k + m < 3:
				continue
			var p: int = c - k
			var q: int = c + m
			if p < 3:
				continue
			var ex := extra + k + m - 1
			var mlen := n - ex
			var ok: bool = q <= mlen - 4 and (boss_i < 0 or (boss_i < mlen - 3 and (boss_i < p or boss_i > q)))
			for f in forks:
				if not (p > f["q"] + 1 or q < f["p"] - 1) or f["q"] > mlen - 4:
					ok = false
			if not ok:
				continue
			forks.append({"p": p, "q": q, "k": k, "m": m})
			extra = ex
	main_len = n - extra
	var nt: Array = []
	for i in main_len:
		var t: Dictionary = orig[i].duplicate(true)
		t["next"] = [i + 1] if i < main_len - 1 else []
		t["main"] = true
		if i == 0:
			t["type"] = "start"
		elif i == main_len - 1:
			t["type"] = "goal"
		elif t["type"] != "boss":
			t["type"] = "empty"
		t.erase("herb")
		nt.append(t)
	for f in forks:
		var d1 := _d(orig, f["p"])
		var d2 := _d(orig, f["q"] - 1)
		var P := Vector2i(int(orig[f["p"]]["x"]), int(orig[f["p"]]["y"]))
		var cells: Array = []
		for jj in range(1, f["m"] + 1):
			cells.append(P + d2 * jj)
		for ii in range(1, f["k"]):
			cells.append(P + d2 * f["m"] + d1 * ii)
		var prev_i: int = f["p"]
		for cc in cells:
			var idx := nt.size()
			nt.append({"x": cc.x, "y": cc.y, "type": "empty", "next": [], "main": false})
			nt[prev_i]["next"].append(idx)
			prev_i = idx
		nt[prev_i]["next"].append(f["q"])
	tiles = nt
	for t in tiles:
		t["prev"] = []
	for i in tiles.size():
		for x in tiles[i]["next"]:
			tiles[x]["prev"].append(i)
	dist_goal = _bfs([main_len - 1], false, true)
	var dist_start := _bfs([0], false)
	# ① 인물(길막이·말 걸 사람·장사꾼·감시꾼)을 길 전체에 고르게, 서로 한 칸 이상 띄워서
	var chars: Array = []
	var others: Array = []
	for t in stuff:
		if t in ["walpae", "pojol", "talk", "shop"]:
			chars.append(t)
		else:
			others.append(t)
	var gcnt: int = guards.size() + int(stage_cfg.get("extra_guards", 2))
	for g in gcnt:
		chars.append("guard")
	for pt in int(stage_cfg.get("patients", 0)):   # 화란: 역병에 걸린 마을 사람
		chars.append("patient")
	_shuffle(rng, chars)
	var occupied: Array = []   # [칸, 감시꾼인가]
	if boss_i >= 0:
		occupied.append([boss_i, false])
	var reserved := {}         # 붉은 눈길 칸 (다른 것 못 놓음)
	guards = []
	var order: Array = range(tiles.size())
	_shuffle(rng, order)
	var span := float(main_len - 5)
	for k in chars.size():
		var kind: String = chars[k]
		var target := 3.0 + (k + 0.5) * span / chars.size()
		var best := -1
		# 붉은 칸 사이에도 빈칸 하나, 인물끼리 화면에서 겹쳐 보이지 않게 (안 되면 조금씩 완화, 붉은 칸 겹침은 절대 안 됨)
		for pss in [[4, true], [3, true], [4, false], [3, false]]:
			var best_d := 1e9
			for i in order:
				if not _char_ok(i, kind == "guard", occupied, reserved, dist_start, pss[0]):
					continue
				if pss[1] and _hidden_by_any(i, occupied):
					continue
				var dd: float = abs(dist_start[i] - target)
				if dd < best_d:
					best_d = dd; best = i
			if best >= 0:
				break
		if best < 0:
			continue
		occupied.append([best, kind == "guard"])
		if kind == "guard":
			var zone: Array = [best]
			for z in nbrs(best):
				zone.append(z)
			for z in zone:
				reserved[z] = true
			guards.append({"x": tiles[best]["x"], "y": tiles[best]["y"], "at": best, "zone": zone,
				"kind": "walpae" if rng.randi() % 2 == 0 else "pojol", "on_path": true})
		else:
			tiles[best]["type"] = kind
	# ③ 약초는 본길에만 (어느 갈래로 가도 다 모을 수 있게), 붉은 칸은 피해서
	var hc: Array = []
	for i in range(2, main_len - 2):
		if tiles[i]["type"] == "empty" and not reserved.has(i):
			hc.append(i)
	_shuffle(rng, hc)
	hc = hc.filter(func(a): return not _behind_char(a, occupied))
	herb_cnt += 2   # 맵마다 약초 두 개 더
	for i in hc.slice(0, herb_cnt):
		tiles[i]["herb"] = true
	# ②-0 심부름 약재: 갈림길로 비켜 가지 않는 본길 칸에 고르게 (지나가기만 해도 줍는다)
	var errands: Array = stage_cfg.get("errand", [])
	if errands.size() > 0:
		var inside := {}
		for f in forks:
			for k in range(int(f["p"]) + 1, int(f["q"])):
				inside[k] = true
		var ec: Array = []
		for i in range(4, main_len - 3):
			if tiles[i]["type"] == "empty" and not reserved.has(i) and not inside.has(i) and not tiles[i].get("herb", false):
				ec.append(i)
		for k in errands.size():
			if ec.is_empty():
				break
			var ew: int = int(4 + (k + 0.5) * (main_len - 8) / errands.size())
			var best: int = ec[0]
			for c in ec:
				if absi(c - ew) < absi(best - ew):
					best = c
			tiles[best]["errand"] = errands[k]
			ec.erase(best)
	# ② 나머지 사건(이로운·해로운 칸, 함정 등)은 남은 빈칸에
	var slots: Array = []
	for i in tiles.size():
		if tiles[i]["type"] != "empty" or reserved.has(i) or tiles[i].get("herb", false) or tiles[i].has("errand"):
			continue
		if tiles[i]["main"] and (i < 2 or i > main_len - 3):
			continue
		slots.append(i)
	_shuffle(rng, others)
	_shuffle(rng, slots)
	others = others.filter(func(t): return t != "empty")   # 빈칸 말고 진짜 사건만 (자리가 모자라면 사건이 먼저)
	slots.sort_custom(func(a, b): return int(_behind_char(a, occupied)) < int(_behind_char(b, occupied)))
	slots = slots.filter(func(a): return not _behind_char(a, occupied))
	for k2 in mini(slots.size(), others.size()):
		tiles[slots[k2]]["type"] = others[k2]
	if rng.randi() % 2 == 1:   # 길을 좌우로 뒤집기
		for t in tiles:
			var x = t["x"]; t["x"] = t["y"]; t["y"] = x
	# 감시꾼은 반드시 자기 칸 위에 (뒤집은 뒤 좌표로 맞춤)
	for g in guards:
		g["x"] = tiles[int(g["at"])]["x"]; g["y"] = tiles[int(g["at"])]["y"]

## a칸의 인물 그림이 b칸(화면 위쪽)을 가리는가
func _covers(a: int, b: int) -> bool:
	var ds: int = (int(tiles[a]["x"]) + int(tiles[a]["y"])) - (int(tiles[b]["x"]) + int(tiles[b]["y"]))
	var dd: int = absi((int(tiles[a]["x"]) - int(tiles[a]["y"])) - (int(tiles[b]["x"]) - int(tiles[b]["y"])))
	return (dd == 0 and ds >= 1 and ds <= 4) or (dd == 1 and ds >= 1 and ds <= 2)

## i칸(사건 아이콘·약초)이 인물 그림에 가려지는가
## 바로 뒤 칸(같은 줄 두 칸 위)은 몸에, 그 뒤 칸은 머리 위 표시에 가려진다
func _behind_char(i: int, occupied: Array) -> bool:
	for o in occupied:
		var ds: int = (int(tiles[o[0]]["x"]) + int(tiles[o[0]]["y"])) - (int(tiles[i]["x"]) + int(tiles[i]["y"]))
		var dd: int = absi((int(tiles[o[0]]["x"]) - int(tiles[o[0]]["y"])) - (int(tiles[i]["x"]) - int(tiles[i]["y"])))
		if dd == 0 and ds == 2:
			return true
	return false

## i칸의 아이콘·약초가 인물 얼굴을 가리는가 (바로 앞 칸)
func _covers_char(i: int, occupied: Array) -> bool:
	for o in occupied:
		var ds: int = (int(tiles[i]["x"]) + int(tiles[i]["y"])) - (int(tiles[o[0]]["x"]) + int(tiles[o[0]]["y"]))
		var dd: int = absi((int(tiles[i]["x"]) - int(tiles[i]["y"])) - (int(tiles[o[0]]["x"]) - int(tiles[o[0]]["y"])))
		if dd == 0 and ds == 2:
			return true
	return false

## i칸이 다른 인물에 가려지거나, i칸 인물이 다른 인물을 가리는가
func _hidden_by_any(i: int, occupied: Array) -> bool:
	for o in occupied:
		if _covers(o[0], i) or _covers(i, o[0]):
			return true
	return false

func _cheb(a: int, b: int) -> int:
	return maxi(absi(int(tiles[a]["x"]) - int(tiles[b]["x"])), absi(int(tiles[a]["y"]) - int(tiles[b]["y"])))

## 인물을 세워도 되는 칸인가: 다른 인물과 사이에 빈칸 하나 이상, 감시꾼끼리는 붉은 칸이 겹치지 않게
func _char_ok(i: int, guard: bool, occupied: Array, reserved: Dictionary, dist_start: Array, gg := 4) -> bool:
	if tiles[i]["type"] != "empty" or reserved.has(i) or dist_start[i] < 3 or dist_goal[i] < 2:
		return false
	for o in occupied:
		var need := gg if (guard and o[1]) else 2   # 감시꾼끼리는 붉은 칸이 겹치지 않게 더 띄움
		if _cheb(i, o[0]) < need:
			return false
	if guard:
		for z in nbrs(i):
			if reserved.has(z) or tiles[z]["type"] in ["start", "goal", "boss"]:
				return false
	return true

func _patient_pic(i: int) -> String:
	if stage_cfg.has("patient_pic"):
		return stage_cfg["patient_pic"]
	return "dutch_sick_man" if i % 2 == 0 else "dutch_sick_woman"

## 화란: 앓는 마을 사람 칸 — 약초나 엽전으로 치료하거나, 지나치면 역병이 번진다
func _treat_patient() -> void:
	var at := pos
	var man: bool = at % 2 == 0
	var pic := _patient_pic(at)
	var who := "앓는 어부" if man else "앓는 여인"
	var text := "물… 물 좀 주시오…\n열이 펄펄 끓어 일어설 수가 없소…" if man else "몸이… 불덩이 같아요…\n아이들 밥도 못 해 줬는데…"
	if stage_cfg.has("patient_pic"):
		who = stage_cfg.get("patient_who", "앓는 사람")
		text = stage_cfg.get("patient_text", "열이… 열이 내리질 않아…")
	var ch: Array = [{"text": "약초 1개로 탕약을 달여 준다" + ("" if main.herbs >= 1 else " (약초 없음)")},
		{"text": "엽전 3냥으로 약을 사 준다" + ("" if main.coins >= 3 else " (엽전 부족)")},
		{"text": "갈 길이 바빠 지나친다"}]
	main.popup_choices(text, ch, func(k: int):
		if k == 0 and main.herbs >= 1:
			main.herbs -= 1; main.coins += 5
			_clear(at); main.sfx("good")
			main.popup("탕약을 마신 %s의 열이 조금씩 내렸다.\n\"고맙소, 동양 의원님…\"\n\n(약초 -1 · 감사의 엽전 +5냥)" % who, "다행이다", func(): _after_land(false), who, pic)
		elif k == 1 and main.coins >= 3:
			main.coins -= 3; main.max_hp += 2; main.hp += 2
			_clear(at); main.sfx("good")
			main.popup("시장에서 해열 약을 사다 먹였다.\n%s가 겨우 웃어 보였다.\n\n(엽전 -3냥 · 마을의 믿음: 최대 체력 +2)" % who, "다행이다", func(): _after_land(false), who, pic)
		elif k == 2:
			turns_left = max(0, turns_left - 1)
			main.sfx("hurt")
			main.popup("돌아보지 않고 걸음을 재촉했다.\n…등 뒤에서 앓는 소리가 오래 들렸다.\n\n(역병이 번졌다: 남은 시각 -1)", "…", func(): _after_land(false), who, pic)
		else:
			main.popup("가진 것이 모자라 치료할 수 없다.\n다른 방법을 골라야 한다.", "다시 고른다", _treat_patient, who, pic), who, pic)

## 갈림길: 두 갈래 중 하나 고르기
func _choose_way(opts: Array) -> int:
	way_opts = opts
	overlay.queue_redraw()
	_focus(tile_center(pos), true, 0.3)
	hint_label.text = "갈림길입니다. 어느 길로 갈까요?"
	var hidden: Array = []
	for c in card_row.get_children():
		if c.visible:
			c.visible = false; hidden.append(c)
	var sorted := opts.duplicate()
	sorted.sort_custom(func(a, b): return tile_center(a).x < tile_center(b).x)
	var btns: Array = []
	for o in sorted:
		var left: bool = tile_center(o).x < tile_center(pos).x
		var b: Button = main.make_button("◀ 왼쪽 길" if left else "오른쪽 길 ▶", 30)
		b.custom_minimum_size = Vector2(250, 120)
		b.pressed.connect(func(): way_chosen.emit(o))
		card_row.add_child(b)
		btns.append(b)
	var pick: int = await way_chosen
	main.sfx("card_play")
	for b in btns:
		b.queue_free()
	for c in hidden:
		c.visible = true
	way_opts = []
	overlay.queue_redraw()
	return pick

# ── 배치 / 카메라 ───────────────────────────────────────
func _layout() -> void:
	var top := hud.position.y + hud.size.y
	var bottom := tray.position.y
	view.position = Vector2(0, top)
	view.size = Vector2(size.x, max(200.0, bottom - top))
	_focus(tile_center(pos), false)

func _clamp_world(p: Vector2) -> Vector2:
	var vs := view.size
	p.x = clamp(p.x, min(0.0, vs.x - world.size.x), 0.0)
	p.y = clamp(p.y, min(0.0, vs.y - world.size.y), 0.0)
	return p

func _focus(target: Vector2, animate := true, dur := 0.45) -> void:
	if view == null or view.size == Vector2.ZERO:
		return
	var want := _clamp_world(view.size / 2.0 - target + Vector2(0, 60))
	if cam_tween and cam_tween.is_valid():
		cam_tween.kill()
	if not animate:
		world.position = want
		return
	cam_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	cam_tween.tween_property(world, "position", want, dur)

func _on_view_input(e: InputEvent) -> void:
	if busy:
		return
	# 터치 끌기는 마우스 움직임으로도 같이 들어와 두 배로 움직였음 → 하나만 사용
	if e is InputEventMouseMotion and (e.button_mask & MOUSE_BUTTON_MASK_LEFT):
		world.position = _clamp_world(world.position + e.relative)

# ── HUD ─────────────────────────────────────────────────
func _build_hud() -> void:
	hud = PanelContainer.new()
	hud.add_theme_stylebox_override("panel", main.bar_style())
	hud.anchor_right = 1.0
	hud.offset_left = 4; hud.offset_right = -4; hud.offset_top = 4
	add_child(hud)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 2)
	hud.add_child(vb)
	var head := HBoxContainer.new()
	vb.add_child(head)
	title_lbl = main.make_label(cfg.get("title", ""), 30, main.GOLD, true)
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title_lbl)
	var me: Button = main.make_button("◎", 24)
	me.custom_minimum_size = Vector2(64, 62)
	head.add_child(me)
	me.pressed.connect(func(): _focus(tile_center(pos)))
	var menu: Button = main.make_button("메뉴", 24)
	menu.custom_minimum_size = Vector2(100, 62)
	head.add_child(menu)
	menu.pressed.connect(func():
		if not busy:
			main.open_menu())
	brew_btn = main.make_button("약탕관", 24)
	brew_btn.custom_minimum_size = Vector2(110, 62)
	head.add_child(brew_btn)
	brew_btn.pressed.connect(func():
		if not busy:
			main.show_brew(_update_hud))
	var bag: Button = main.make_button("보따리", 24)
	bag.custom_minimum_size = Vector2(110, 62)
	head.add_child(bag)
	bag.pressed.connect(func():
		if not busy:
			main.show_bag())
	var sname: Label = main.make_label(("〈%s〉  만리길" % stage_cfg["name"]) if not main.sub_stage.is_empty() else ("〈%s〉  %d / %d" % [stage_cfg["name"], main.stage_idx + 1, cfg["stages"].size()]), 24, Color("e9c9a0"))
	vb.add_child(sname)
	var row := HBoxContainer.new()
	vb.add_child(row)
	clock_lbl = main.make_label("", 26, main.LIGHT, true)
	clock_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(clock_lbl)
	info_lbl = main.make_label("", 22, main.LIGHT)
	row.add_child(info_lbl)
	_update_hud()

func _update_hud() -> void:
	clock_lbl.text = "남은 시각 %d" % turns_left
	clock_lbl.add_theme_color_override("font_color", main.LIGHT if turns_left > 3 else Color("ff8a70"))
	info_lbl.text = "약초 %d · 체력 %d/%d · 엽전 %d · 약병 %d" % [main.herbs, main.hp, main.max_hp, main.coins, main.potions + main.potions_small]
	if stage_cfg.has("errand"):
		info_lbl.text = "심부름 약재 %d/%d · " % [errand_names.size(), stage_cfg["errand"].size()] + info_lbl.text
	if brew_btn:
		brew_btn.modulate = Color(1.25, 1.15, 0.8) if main.herbs >= main.BREW_SMALL else Color.WHITE

func _build_tray() -> void:
	tray = PanelContainer.new()
	tray.add_theme_stylebox_override("panel", main.bar_style())
	tray.anchor_top = 1.0; tray.anchor_bottom = 1.0; tray.anchor_right = 1.0
	tray.offset_left = 4; tray.offset_right = -4
	tray.offset_top = -384; tray.offset_bottom = -4
	add_child(tray)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	tray.add_child(vb)
	hint_label = main.make_label("행보 상소를 고르십시오", 26, main.GOLD, true)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(hint_label)
	card_row = HBoxContainer.new()
	card_row.alignment = BoxContainer.ALIGNMENT_CENTER
	card_row.add_theme_constant_override("separation", 18)
	card_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(card_row)

func _intro() -> void:
	main.bgm("travel")
	busy = true
	_update_hud()
	await get_tree().process_frame
	await get_tree().process_frame
	_layout()
	if pos == 0 and restore.is_empty():
		await get_tree().create_timer(0.3).timeout
		main.popup("〈%s〉\n\n붉은 칸은 감시꾼의 눈길입니다. 그 칸에서 멈추면 들킵니다.\n남은 시각 안에 대문까지 가십시오." % stage_cfg["name"], "출발", func():
			busy = false
			_deal(), cfg.get("title", ""), "", "", true)
		return
	await get_tree().create_timer(0.4).timeout
	_deal()
	busy = false

func get_state() -> Dictionary:
	return {"seed": map_seed, "pos": pos, "turns": turns_left, "herbs": herbs_got, "talk_idx": talk_idx,
		"cleared": cleared.keys(), "guards_done": guards_done.keys(), "visited": visited.keys(), "errand": errand_names, "days_left": turns_left}

func place_name() -> String:
	return stage_cfg.get("name", "")

var said_start := false
func _deal() -> void:
	if not said_start:
		said_start = true
		comp_say("start")
	for c in card_row.get_children():
		c.queue_free()
	for i in 3:
		var v: int = STEP_VALUES.pick_random()
		var b: Button = main.step_card(v, 186, 282)
		b.modulate.a = 0.0
		card_row.add_child(b)
		b.pressed.connect(func(): _play(v, b))
		b.pivot_offset = Vector2(93, 141)
		b.scale = Vector2(0.8, 0.8)
		var tw := create_tween().set_parallel()
		tw.tween_property(b, "modulate:a", 1.0, 0.28).set_delay(0.1 + i * 0.15)
		tw.tween_property(b, "scale", Vector2.ONE, 0.28).set_delay(0.1 + i * 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	hint_label.text = "행보 상소를 고르십시오 · 대문까지 %d칸" % dist_goal[pos]

# ── 이동 ────────────────────────────────────────────────
func _blocks(i: int) -> bool:
	return tiles[i]["type"] in BLOCKERS and not cleared.has(i)

func _play(steps: int, chosen: Button) -> void:
	if busy:
		return
	busy = true
	main.sfx("card_play")
	for c in card_row.get_children():
		c.disabled = true
		if c != chosen:
			create_tween().tween_property(c, "modulate:a", 0.25, 0.25)
	var lift := create_tween().set_parallel()
	lift.tween_property(chosen, "scale", Vector2(1.12, 1.12), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await lift.finished
	await get_tree().create_timer(0.2).timeout
	turns_left -= 1
	_update_hud()
	hint_label.text = "%s 걸음 나아갑니다…" % main.STEP_WORD[steps]
	_focus(tile_center(pos), true, 0.3)
	await get_tree().create_timer(0.3).timeout
	for s in steps:
		var nx: Array = tiles[pos]["next"]
		if nx.is_empty():
			break
		var nxt: int = nx[0]
		if nx.size() > 1:
			nxt = await _choose_way(nx)
		pos = nxt
		visited[pos] = true
		_pick_errand(pos)
		var target := tile_center(pos)
		_focus(target, true, HOP_TIME + STEP_PAUSE)
		if follower:
			var ftw := create_tween()
			ftw.tween_property(follower, "position", tile_center(_behind(pos)), HOP_TIME).set_trans(Tween.TRANS_QUAD)
		var tw := create_tween()
		tw.tween_property(token, "position", token.position.lerp(target, 0.5) - Vector2(0, 40), HOP_TIME * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(token, "position", target, HOP_TIME * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_callback(func(): main.sfx("step", -4.0))
		tw.tween_property(token_pic, "scale", Vector2(1.08, 0.92), 0.06)
		tw.tween_property(token_pic, "scale", Vector2.ONE, 0.08)
		await tw.finished
		overlay.queue_redraw()
		await get_tree().create_timer(STEP_PAUSE).timeout
		if _blocks(pos):
			break
	await get_tree().create_timer(0.35).timeout
	_pick_herb(pos)  # 약초는 그 칸에 딱 멈춰야 얻는다
	_resolve()

## 약초가 넉넉해지면 약탕관 버튼을 반짝이며 알려 줌
func _brew_hint() -> void:
	var l: Label = main.ink_text(main.make_label("진한 탕약까지 달일 수 있어요!" if main.herbs >= main.BREW_HERBS else "묽은 탕약을 달일 수 있어요!", 30, main.GOLD, true), 8)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	l.position.y = 230
	add_child(l)
	var lt := create_tween()
	lt.tween_interval(1.8)
	lt.tween_property(l, "modulate:a", 0.0, 0.6)
	lt.tween_callback(l.queue_free)
	if brew_btn:
		brew_btn.pivot_offset = brew_btn.size / 2.0
		var tw := create_tween().set_loops(3)
		tw.tween_property(brew_btn, "scale", Vector2(1.15, 1.15), 0.25)
		tw.tween_property(brew_btn, "scale", Vector2.ONE, 0.25)

var errand_names: Array = []
func _pick_errand(i: int) -> void:
	if not tiles[i].has("errand") or str(tiles[i]["errand"]) in errand_names:
		return
	errand_names.append(str(tiles[i]["errand"]))
	main.sfx("item")
	var n: Node = ent_nodes[i].get_node_or_null("Errand")
	if n:
		var tw := create_tween().set_parallel()
		tw.tween_property(n, "position:y", n.position.y - 60, 0.4)
		tw.tween_property(n, "modulate:a", 0.0, 0.4)
	_update_hud()

var follower: Control = null
## 동료는 한 칸 뒤(지나온 칸)에 선다
func _behind(i: int) -> int:
	var pv: Array = tiles[i]["prev"]
	for p in pv:
		if visited.has(p):
			return p
	return pv[0] if not pv.is_empty() else i

## 동료의 짧은 한마디 (말풍선, 진행을 멈추지 않음)
func comp_say(kind: String) -> void:
	var t: String = main.comp_line(kind)
	if t == "":
		return
	var c: Dictionary = StoryData.COMPANION.get(main.companion(), {})
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", main.plaque_style())
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l: Label = main.make_label("%s: %s" % [c.get("name", ""), t], 24, main.GOLD, true)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(560, 0)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p.add_child(l)
	p.anchor_left = 0.5; p.anchor_right = 0.5
	p.offset_left = -300; p.offset_right = 300; p.offset_top = 250
	p.grow_horizontal = Control.GROW_DIRECTION_BOTH
	add_child(p)
	var tw := create_tween()
	tw.tween_interval(2.4)
	tw.tween_property(p, "modulate:a", 0.0, 0.5)
	tw.tween_callback(p.queue_free)

func _pick_herb(i: int) -> void:
	var t: Dictionary = tiles[i]
	if not t.get("herb", false) or ent_nodes[i].get_node_or_null("Herb") == null:
		return
	var h: Control = ent_nodes[i].get_node("Herb")
	h.name = "HerbTaken"
	herbs_got += 1
	if herbs_got == 1:
		comp_say("herb")
	main.herbs += 1
	main.coins += 2
	if main.herbs == main.BREW_SMALL or main.herbs == main.BREW_HERBS:
		_brew_hint()
	main.sfx("item")
	var tw := create_tween().set_parallel()
	tw.tween_property(h, "position:y", h.position.y - 60, 0.4)
	tw.tween_property(h, "modulate:a", 0.0, 0.4)
	_update_hud()

const WHO_PIC := {"약재 상인": "yakjae", "엿장수": "yeotjangsu", "주막 주모": "jumo", "주모": "jumo", "물장수": "muljangsu",
	"포졸": "pojol", "백성": "addict", "다래": "friend", "순라꾼": "sunra", "청나라 약재상": "yakjae", "항구 주모": "jumo"}

## 이 칸에서 만날 사람 (칸마다 정해져 있어 맵에 미리 보인다)
func _talk_at(i: int) -> Dictionary:
	var pool: Array = StoryData.talks(main.chapter)
	var k := 0
	for j in i:
		if tiles[j]["type"] == "talk":
			k += 1
	return pool[(main.stage_idx * 3 + k) % pool.size()]

func _resolve() -> void:
	var t: String = tiles[pos]["type"]
	if cleared.has(pos):
		t = "empty"
	match t:
		"walpae", "pojol":
			var eid := _enemy_id(t)
			var e: Dictionary = GameData.ENEMIES[eid]
			var idx := pos
			main.sfx("alarm")
			var bl: String = BLOCK_LINES.get(eid, "%s이(가) 길을 막아섰다!" % e["name"])
			var bparts: PackedStringArray = bl.split("\n", false, 1)
			# 상황 설명은 이름 없이, 따옴표 대사만 그 사람 이름으로
			var talk: Array = [{"who": "", "pic": e["sprite"], "text": bparts[0]}]
			if bparts.size() > 1:
				talk.append({"who": e["name"], "pic": e["sprite"], "text": bparts[1].replace("\"", "")})
			var disg: bool = main.chapter in main.DISGUISED
			for ln in BLOCK_REPLY.get(eid, BLOCK_REPLY["_"]):
				var l2: Dictionary = ln.duplicate()
				if not disg:
					l2["who"] = l2["who"].replace("{alias}", "{name}")
					l2["pic"] = l2["pic"].replace("hero_disguise", "hero")
				talk.append(l2)
			main.dialog_chain(talk, func():
				main.popup("피할 길이 없다. 맞서 싸우자!", "맞서 싸운다", func():
					main.start_battle(eid, func():
						_clear(idx)
						_after_land(true)), "전투", e["sprite"]))
			return
		"boss":
			var nd: Dictionary = tiles[pos]
			var idx := pos
			main.sfx("alarm")
			main.dialog_chain(StoryData.lines(nd.get("pre", "")), func():
				main.start_battle(nd["battle"], func():
					_clear(idx)
					main.dialog_chain(StoryData.lines(nd.get("post", "")), func(): _after_land(true)), {"lose_ok": nd.get("lose_ok", false)}))
			return
		"spike":
			main.hp = max(1, main.hp - 6)
			main.sfx("hurt")
			_shake()
			main.popup("숨겨진 죽창 함정을 밟았다!\n\n(체력 -6)", "이를 악물고 간다", func(): _after_land(false), "함정")
			return
		"talk":
			_clear(pos)
			var talk: Dictionary = _talk_at(pos)
			talk_idx += 1
			var extra := ""
			main.sfx("coin" if talk.has("coin") else "item")
			if talk.has("coin"):
				main.coins += talk["coin"]; extra += "\n\n(엽전 +%d냥)" % talk["coin"]
			if talk.has("potion"):
				main.potions += talk["potion"]; extra += "\n\n(약병 +%d)" % talk["potion"]
			main.popup(talk["text"] + extra, "고맙습니다", func(): _after_land(false), talk["who"], talk.get("pic", ""))
			return
		"patient":
			_treat_patient()
			return
		"item":
			_clear(pos)
			main.potions += 1
			main.sfx("item")
			main.popup("길섶에서 약초 주머니를 주웠다!\n곧 약병 하나로 달여 냈다.\n\n(약병 +1)", "챙긴다", func(): _after_land(false), "약초")
			return
		"buff":
			_clear(pos); _apply_event(GameData.BUFFS.pick_random()); return
		"debuff":
			_clear(pos); _apply_event(GameData.DEBUFFS.pick_random()); return
		"trap":
			comp_say("trap")
			_clear(pos); _apply_event(GameData.TRAPS.pick_random()); return
		"rest":
			_clear(pos); _apply_event(GameData.REST); return
		"shop":
			main.popup("길가에 장이 섰다.\n약재와 물건을 사고팔 수 있다.", "둘러본다", func():
				main.open_shop(func(): _after_land(false)), "장터", "", "jangteo")
			return
		"goal":
			_stage_clear()
			return
	_after_land(false)

## 사건 뒤: 감시꾼 눈길 확인 → 차례 끝
func _after_land(_fought: bool) -> void:
	_update_hud()
	for gi in guards.size():
		if guards_done.has(gi):
			continue
		if pos in guards[gi]["zone"].map(func(z): return int(z)):
			var eid := _enemy_id(guards[gi]["kind"])
			var e: Dictionary = GameData.ENEMIES[eid]
			var g := gi
			main.sfx("alarm")
			_alert(gi)
			main.popup("들켰다!\n%s이(가) 이쪽을 노려보며 다가온다." % e["name"], "맞서 싸운다", func():
				main.start_battle(eid, func():
					guards_done[g] = true
					create_tween().tween_property(guard_nodes[g], "modulate:a", 0.0, 0.4)
					overlay.queue_redraw()
					_end_turn()), "전투", e["sprite"])
			return
	_end_turn()

func _alert(gi: int) -> void:
	var n: Control = guard_nodes[gi]
	var tw := create_tween()
	tw.tween_property(n, "position:y", n.position.y - 24, 0.12)
	tw.tween_property(n, "position:y", n.position.y, 0.12)

func _shake() -> void:
	var tw := create_tween()
	tw.tween_property(token, "position:x", token.position.x + 10, 0.05)
	tw.tween_property(token, "position:x", token.position.x - 10, 0.08)
	tw.tween_property(token, "position:x", token.position.x, 0.05)

## 길막이와 마주쳤을 때 주고받는 짧은 이야기
const BLOCK_REPLY := {
	"_": [{"who": "{alias}", "pic": "hero_disguise_angry", "text": "(돌아갈 길도 없어… 여기서 물러설 순 없어!)"}],
	"pojol": [{"who": "{alias}", "pic": "hero_disguise_sad", "text": "저는 그냥 약초 팔러 가는 길인데요…"},
		{"who": "포졸", "pic": "pojol", "text": "약초꾼이 왜 그리 눈을 피해? 수상하다, 이리 와 봐라!"}],
	"walpae": [{"who": "{alias}", "pic": "hero_disguise_angry", "text": "가진 거라곤 약초 몇 뿌리뿐이에요. 비켜 주세요."},
		{"who": "왈패", "pic": "walpae", "text": "흐흐, 약초도 돈이지. 순순히 안 내놓겠다 이거냐?"}],
	"mob": [{"who": "{name}", "pic": "hero", "text": "진정하세요! 제가 고쳐 드릴 수 있어요!"},
		{"who": "중독된 사내", "pic": "addict", "text": "약…! 그 약 냄새… 내놔아아!"}],
	"haejeok": [{"who": "{alias}", "pic": "hero_disguise_angry", "text": "역병 도는 마을에 약을 가져가는 길이에요. 비켜요!"},
		{"who": "뱃사람", "pic": "walpae", "text": "약이라고? 그럼 더 값나가겠군. 내놔라!"}],
}

const BLOCK_LINES := {
	"pojol": "포졸이 길을 막아섰다!\n\"거기 너, 잠깐 서 봐라!\"",
	"walpae": "왈패가 길을 턱 막아섰다!\n\"어이, 가진 거 다 내놓고 가라.\"",
	"rival": "흑룡파 왈패들이 몰려왔다!\n\"청안파 꼬마 의원이 너냐?\"",
	"sanjeok": "산적이 뛰쳐나왔다!\n\"가진 것 다 내놓고 가라!\"",
	"mob": "청심보명단에 중독된 사내가 달려든다!\n\"약… 약을 내놔…!\"",
	"haejeok": "칼을 찬 뱃사람 무리가 길을 막았다!\n\"이방인, 가진 걸 내놔라!\"",
	"rat": "역병을 옮기는 쥐떼가 우르르 몰려왔다!",
}

func _apply_event(ev: Dictionary) -> void:
	if ev.has("battle"):
		main.sfx("alarm")
	elif ev.has("hp") or ev.has("day") or (ev.has("coin") and int(ev["coin"]) < 0):
		main.sfx("bad")
	else:
		main.sfx("good")
	if ev.has("heal"): main.hp = min(main.max_hp, main.hp + int(ev["heal"]))
	if ev.has("maxhp"): main.max_hp += int(ev["maxhp"])
	if ev.has("hp"): main.hp = max(1, main.hp + int(ev["hp"]))
	if ev.has("energy"): main.next_energy += int(ev["energy"])
	if ev.has("guard"): main.next_guard += int(ev["guard"])
	if ev.has("day"): turns_left = max(1, turns_left + int(ev["day"]))
	if ev.has("coin"): main.coins = max(0, main.coins + int(ev["coin"]))
	_update_hud()
	var text: String = ev["text"].replace("남은 날", "남은 시각").replace("하루를 더 허비했다", "시간을 허비했다").replace("이틀을 잃었다", "시간을 잃었다")
	if ev.has("battle"):
		var eid: String = ev["battle"]
		main.popup(text, "맞서 싸운다", func():
			main.start_battle(eid, func(): _end_turn()), ev["title"], GameData.ENEMIES[eid]["sprite"])
	else:
		main.popup(text, "계속 간다", func(): _after_land(false), ev["title"], ev.get("pic", ""))

func _clear(i: int) -> void:
	cleared[i] = true
	_hide_ent(i, true)

func _hide_ent(i: int, animate: bool) -> void:
	if not ent_nodes.has(i):
		return
	var n: Control = ent_nodes[i]
	for ch in n.get_children():
		if ch.name.begins_with("Herb"):
			continue
		if animate:
			create_tween().tween_property(ch, "modulate:a", 0.0, 0.4)
		else:
			ch.modulate.a = 0.0

func _end_turn() -> void:
	_update_hud()
	overlay.queue_redraw()
	main.bgm("travel")
	if turns_left <= 0:
		main.sfx("gong")
		main.game_over("시각이 다 되었다.\n\"게 섰거라! 통금 시각에 어딜 쏘다니느냐!\"\n순라꾼에게 붙잡히고 말았다…", "sunra")
		return
	busy = false
	_focus(tile_center(pos))
	_deal()

func _stage_clear() -> void:
	main.sfx("victory")
	var bonus: int = turns_left
	main.coins += bonus
	var stages: Array = cfg.get("stages", [])
	var last: bool = main.stage_idx >= stages.size() - 1
	var msg: String = "〈%s〉 통과!\n\n남은 시각 보너스 엽전 +%d냥\n이번 길에서 캔 약초 %d/%d (약초 주머니 %d개)" % [stage_cfg["name"], bonus, herbs_got, herbs_total, main.herbs]
	if errand_names.size() > 0:
		msg += "\n구한 약재: %s" % " · ".join(errand_names)
	if not main.sub_stage.is_empty():
		main.popup(msg, "계속", func():
			main.dialog_chain(StoryData.lines(stage_cfg.get("after", "")), main.end_voyage), "", "", data.get("bg", ""), true)
		return
	if stage_cfg.get("after_story", false):
		main.popup(msg, "계속", func():
			main.board = null
			main.play_story(StoryData.lines(stage_cfg.get("after", "")), main.next_stage), "", "", data.get("bg", ""), true)
		return
	main.popup(msg, "계속", func():
		if last:
			_reach_goal()
		else:
			var ab: Dictionary = stage_cfg.get("after_battle", {})
			if ab.is_empty():
				main.dialog_chain(StoryData.lines(stage_cfg.get("after", "")), main.next_stage)
			else:
				main.dialog_chain(StoryData.lines(stage_cfg.get("after", "")) + StoryData.lines(ab["pre"]), func():
					main.start_battle(ab["battle"], func():
						main.dialog_chain(StoryData.lines(ab["post"]), main.next_stage), {"lose_ok": ab.get("lose_ok", false), "comp_done": true})), "", "", data.get("bg", ""), true)

func _reach_goal() -> void:
	if cfg.has("goal_battle"):
		main.sfx("alarm")
		main.dialog_chain(StoryData.lines(cfg.get("goal_pre", "")), func():
			main.start_battle(cfg["goal_battle"], main.chapter_clear,
				{"lose_ok": cfg.get("goal_lose_ok", false), "ally": cfg.get("goal_ally", ""), "no_reward": true}))
	else:
		main.popup(cfg.get("goal_text", "목적지에 도착했다!"), "들어간다", main.chapter_clear,
			cfg.get("goal_title", ""), cfg.get("goal_pic", ""), cfg.get("goal_bg", ""), true)
