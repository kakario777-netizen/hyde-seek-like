extends Node
## 배경음·효과음 관리. 파일: res://assets/audio/bgm/<이름>.ogg, res://assets/audio/sfx/<이름>.ogg

const FADE := 1.2
var bgm_a: AudioStreamPlayer
var bgm_b: AudioStreamPlayer
var current_bgm := ""
var cur_p: AudioStreamPlayer = null   # 지금 곡을 맡은 플레이어
var fade_tw: Tween = null
var sfx_players: Array = []
var bgm_volume := 0.7
var sfx_volume := 0.9
var _cache := {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for n in ["BGM", "SFX"]:
		if AudioServer.get_bus_index(n) == -1:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, n)
			AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")
	bgm_a = _player("BGM"); bgm_b = _player("BGM")
	for i in 8:
		sfx_players.append(_player("SFX"))
	apply_volume()

func _player(bus: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = bus
	add_child(p)
	return p

func _load(kind: String, name: String) -> AudioStream:
	var key := kind + "/" + name
	if _cache.has(key):
		return _cache[key]
	var path := "res://assets/audio/%s/%s.ogg" % [kind, name]
	var s: AudioStream = load(path) if ResourceLoader.exists(path) else null
	_cache[key] = s
	return s

func _db(v: float) -> float:
	return -80.0 if v <= 0.001 else linear_to_db(v)

func apply_volume() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), _db(bgm_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), _db(sfx_volume))

## 배경음 바꾸기 (같은 곡이면 그대로)
func bgm(name: String) -> void:
	if name == current_bgm:
		return
	current_bgm = name
	var s: AudioStream = _load("bgm", name) if name != "" else null
	# 곡이 빠르게 연달아 바뀌어도 새 곡이 끊기지 않게: 앞 페이드를 멈추고, 맡은 플레이어를 직접 기억한다
	if fade_tw and fade_tw.is_valid():
		fade_tw.kill()
	var old: AudioStreamPlayer = cur_p if cur_p else bgm_a
	var nw: AudioStreamPlayer = bgm_b if old == bgm_a else bgm_a
	nw.stop()
	fade_tw = create_tween().set_parallel()
	if old.playing:
		fade_tw.tween_property(old, "volume_db", -40.0, FADE)
	cur_p = nw
	if s == null:
		fade_tw.chain().tween_callback(old.stop)
		return
	if s is AudioStreamOggVorbis:
		s.loop = true
	nw.stream = s
	nw.volume_db = -40.0
	nw.play()
	fade_tw.tween_property(nw, "volume_db", 0.0, FADE)
	fade_tw.chain().tween_callback(old.stop)

## 효과음. pitch_var: 음높이를 조금씩 흔들어 반복감 줄이기
func sfx(name: String, vol_db := 0.0, pitch_var := 0.06) -> void:
	var s: AudioStream = _load("sfx", name)
	if s == null:
		return
	for p in sfx_players:
		if not p.playing:
			p.stream = s
			p.volume_db = vol_db
			p.pitch_scale = 1.0 + randf_range(-pitch_var, pitch_var)
			p.play()
			return
	var p0: AudioStreamPlayer = sfx_players[0]
	p0.stream = s; p0.volume_db = vol_db; p0.play()
