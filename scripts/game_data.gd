class_name GameData
## 이야기·카드·적 데이터 (한양 숨바꼭질)
## 바탕: 「지킬 박사와 하이드 씨」(1886, 퍼블릭 도메인)의 이중인격 모티프를 조선으로 옮겨 새로 쓴 이야기

# ── 이야기 ─────────────────────────────────────────────
# who: 말하는 사람(빈칸이면 나레이션) / pose: 인물 그림 / bg: 배경
# choices: [{text, goto, set}] / label: 이동 표식 / goto: 다음 표식 / end: 끝
# if / ifnot: 표식(flag)이 있을 때만 / 없을 때만 보여 줌
const PROLOGUE := [
	# ── 발단: 한양의 약방
	{"bg": "title", "who": "", "text": "조선, 한양.\n종루의 인경이 스물여덟 번 울리면 성문이 닫히고,\n밤거리는 순라꾼의 등불만이 지키는 도성."},
	{"who": "", "text": "그 도성 북촌 어귀에, 가난한 이에게는 약값을 받지 않는다는 작은 약방이 하나 있었다."},
	{"bg": "yakbang", "who": "", "text": "허 의원의 약방.\n그리고 그곳에서 약재 심부름을 하며 사는 열다섯 살 소녀, {name}."},
	{"who": "{name}", "pose": "hero", "text": "의원님! 당귀는 볕에 다 말려 두었고요, 감초는 썰어서 셋째 서랍에 넣어 놨어요."},
	{"who": "허 의원", "pose": "heo", "text": "허허, 손이 빠르구나. 네가 이 약방에 온 지도 벌써 칠 년이로구나."},
	{"who": "", "text": "{name|은} 일곱 살에 역병으로 부모를 잃었다.\n길가에 쓰러져 있던 {name|을} 업어 온 사람이 허 의원이었다."},
	{"who": "{name}", "pose": "hero", "text": "그런데 의원님, 요즘 밤마다 뭘 그렇게 달이세요?\n약방 가득 비린 쇠 냄새가 나던데요."},
	{"who": "허 의원", "pose": "heo", "text": "…흑심단(黑心丹)이라는 약이다.\n사람 마음속의 검은 것, 미움과 욕심만을 따로 떼어 내는 약이지."},
	{"who": "허 의원", "pose": "heo", "text": "그것만 떼어 낼 수 있다면, 세상에 나쁜 사람은 하나도 남지 않을 게다."},
	{"who": "{name}", "pose": "hero", "text": "마음을… 떼어 낸다고요?",
		"choices": [{"text": "그런 약이 정말 있어요?", "goto": "p_wonder"}, {"text": "어쩐지 무섭게 들려요", "goto": "p_fear", "set": "feared"}]},
	{"label": "p_wonder", "who": "허 의원", "pose": "heo", "text": "있고말고. 내가 반드시 만들어 보일 게다.\n…다만, 떼어 낸 검은 것이 어디로 가는지가 문제로구나.", "goto": "p_next"},
	{"label": "p_fear", "who": "허 의원", "pose": "heo", "text": "…그래, 너는 늘 눈이 밝구나.\n나도 실은 조금 무섭단다. 떼어 낸 검은 것이 어디로 가는지 아직 모르니.", "goto": "p_next"},
	{"label": "p_next", "who": "", "text": "허 의원은 웃었지만, 붓을 쥔 손등에는 손톱으로 할퀸 듯한 붉은 자국이 나 있었다."},
	# ── 전개: 운종가의 소문
	{"bg": "jangteo", "who": "", "text": "이튿날 낮, 운종가.\n{name|은} 모자란 약재를 사러 시전 거리로 나섰다."},
	{"who": "약재 상인", "pose": "yakjae", "text": "허 의원님 심부름이냐? 요즘 그 어른, 주사(朱砂)에 만다라 씨앗까지 사 가시던데…\n그런 건 독에 가까운 것들이야."},
	{"who": "약재 상인", "pose": "yakjae", "text": "그리고 조심하거라. 요 며칠 밤, 종로 골목에 검은 갓 쓴 사내가 나타나\n사람들을 마구 해친단다. 웃으면서 말이야."},
	{"who": "{name}", "pose": "hero_sad", "text": "(검은 갓… 요즘 의원님도 밤마다 검은 갓을 쓰고 나가시던데…)"},
	# ── 전개: 봉인된 편지
	{"bg": "yakbang", "who": "", "text": "그날 밤, 통금 인경이 울린 지 한참 뒤에야 허 의원이 돌아왔다.\n얼굴은 흙빛이었고, 도포 자락에는 진흙이 말라붙어 있었다."},
	{"who": "허 의원", "pose": "heo", "text": "{name}아, 잘 듣거라. 이 편지와 열쇠를 네가 맡아 다오."},
	{"who": "허 의원", "pose": "heo", "text": "만일… 내가 내가 아니게 되거든, 이것을 지리산 화엄골의 백운 선생께 전해야 한다.\n내 스승이시다. 절대, 절대 열어 보아서는 안 된다."},
	{"who": "{name}", "pose": "hero_sad", "text": "의원님, 무슨 말씀이세요… 어디 편찮으세요?"},
	{"who": "허 의원", "pose": "heo", "text": "괜찮다. 오늘은 일찍 자거라.\n…그리고 오늘 밤엔 무슨 소리가 나도 방문을 열지 말거라."},
	# ── 위기: 그림자 사내
	{"bg": "alley", "who": "", "text": "자정 무렵.\n쨍그랑, 약병 깨지는 소리에 {name|은} 잠에서 깼다."},
	{"who": "", "text": "문틈으로 내다본 마당에, 낯선 사내 하나가 서 있었다.\n검은 갓, 찢어진 도포, 그리고 달빛에 번들거리는 붉은 눈."},
	{"who": "???", "pose": "shadow", "text": "흐흐흐… 냄새가 나는구나. 꼬마야, 거기 있지?\n그 늙은이가 맡긴 편지, 어디 두었느냐?"},
	{"who": "{name}", "pose": "hero_surprised", "text": "(숨, 숨을 참아야 해… 저 목소리, 어디서 들어 본 것 같은데…)"},
	{"who": "", "text": "사내는 약장을 모조리 뒤엎고는, 동이 틀 무렵 낮게 웃으며 담을 넘어 사라졌다.\n허 의원은 끝내 돌아오지 않았다."},
	# ── 위기: 누명
	{"bg": "yakbang", "who": "", "text": "새벽.\n어지럽혀진 약방에 포도청 포졸들이 들이닥쳤다."},
	{"who": "포졸", "pose": "pojol", "text": "의원은 간데없고 돈궤는 텅 비었다! 핏자국까지 있구나.\n밤새 이 집에 있던 건 저 계집아이 하나뿐이렷다!"},
	{"who": "{name}", "pose": "hero_surprised", "text": "아, 아니에요! 어젯밤에 검은 갓 쓴 사내가…!",
		"choices": [{"text": "억울하다고 끝까지 해명한다", "goto": "explain"}, {"text": "틈을 보아 뒷문으로 달아난다", "goto": "run"}]},
	{"label": "explain", "who": "포졸", "pose": "pojol", "text": "검은 갓? 핑계 한번 그럴싸하구나. 변명은 포도청 형틀 위에서 해라!\n여봐라, 오랏줄을 가져와!"},
	{"who": "{name}", "pose": "hero_sad", "text": "(안 돼… 지금 잡히면 아무도 내 말을 믿어 주지 않아.\n의원님을 찾을 사람도 없어져.)", "goto": "run"},
	{"label": "run", "bg": "alley", "who": "", "text": "{name|은} 편지를 품에 감춘 채 뒷문을 박차고 골목으로 내달렸다."},
	{"who": "포졸", "pose": "pojol_battle", "text": "게 섰거라! 저 계집아이를 잡아라!"},
	{"who": "{name}", "pose": "hero_surprised", "text": "막다른 골목…! 어떡해…!"},
	# ── 친구와의 만남
	{"who": "???", "text": "에잇, 이거나 먹어라!"},
	{"who": "", "text": "어디선가 날아든 고춧가루 한 줌에 포졸이 눈을 감싸 쥐고 나뒹굴었다.\n그 틈에 누군가 {name}의 손목을 확 잡아끌었다."},
	{"who": "다래", "pose": "friend", "text": "이쪽이야! 뛰어!"},
	{"bg": "jangteo", "who": "", "text": "둘은 운종가 뒤편, 주막 헛간에 몸을 숨겼다."},
	{"who": "다래", "pose": "friend", "text": "휴, 따돌렸다. 난 다래야! 지리산에서 약초 캐다가 운종가에 팔러 올라왔어.\n너, 허 의원님 약방 아이지? 약재 사러 올 때 몇 번 봤어."},
	{"who": "{name}", "pose": "hero_sad", "text": "고마워… 그런데 왜 나를 도와줬어?\n다들 내가 의원님을 해쳤다고 하는데."},
	{"who": "다래", "pose": "friend", "text": "포졸한테 쫓기면서도 그 편지만은 꼭 쥐고 있었잖아.\n도둑이었으면 돈을 쥐었겠지."},
	{"who": "주막 주모", "pose": "jumo", "text": "어머, 웬 아가씨들이 헛간에 숨어 있누?\n…쉿, 사정은 묻지 않으마. 국밥이나 한 그릇씩 먹고 가거라."},
	{"who": "다래", "pose": "friend_worried", "text": "그런데 큰일이야. 벌써 종로 네거리마다 방이 붙었어.\n'약방 계집아이를 잡아 오면 상금 열 냥'이래…"},
	{"who": "{name}", "pose": "hero_sad", "text": "의원님이 마지막으로 그러셨어.\n이 편지를 지리산 화엄골 백운 선생께 전하라고."},
	{"who": "다래", "pose": "friend_worried", "text": "…백운? 화엄골의 백운 노인?\n그분, 우리 할아버지야!"},
	{"who": "{name}", "pose": "hero_surprised", "text": "정말?!"},
	{"who": "다래", "pose": "friend", "text": "할아버지는 의원님의 스승님이셨대. 뭔가 아실 거야.\n나도 같이 갈게. 산길은 내가 훤하거든!"},
	{"who": "{name}", "pose": "hero_angry", "text": "…응. 의원님을 찾고, 내 누명도 내 손으로 벗길 거야."},
	{"bg": "title", "who": "", "text": "이튿날 새벽, 파루 종소리와 함께 숭례문이 열렸다.\n두 소녀는 장꾼들 틈에 섞여 한양을 빠져나갔다."},
	{"who": "", "text": "【목표】\n포도청 추격대가 따라잡기 전에, 서른 날 안에\n지리산 화엄골의 백운 노인을 찾아가라.", "end": true},
]

