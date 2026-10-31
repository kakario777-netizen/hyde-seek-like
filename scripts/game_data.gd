class_name GameData
## 이야기·카드·적 데이터 (한양 숨바꼭질)

# ── 이야기 ─────────────────────────────────────────────
# who: 말하는 사람(빈칸이면 나레이션) / pose: 초상화 그림 / bg: 배경
# choices: [{text, goto}] / label: 이동 표식 / goto: 다음 표식 / end: 끝
const PROLOGUE := [
	{"bg": "yakbang", "who": "", "text": "조선, 한양.\n밤비가 막 그친 새벽녘."},
	{"who": "연이", "pose": "yeoni", "text": "의원님, 부탁하신 감초랑 당귀 다 챙겨 왔어요…\n…의원님?"},
	{"who": "", "text": "약방 문은 부서져 있었고, 바닥엔 깨진 약병과 쏟아진 약재가 어지럽게 흩어져 있었다."},
	{"who": "연이", "pose": "yeoni", "text": "이게… 무슨 일이야.\n의원님은 어디 가신 거지?"},
	{"who": "포졸", "pose": "pojol", "text": "저 아이다!\n약방을 털고 의원을 해친 범인이 저기 있다!"},
	{"who": "연이", "pose": "yeoni", "text": "네? 아, 아니에요!\n저는 방금 막 왔다고요!",
		"choices": [{"text": "그대로 뒷문으로 달아난다", "goto": "run"}, {"text": "억울하다고 해명한다", "goto": "explain"}]},
	{"label": "explain", "who": "포졸", "pose": "pojol", "text": "변명은 포도청에서 실컷 해라!\n오랏줄을 가져와!"},
	{"who": "연이", "pose": "yeoni", "text": "(안 돼… 지금 잡히면 아무도 내 말을 안 믿어 줄 거야.)", "goto": "run"},
	{"label": "run", "bg": "alley", "who": "", "text": "연이는 뒷문을 박차고 어둑한 골목으로 내달렸다."},
	{"who": "연이", "pose": "yeoni", "text": "헉, 헉… 이대로 다니면 금방 붙잡히겠어.\n머리를 감추고 사내아이처럼 하고 다니자."},
	{"who": "", "text": "연이는 댕기를 풀어 패랭이 속에 감추었다.\n이제부터 이름은 '연돌이'다."},
	{"who": "연이", "pose": "yeoni", "text": "의원님은 요즘 '흑심단'이라는 약 얘기만 하셨어.\n그 약이랑 분명 관련이 있을 거야."},
	{"who": "연이", "pose": "yeoni", "text": "남산 아래 의원님 별채…\n거기에 가면 뭔가 알 수 있을지도 몰라!"},
	{"who": "", "text": "【목표】\n날이 저물기 전에 종로를 빠져나가\n남산 아래 허 의원의 별채에 닿아라.", "end": true},
]

const CHAPTER1_END := [
	{"bg": "yakbang", "who": "", "text": "별채 안은 고요했다.\n서안 위에 펼쳐진 낡은 의서 한 권만이 연이를 기다리고 있었다."},
	{"who": "연이", "pose": "yeoni", "text": "의원님 글씨다…\n'흑심단을 먹은 자는 해가 지면 다른 사람이 된다'…?"},
	{"who": "", "text": "그때, 별채 담 너머로 낯선 사내의 낮은 웃음소리가 들려왔다."},
	{"who": "연이", "pose": "yeoni", "text": "누, 누구세요…?"},
	{"who": "", "text": "― 제1장 「누명」 끝 ―\n다음 장에서 계속됩니다.", "end": true},
]

# ── 보드 칸 대화 ───────────────────────────────────────
const TALKS := [
	{"who": "엿장수", "text": "어이 꼬마, 포졸들이 계집아이 하나를 찾느라 난리더구먼.\n자넨 사내니 상관없겠지? 허허.", "coin": 2},
	{"who": "주막 주모", "text": "남산 쪽 별채? 요 며칠 밤마다 이상한 사내가 드나들던데…\n조심하거라.", "coin": 1},
	{"who": "약재 상인", "text": "허 의원님 단골이었지.\n요즘 무슨 붉은 약을 끓인다고 들었네. 옜다, 약병 하나 가져가.", "potion": 1},
	{"who": "물장수", "text": "왈패들은 고춧가루에 약해.\n눈에 들어가면 한동안 앞을 못 보거든!", "coin": 1},
]

# ── 전투 카드 ─────────────────────────────────────────
# cost: 기력 / dmg: 피해 / block: 막기 / heal: 회복 / slow: 적 게이지 감소(0~1)
const CARDS := {
	"jumeok": {"name": "주먹치기", "icon": "card_jumeok", "cost": 1, "dmg": 4, "desc": "피해 4"},
	"baldda": {"name": "발따귀", "icon": "card_baldda", "cost": 2, "dmg": 9, "desc": "피해 9"},
	"pum": {"name": "품밟기", "icon": "card_pum", "cost": 1, "block": 6, "desc": "막기 6"},
	"gyeot": {"name": "곁치기", "icon": "card_gyeot", "cost": 2, "dmg": 5, "slow": 0.4, "desc": "피해 5\n적 늦춤"},
	"gochu": {"name": "고춧가루", "icon": "card_gochu", "cost": 1, "slow": 1.0, "desc": "적 공격\n초기화"},
	"yak": {"name": "약병", "icon": "card_yak", "cost": 1, "heal": 12, "potion": true, "desc": "체력 +12"},
}
const START_DECK := ["jumeok", "jumeok", "jumeok", "baldda", "baldda", "pum", "pum", "gyeot", "gochu"]

# ── 적 ──────────────────────────────────────────────────
# period: 공격까지 걸리는 초 / atk: 공격력
const ENEMIES := {
	"walpae": {"name": "종로 왈패", "sprite": "walpae", "hp": 22, "atk": 6, "period": 3.6, "coin": 3},
	"pojol": {"name": "포도청 포졸", "sprite": "pojol", "hp": 30, "atk": 8, "period": 4.2, "coin": 5},
}
