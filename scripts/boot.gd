extends Control
## 시작 화면: 앱 안 업데이트
## - 새 '게임 데이터(.pck)'가 있으면 받아서 바로 적용 (재설치 없음)
## - 앱 자체를 새로 깔아야 하는 변경이면 설치 파일 페이지 안내
## - 새 데이터로 켜다가 멈추면 다음 실행 때 원래 데이터로 되돌림

const SHELL := 1   # 이 시작 화면/업데이트 기능의 판. 바뀌면 APK 재설치 필요
const REPO := "kakario777-netizen/hyde-seek-releases"
const API := "https://api.github.com/repos/%s/releases/latest" % REPO
const PAGE := "https://github.com/%s/releases/latest" % REPO
const PATCH := "user://patch.pck"
const PATCH_NEW := "user://patch_new.pck"
const STATE := "user://patch_state.json"

var label: Label
var bar: ProgressBar
var http: HTTPRequest
var dl: HTTPRequest
var cur_build := 0
var new_build := 0
var started := false

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color("1a120d")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var vb := VBoxContainer.new()
	vb.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vb.custom_minimum_size = Vector2(560, 160)
	vb.position = Vector2(-280, -80)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 20)
	add_child(vb)
	var t := Label.new()
	t.text = "한양 숨바꼭질"
	t.add_theme_font_size_override("font_size", 52)
	t.add_theme_color_override("font_color", Color("d9b45a"))
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(t)
	label = Label.new()
	label.text = "업데이트 확인 중…"
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color("e8dcc0"))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(label)
	bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 18)
	bar.show_percentage = false
	bar.visible = false
	vb.add_child(bar)

	_recover_if_crashed()
	cur_build = _current_build()
	if OS.has_feature("editor") or OS.get_cmdline_user_args().size() > 0:
		_start_game()   # 개발·테스트 실행에선 업데이트 확인 생략
		return
	http = HTTPRequest.new()
	http.timeout = 5.0
	add_child(http)
	http.request_completed.connect(_on_latest)
	if http.request(API, ["User-Agent: hanyang-hide", "Accept: application/vnd.github+json"]) != OK:
		_start_game()
	get_tree().create_timer(7.0).timeout.connect(func():
		if not started and (dl == null):
			_start_game())

func _read_state() -> Dictionary:
	if not FileAccess.file_exists(STATE):
		return {}
	var d = JSON.parse_string(FileAccess.get_file_as_string(STATE))
	return d if d is Dictionary else {}

func _write_state(d: Dictionary) -> void:
	var f := FileAccess.open(STATE, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(d))

## 지난번에 새 데이터로 켜다가 끝까지 못 갔으면(멈춤) 원래 데이터로
func _recover_if_crashed() -> void:
	var st := _read_state()
	if st.get("pending", false):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATCH))
		st = {"bad_build": st.get("build", 0)}
		_write_state(st)

func _base_build() -> int:
	var d = JSON.parse_string(FileAccess.get_file_as_string("res://build_info.json"))
	return int(d.get("build", 0)) if d is Dictionary else 0

func _current_build() -> int:
	var b := _base_build()
	var st := _read_state()
	if FileAccess.file_exists(PATCH) and int(st.get("build", 0)) > b and int(st.get("shell", SHELL)) == SHELL:
		return int(st["build"])
	return b

func _on_latest(result: int, code: int, _h: PackedStringArray, body: PackedByteArray) -> void:
	if started:
		return
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		_start_game(); return
	var rel = JSON.parse_string(body.get_string_from_utf8())
	if not (rel is Dictionary):
		_start_game(); return
	var tag: String = rel.get("tag_name", "")
	new_build = int(tag.trim_prefix("build-")) if tag.begins_with("build-") else 0
	var shell_need := SHELL
	var pck_url := ""
	for a in rel.get("assets", []):
		var n: String = a.get("name", "")
		if n == "hyde.pck":
			pck_url = a.get("browser_download_url", "")
		elif n.begins_with("shell-"):
			shell_need = int(n.trim_prefix("shell-").get_basename())
	if new_build <= cur_build or new_build == int(_read_state().get("bad_build", -1)):
		_start_game(); return
	if shell_need > SHELL:
		_ask_reinstall(); return
	if pck_url == "":
		_start_game(); return
	label.text = "새 이야기를 받는 중… (빌드 %d)" % new_build
	bar.visible = true
	dl = HTTPRequest.new()
	dl.download_file = PATCH_NEW
	dl.timeout = 120.0
	add_child(dl)
	dl.request_completed.connect(_on_pck)
	dl.request(pck_url, ["User-Agent: hanyang-hide"])

func _process(_d: float) -> void:
	if dl and bar.visible:
		var total := dl.get_body_size()
		if total > 0:
			bar.value = 100.0 * dl.get_downloaded_bytes() / total

func _on_pck(result: int, code: int, _h: PackedStringArray, _b: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200 or not FileAccess.file_exists(PATCH_NEW):
		label.text = "업데이트를 받지 못했어요. 지금 버전으로 시작합니다."
		await get_tree().create_timer(1.2).timeout
		_start_game(); return
	var d := DirAccess.open("user://")
	if d.file_exists("patch.pck"):
		d.remove("patch.pck")
	d.rename("patch_new.pck", "patch.pck")
	_write_state({"build": new_build, "shell": SHELL})
	cur_build = new_build
	label.text = "업데이트 완료! (빌드 %d)" % new_build
	await get_tree().create_timer(0.6).timeout
	_start_game()

func _ask_reinstall() -> void:
	label.text = "앱을 새로 설치해야 하는 업데이트가 있어요.\n(빌드 %d)" % new_build
	var hb := HBoxContainer.new()
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	hb.add_theme_constant_override("separation", 24)
	label.get_parent().add_child(hb)
	for pair in [["설치 파일 받기", true], ["나중에", false]]:
		var b := Button.new()
		b.text = pair[0]
		b.custom_minimum_size = Vector2(220, 90)
		b.add_theme_font_size_override("font_size", 28)
		hb.add_child(b)
		var go: bool = pair[1]
		b.pressed.connect(func():
			if go:
				OS.shell_open(PAGE)
			_start_game())

func _start_game() -> void:
	if started:
		return
	started = true
	var st := _read_state()
	if FileAccess.file_exists(PATCH) and int(st.get("build", 0)) > _base_build() and int(st.get("shell", SHELL)) == SHELL:
		st["pending"] = true    # 끝까지 켜지면 main이 지움
		_write_state(st)
		if not ProjectSettings.load_resource_pack(PATCH, true):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(PATCH))
			_write_state({})
	get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")

## main이 무사히 켜지면 호출
static func mark_ok() -> void:
	if not FileAccess.file_exists(STATE):
		return
	var d = JSON.parse_string(FileAccess.get_file_as_string(STATE))
	if d is Dictionary and d.get("pending", false):
		d.erase("pending")
		var f := FileAccess.open(STATE, FileAccess.WRITE)
		f.store_string(JSON.stringify(d))

## 지금 실행 중인 빌드 번호 (제목 화면 표시용)
static func running_build() -> int:
	var d = JSON.parse_string(FileAccess.get_file_as_string("res://build_info.json"))
	return int(d.get("build", 0)) if d is Dictionary else 0