# 보드 중간 이야기 (팝업으로 이어짐)
const STORY1 := [
	{"who": "", "bg": "street_ink", "text": "문경새재 고갯마루.\n주막 앞 담벼락에도 어김없이 방이 붙어 있었다."},
	{"who": "다래", "pic": "friend_worried", "text": "여기까지 방이 붙었어… 그리고 저 사람들 얘기 들었어?\n한양에 밤마다 검은 갓 쓴 사내가 나타나서, 벌써 셋이나 다쳤대."},
	{"who": "{name}", "pic": "hero_sad", "text": "그날 밤 그 사내 목소리…\n이상하게 자꾸 의원님 목소리랑 겹쳐 들려."},
	{"who": "다래", "pic": "friend", "text": "지금은 생각하지 마. 할아버지를 만나면 다 알게 될 거야.\n자, 이 고개만 넘으면 경상도야!"},
]

const STORY2 := [
	{"who": "", "bg": "street_ink", "text": "공주, 금강 나루.\n강 건너편으로 넘어갈 배를 기다리며 두 소녀는 모닥불 곁에 앉았다."},
	{"who": "{name}", "pic": "hero_sad", "text": "(의원님 편지… 이 안에 무슨 일이 있었는지 다 적혀 있을지도 몰라.)",
		"choices": [{"text": "몰래 봉인을 뜯어 본다", "set": "opened"}, {"text": "약속을 지킨다", "set": ""}]},
	{"if": "opened", "who": "", "pic": "hero_surprised", "text": "'스승님, 저는 둘이 되었습니다.\n해가 지면 제 안의 검은 것이 저를 밀어내고 거리로 나갑니다…'\n떨리는 글씨는 거기서 번져 끊겨 있었다."},
	{"if": "opened", "who": "{name}", "pic": "hero_surprised", "text": "둘이…? 그럼 그 검은 갓의 사내가…"},
	{"ifnot": "opened", "who": "다래", "pic": "friend", "text": "잘 참았어. 의원님이 열지 말라고 한 데는 이유가 있을 거야."},
	{"who": "다래", "pic": "friend_worried", "text": "…그런데 아까부터 누가 우리를 따라오는 것 같아.\n강을 건너면 조금만 더 서두르자."},
]

const CHAPTER1_END := [
	{"bg": "byeolchae", "who": "", "text": "지리산 화엄골.\n안개 낀 계곡 끝, 대숲에 둘러싸인 초당에 마침내 닿았다."},
	{"who": "다래", "pose": "friend_worried", "text": "할아버지? 할아버지, 저 다래예요!\n…이상해. 문이 열려 있어."},
	{"who": "", "text": "초당 안은 텅 비어 있었다.\n서안 위에 펼쳐진 의서, 허 의원의 글씨로 쓴 쪽지 한 장,\n그리고 백운 노인이 남긴 짧은 서찰."},
	{"who": "다래", "pose": "friend_worried", "text": "'급한 볼일로 한양에 다녀오마. 찾지 말거라.'\n…할아버지가 한양엘? 산 밖으로는 한 발짝도 안 나가시던 분이…"},
	{"who": "{name}", "pose": "hero_surprised", "text": "'스승님, 흑심단의 해독약은 결국 한양 약방 지하에 숨겨 두었습니다.\n부디 제가 저를 잃기 전에…'"},
	{"if": "opened", "who": "{name}", "pose": "hero_sad", "text": "의원님이 편지에 쓰신 말이랑 같아… '저는 둘이 되었습니다.'"},
	{"who": "", "text": "그때, 대숲 너머에서 낮은 웃음소리가 번져 왔다."},
	{"who": "???", "pose": "shadow", "text": "흐흐흐… 고맙구나, 꼬마야. 그 편지를 여기까지 날라다 주어서.\n백운 그 늙은이를 믿었느냐? 그자는 너희가 아는 그런 사람이 아니다."},
	{"who": "{name}", "pose": "hero_angry", "text": "그 목소리…! 당신, 의원님 몸으로 무슨 짓을 한 거야!"},
	{"who": "???", "pose": "shadow", "text": "의원? 그 물러 터진 늙은이는 이제 해가 떠 있을 때만 잠깐 깨어날 뿐이다.\n밤은, 내 것이다."},
	{"who": "", "text": "그 순간 동녘 능선 위로 해가 솟았다.\n사내는 비명을 지르며 얼굴을 감싸 쥐더니, 안개 속으로 비틀비틀 사라졌다."},
	{"who": "다래", "pose": "friend_worried", "text": "{name}아… 방금 그 사람, 정말 너희 의원님이야?\n할아버지가 그런 사람이 아니라니, 그게 무슨 소리야…"},
	{"who": "{name}", "pose": "hero_angry", "text": "해독약은 한양 약방 지하에 있어.\n돌아가야 해. 의원님도, 너희 할아버지도 구해야 하니까."},
	{"who": "다래", "pose": "friend", "text": "하지만 넌 한양에선 얼굴이 알려졌잖아.\n…그렇다면, 아무도 못 알아보게 하면 되겠네!"},
	{"who": "", "text": "{name|은} 댕기를 풀고, 다래가 내민 패랭이를 깊게 눌러 썼다.\n그날부터 {name|은} 사내아이 '{alias}'가 되었다."},
	{"who": "", "text": "― 제1장 「누명」 끝 ―", "end": true},
]

# ── 보드 칸 대화 ───────────────────────────────────────
const TALKS := [
	{"who": "엿장수", "pic": "yeotjangsu", "text": "엿 사려, 엿! 어이 처자들, 어디까지 가누?\n남쪽 길엔 산적이 들끓는다니, 서낭당에 돌이라도 하나 얹고 가게.", "coin": 2},
	{"who": "주막 주모", "pic": "jumo", "text": "어머, 둘 다 얼굴이 반쪽이네. 국밥이나 먹고 가.\n…참, 어제 포졸들이 계집아이 둘을 찾는다며 지나갔단다.", "potion": 1},
	{"who": "약재 상인", "pic": "yakjae", "text": "화엄골 백운 노인? 그 양반 약초 보는 눈은 조선 제일이지.\n옜다, 약병 하나 가져가거라. 길이 멀다.", "potion": 1},
	{"who": "물장수", "pic": "muljangsu", "text": "목 좀 축이고 가쇼!\n왈패들은 고춧가루에 약하다오. 눈에 들어가면 한동안 기세가 꺾이지!", "coin": 1},
]

# ── 길 위의 사건 ───────────────────────────────────────
# heal: 체력 / maxhp: 최대 체력 / energy: 다음 전투 첫 차례 기력 / guard: 다음 전투 시작 막기
# day: 남은 날 / coin: 엽전 / battle: 전투
const BUFFS := [
	{"title": "약수터", "text": "바위틈에서 솟는 맑은 약수를 마셨다.\n몸이 가뿐해진다.\n\n(체력 +10, 다음 전투 첫 차례 기력 +1)", "heal": 10, "energy": 1},
	{"title": "서낭당", "text": "서낭당 돌무더기에 돌을 하나 얹고 빌었다.\n마음이 든든해진다.\n\n(다음 전투 시작 시 막기 8)", "guard": 8},
	{"title": "어린 산삼", "pic": "friend", "text": "다래가 바위틈에서 어린 산삼 한 뿌리를 찾아냈다!\n\n(최대 체력 +5, 체력 +5)", "maxhp": 5, "heal": 5},
]
const DEBUFFS := [
	{"title": "진흙탕", "text": "밤새 내린 비로 길이 온통 진창이 되었다.\n하루를 더 허비했다.\n\n(남은 날 -1)", "day": -1},
	{"title": "독초", "text": "허기에 산딸기를 따 먹었는데 독초가 섞여 있었다…\n\n(체력 -6)", "hp": -6},
	{"title": "소매치기", "text": "장꾼들 틈에서 엽전 주머니를 털렸다!\n\n(엽전 -3냥)", "coin": -3},
]
const TRAPS := [
	{"title": "사냥꾼의 덫", "text": "수풀 속 덫에 발목이 걸렸다!\n\n(체력 -8)", "hp": -8},
	{"title": "산적 매복", "text": "고갯길 수풀에서 산적이 뛰쳐나왔다!\n\"가진 것 다 내놓고 가라!\"", "battle": "sanjeok"},
	{"title": "관아 검문", "pic": "pojol", "text": "고을 어귀에 검문이 섰다. 방에 그려진 얼굴과 대조하고 있다!\n산길로 돌아가느라 이틀을 잃었다.\n\n(남은 날 -2)", "day": -2},
]
const REST := {"title": "주막", "pic": "jumo", "text": "주막에서 하룻밤 묵어 갔다.\n따뜻한 국밥에 기운이 돈다.\n\n(체력 +20)", "heal": 20}

# ── 전투 카드 ─────────────────────────────────────────
# cost: 기력 / dmg: 피해 / block: 막기 / slow: 적 기세 감소(칸, 99 = 초기화) / coin: 엽전
# 같은 카드 두 장을 합치면 단계(★)가 오르고, 피해·막기가 50%씩 커진다 (최대 ★3)
const CARDS := {
	"jumeok": {"name": "주먹치기", "icon": "card_jumeok", "cost": 1, "dmg": 4},
	"baldda": {"name": "발따귀", "icon": "card_baldda", "cost": 2, "dmg": 9},
	"pum": {"name": "품밟기", "icon": "card_pum", "cost": 1, "block": 6},
	"gyeot": {"name": "곁치기", "icon": "card_gyeot", "cost": 2, "dmg": 5, "slow": 1},
	"gochu": {"name": "고춧가루", "icon": "card_gochu", "cost": 1, "slow": 99},
	"nalchi": {"name": "날치기", "icon": "card_nalchi", "cost": 1, "dmg": 3, "coin": 1},
}
const START_DECK := ["jumeok", "jumeok", "jumeok", "baldda", "baldda", "pum", "pum", "gyeot", "gochu"]
const REWARD_POOL := ["jumeok", "jumeok", "baldda", "pum", "pum", "gyeot", "gochu", "nalchi"]
const MAX_LV := 3
const MIN_DECK := 6

static func stats(id: String, lv: int) -> Dictionary:
	var c: Dictionary = CARDS[id].duplicate()
	var mul := 1.0 + 0.5 * (lv - 1)
	for k in ["dmg", "block"]:
		if c.has(k):
			c[k] = int(round(c[k] * mul))
	if c.has("coin"):
		c["coin"] = c["coin"] + (lv - 1)
	if id == "gyeot" and lv >= 3:
		c["slow"] = 2
	if id == "gochu" and lv > 1:
		c["dmg"] = 3 * (lv - 1)
	var lines := []
	if c.has("dmg"): lines.append("피해 %d" % c["dmg"])
	if c.has("block"): lines.append("막기 %d" % c["block"])
	if c.has("heal"): lines.append("체력 +%d" % c["heal"])
	if c.has("slow"): lines.append("기세 초기화" if c["slow"] >= 99 else "기세 -%d" % c["slow"])
	if c.has("coin"): lines.append("엽전 +%d" % c["coin"])
	c["desc"] = "\n".join(PackedStringArray(lines))
	c["lv"] = lv
	c["icon_ui"] = id
	return c

# ── 적 ──────────────────────────────────────────────────
# 차례제: 적은 내 차례가 끝날 때마다 moves 를 차례로 한 번씩 행동하고 기세가 한 칸 오른다.
# 기세가 charge 칸 차면 그 차례에는 heavy(필살) 공격. 고춧가루·곁치기로 기세를 꺾을 수 있다.
const ENEMIES := {
	"walpae": {"name": "종로 왈패", "sprite": "walpae", "hp": 26, "coin": 3, "charge": 3,
		"moves": [{"t": "atk", "v": 6, "n": "주먹질"}, {"t": "def", "v": 6, "n": "버티기"}, {"t": "atk", "v": 7, "n": "발길질"}],
		"heavy": {"t": "atk", "v": 13, "n": "몽둥이 내려치기"}},
	"sanjeok": {"name": "고갯길 산적", "sprite": "walpae", "hp": 30, "coin": 5, "charge": 3,
		"moves": [{"t": "atk", "v": 7, "n": "몽둥이질"}, {"t": "atk", "v": 5, "n": "멱살잡이"}, {"t": "def", "v": 7, "n": "버티기"}],
		"heavy": {"t": "atk", "v": 14, "n": "통나무 휘두르기"}},
	"rival": {"name": "흑룡파 왈패", "sprite": "walpae", "hp": 30, "coin": 4, "charge": 3,
		"moves": [{"t": "atk", "v": 7, "n": "칼등 치기"}, {"t": "def", "v": 7, "n": "버티기"}, {"t": "atk", "v": 8, "n": "박치기"}],
		"heavy": {"t": "atk", "v": 15, "n": "쇠사슬 휘두르기"}},
	"mob": {"name": "청심보명단 중독자", "sprite": "addict", "hp": 28, "coin": 3, "charge": 2,
		"moves": [{"t": "atk", "v": 6, "n": "할퀴기"}, {"t": "atk", "v": 7, "n": "달려들기"}],
		"heavy": {"t": "atk", "v": 12, "n": "광란"}},
	"seohwi": {"name": "청안 서휘", "sprite": "seohwi_battle", "hp": 70, "coin": 0, "charge": 3, "boss": true,
		"moves": [{"t": "atk", "v": 9, "n": "정권 찌르기"}, {"t": "def", "v": 10, "n": "흘려 막기"}, {"t": "atk", "v": 11, "n": "돌려차기"}],
		"heavy": {"t": "atk", "v": 22, "n": "청안 연격"}},
	"seohwi2": {"name": "청안 서휘", "sprite": "seohwi_battle", "hp": 58, "coin": 10, "charge": 3, "boss": true,
		"moves": [{"t": "atk", "v": 8, "n": "정권 찌르기"}, {"t": "def", "v": 9, "n": "흘려 막기"}, {"t": "atk", "v": 10, "n": "돌려차기"}],
		"heavy": {"t": "atk", "v": 18, "n": "청안 연격"}},
	"baegun": {"name": "대대장 백운", "sprite": "baegun_boss", "hp": 100, "coin": 30, "charge": 3, "boss": true,
		"moves": [{"t": "atk", "v": 10, "n": "독침 날리기"}, {"t": "def", "v": 12, "n": "약연 방패"}, {"t": "atk", "v": 12, "n": "지팡이 내려치기"}],
		"heavy": {"t": "atk", "v": 24, "n": "흑심 독무"}},
	"darae": {"name": "다래", "sprite": "friend_worried", "hp": 36, "coin": 0, "charge": 4, "boss": true,
		"moves": [{"t": "atk", "v": 4, "n": "울면서 밀치기"}, {"t": "atk", "v": 5, "n": "약초 바구니 휘두르기"}],
		"heavy": {"t": "atk", "v": 8, "n": "\"바보야!\""}},
	"shadow": {"name": "검은 사내", "sprite": "shadow", "hp": 140, "coin": 0, "charge": 3, "boss": true,
		"moves": [{"t": "atk", "v": 11, "n": "검은 손아귀"}, {"t": "atk", "v": 13, "n": "어둠 찢기"}, {"t": "def", "v": 14, "n": "그림자 두르기"}],
		"heavy": {"t": "atk", "v": 28, "n": "흑심 폭주"}},
	"haejeok": {"name": "뱃사람 무뢰배", "sprite": "haejeok", "hp": 34, "coin": 6, "charge": 3,
		"moves": [{"t": "atk", "v": 8, "n": "단검 찌르기"}, {"t": "def", "v": 8, "n": "몸 피하기"}, {"t": "atk", "v": 9, "n": "갈고리 휘두르기"}],
		"heavy": {"t": "atk", "v": 17, "n": "선원 칼춤"}},
	"rat": {"name": "역병 쥐떼", "sprite": "rat", "hp": 26, "coin": 2, "charge": 2,
		"moves": [{"t": "atk", "v": 6, "n": "물어뜯기"}, {"t": "atk", "v": 5, "n": "우르르 몰려들기"}],
		"heavy": {"t": "atk", "v": 12, "n": "역병 퍼뜨리기"}},
	"pojol": {"name": "포도청 포졸", "sprite": "pojol_battle", "hp": 34, "coin": 5, "charge": 4,
		"moves": [{"t": "atk", "v": 7, "n": "창대 치기"}, {"t": "def", "v": 8, "n": "창 겨누기"}, {"t": "atk", "v": 8, "n": "오랏줄 던지기"}],
		"heavy": {"t": "atk", "v": 16, "n": "창 찌르기"}},
}
