class_name StoryData
## 제2장~제5장 이야기, 장(章) 설정, 장별 길 위 대화
## 인물: 윤도결(포도청 종사관) · 서휘(왈패 대장, 푸른 눈의 혼혈, 애체(안경)) · 백운(다래 할아버지 = 왈패 대대장)

# ── 장 설정 ─────────────────────────────────────────────
# board: 보드 파일 / days: 기한 / goal: 목적지 이름 / goal_pre·goal_battle·goal_lose_ok: 목적지에서 벌어지는 이야기와 싸움
const CHAPTERS := {
	1: {"title": "제1장  누명", "board": "board1", "days": 30, "goal": "화엄골", "intro": "PROLOGUE", "end": "CHAPTER1_END",
		"goal_text": "안개 낀 계곡 끝, 대숲 속 초당이 보인다.\n지리산 화엄골에 도착했다!", "goal_title": "화엄골", "goal_pic": "friend", "goal_bg": "byeolchae"},
	2: {"title": "제2장  남장", "board": "board2", "days": 26, "goal": "한양 약방", "intro": "CH2_INTRO", "end": "CH2_END",
		"goal_pre": "CH2_GOAL", "goal_battle": "seohwi", "goal_lose_ok": true},
	3: {"title": "제3장  왈패 소굴", "board": "board3", "days": 24, "goal": "왈패 소굴", "intro": "CH3_INTRO", "end": "CH3_END",
		"goal_text_pic": "",
		"goal_text": "청계천 다리 밑, 왈패 소굴로 돌아왔다.\n안쪽 방에서 낮은 목소리가 새어 나온다…", "goal_title": "왈패 소굴", "goal_pic": "", "goal_bg": "den"},
	4: {"title": "제4장  대대장", "board": "board4", "days": 24, "goal": "화엄골 지하", "intro": "CH4_INTRO", "end": "CH4_END",
		"goal_pre": "CH4_GOAL", "goal_battle": "baegun", "goal_ally": "seohwi",
		"end_battle": "darae", "end_after": "CH4_AFTER_DUEL"},
	5: {"title": "제5장  어의", "board": "board5", "days": 22, "goal": "허 의원 약방", "intro": "CH5_INTRO", "end": "CH5_END",
		"goal_pre": "CH5_GOAL", "goal_battle": "shadow", "goal_ally": "dogyeol"},
}

static func lines(key: String) -> Array:
	match key:
		"PROLOGUE": return GameData.PROLOGUE
		"CHAPTER1_END": return GameData.CHAPTER1_END
		"story1": return GameData.STORY1
		"story2": return GameData.STORY2
	return ALL.get(key, [])

# ── 제2장 「남장」 ───────────────────────────────────────
const CH2_INTRO := [
	{"bg": "byeolchae", "who": "", "text": "― 제2장 「남장」 ―"},
	{"who": "", "pose": "hero_disguise", "text": "패랭이 아래로 머리를 감추고, 가슴엔 무명천을 단단히 둘렀다.\n거울 속에는 낯선 사내아이 하나가 서 있었다."},
	{"who": "다래", "pose": "friend", "text": "와… 진짜 누가 봐도 사내아이야.\n목소리만 조금 낮추면 되겠어. 자, 이름을 불러 볼까? {alias}!"},
	{"who": "{alias}", "pose": "hero_disguise", "text": "…으, 응. 어색하다.\n그래도 이제 한양에 들어갈 수 있어."},
	{"who": "다래", "pose": "friend_worried", "text": "할아버지도 한양에 계시댔지. 의원님의 해독약도 한양 약방 지하에 있고.\n…저 검은 사내도 결국 한양으로 가겠지?"},
	{"who": "{alias}", "pose": "hero_disguise_angry", "text": "그러니까 우리가 먼저 가야 해.\n약방 지하에서 해독약을 찾아내기 전엔 절대 안 잡혀."},
	{"who": "", "text": "【목표】\n스물엿새 안에 서쪽 길로 돌아 한양 약방에 닿아라.\n남장이 들키지 않도록 조심할 것.", "end": true},
]

const C2_DOGYEOL := [
	{"who": "", "bg": "street_ink", "text": "어느 고을 어귀, 검문소.\n붉은 술 전립을 쓴 포졸들 사이로, 검은 철릭의 젊은 관리 하나가 걸어 나왔다."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "포도청 종사관 윤도결이다.\n한양 약방 사건의 계집아이를 쫓아 여기까지 왔지."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "…너. 사내아이치곤 손이 곱구나. 약초 냄새도 나고.\n어디서 왔느냐?",
		"choices": [{"text": "지리산 약초꾼이라 둘러댄다", "set": "c2_lie"}, {"text": "고개를 숙이고 입을 다문다", "set": ""}]},
	{"if": "c2_lie", "who": "다래", "pic": "friend", "text": "맞아요, 나리! 얘는 제 사촌 동생이에요. 둘이 약초 팔러 한양 가는 길이고요!"},
	{"who": "윤도결", "pic": "jongsagwan", "text": "흠… 가 봐라. 하지만 기억해 두마.\n그 계집아이는 의원을 해치고 돈궤를 턴 흉악범이다. 반드시 내 손으로 잡는다."},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "(…나 아니라고요. 정말로.)"},
]

const C2_PLAGUE := [
	{"who": "", "bg": "street_ink", "text": "작은 마을 하나가 열병에 신음하고 있었다.\n의원은 이미 도망가고, 아이들만 거적 위에 누워 있었다."},
	{"who": "다래", "pic": "friend_worried", "text": "{alias}, 그냥 지나가자. 포졸들이 바로 뒤에 있어!"},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "…의원님이라면 그냥 지나치지 않으셨을 거야.\n다래야, 쑥이랑 금은화 좀 캐다 줘. 이 열은 내릴 수 있어.",
		"choices": [{"text": "밤새 아이들을 돌본다", "set": "c2_healed"}, {"text": "약만 지어 주고 서둘러 떠난다", "set": ""}]},
	{"if": "c2_healed", "who": "", "text": "{alias}는 밤새 아이들의 이마를 식히고 약을 달였다.\n새벽녘, 열이 내린 아이가 처음으로 웃었다."},
	{"who": "", "text": "그 모습을, 마을 어귀 나무 그늘에서 누군가 말없이 지켜보고 있었다."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "(…저런 아이가 정말 사람을 해치고 돈을 훔쳤을까.\n방에 적힌 것과는 영 딴판이로군.)"},
	{"if": "c2_healed", "who": "", "text": "(보너스: 마을 사람들이 고맙다며 엽전과 약병을 쥐여 주었다.)", "coin": 6, "potion": 1},
]

const CH2_GOAL := [
	{"who": "", "bg": "yakbang", "text": "마침내 한양, 허 의원의 약방.\n그런데 부서진 대문 안에서 웬 사내들의 웃음소리가 들려왔다."},
	{"who": "", "text": "약방은 이미 왈패들 차지였다.\n약장은 뜯겨 나가고, 마당엔 술독이 굴러다녔다."},
	{"who": "???", "pic": "seohwi", "text": "손님이 왔구나. 여긴 이제 우리 '청안파'의 집이다.\n…어린 약초꾼이 무슨 볼일이지?"},
	{"who": "", "text": "흐트러진 금빛 머리칼, 서양식 애체(안경) 너머로 빛나는 푸른 눈.\n왈패라기엔 지나치게 단정한 말씨의 사내였다."},
	{"who": "서휘", "pic": "seohwi", "text": "나는 서휘. 이 동네에선 '청안(靑眼)'이라고들 부르지.\n약방 지하실을 찾는다면… 미안하지만 그건 내 물건이다."},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "여긴 허 의원님 약방이야! 당장 나가!"},
	{"who": "서휘", "pic": "seohwi_battle", "text": "후후, 용감하군. 그럼 한번 증명해 보시지.", "end": true},
]

const CH2_END := [
	{"bg": "den", "who": "", "text": "…서휘는 강했다.\n{alias}의 주먹은 단 한 번도 그의 애체를 건드리지 못했다."},
	{"who": "서휘", "pose": "seohwi", "text": "기술은 나쁘지 않아. 하지만 넌 사람을 때려 본 적이 없는 손이야.\n…그 대신, 약초 냄새가 짙군."},
	{"who": "", "text": "그때, 왈패 둘이 몸부림치는 다래를 끌고 들어왔다."},
	{"who": "다래", "pose": "friend_worried", "text": "이거 놔! {alias}, 도망쳐!"},
	{"who": "서휘", "pose": "seohwi", "text": "거래를 하지. 내 아이들 중엔 다친 놈, 병든 놈이 많다.\n네가 우리 소굴의 의원이 되어 준다면, 이 아가씨는 털끝 하나 건드리지 않겠다."},
	{"who": "{alias}", "pose": "hero_disguise_sad", "text": "…거절하면?"},
	{"who": "서휘", "pose": "seohwi", "text": "거절할 리가 없지. 넌 저 아이를 버리고 갈 사람이 아니니까.",
		"choices": [{"text": "\"…약속은 지켜.\"", "set": ""}, {"text": "\"다래한테 손대면 가만 안 둬.\"", "set": "c2_threat"}]},
	{"if": "c2_threat", "who": "서휘", "pose": "seohwi", "text": "후후, 좋은 눈빛이다. 걱정 마라. 나는 약속은 지킨다."},
	{"who": "다래", "pose": "friend_worried", "text": "{alias}… 안 돼…!"},
	{"who": "", "text": "그렇게 {alias}는 다래와 떨어져, 왈패 소굴의 의원이 되었다.", "end": true},
]

# ── 제3장 「왈패 소굴」 ─────────────────────────────────
const CH3_INTRO := [
	{"bg": "den", "who": "", "text": "― 제3장 「왈패 소굴」 ―"},
	{"who": "", "text": "청계천 수표교 아래, 비밀 창고.\n{alias}는 매일 아침 왈패들의 찢어진 이마를 꿰매고, 부러진 팔에 부목을 댔다."},
	{"who": "왈패", "pose": "walpae", "text": "어이 꼬마 의원, 어제 준 고약 말이야… 진짜 하나도 안 아프더라.\n…고맙다."},
	{"who": "{alias}", "pose": "hero_disguise", "text": "(무서운 사람들인 줄만 알았는데… 대부분 갈 곳 없는 아이들이었어.)"},
	{"who": "서휘", "pose": "seohwi", "text": "놀랐나? 다들 역병에 부모를 잃었거나, 빚 때문에 쫓겨난 놈들이다.\n나도 마찬가지고. 푸른 눈의 혼혈아를 받아 주는 곳은 이 다리 밑뿐이었지."},
	{"who": "서휘", "pose": "seohwi", "text": "그래서 너에게 맡길 일이 있다.\n'청심보명단(淸心保命丹)'. 기운을 북돋는 자양강장 환약이다. 이 처방대로 빚어라."},
	{"who": "{alias}", "pose": "hero_disguise", "text": "인삼, 녹용, 감초… 그리고 이건… 처음 보는 붉은 씨앗이네.\n그래도 처방은 훌륭해 보여. 이 정도면 몸이 약한 사람들한테 좋겠다."},
	{"who": "", "text": "【목표】\n스물나흘 안에 한양 곳곳을 돌며 약재를 모으고\n청심보명단을 전한 뒤 왈패 소굴로 돌아와라.", "end": true},
]

const C3_DOGYEOL := [
	{"who": "", "bg": "stream", "text": "청계천 둑길, 해 질 녘.\n약재 꾸러미를 안고 가던 {alias}의 앞을 누군가 막아섰다."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "또 만났구나, 약초꾼.\n…아니, 이젠 청안파의 꼬마 의원이라지?"},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "잡아가실 거면, 잡아가세요."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "그날 열병 마을에서 네가 밤새 아이들을 돌보는 걸 봤다.\n나는… 네가 그 흉악범이라고 믿지 않는다."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "약방 사건엔 이상한 게 너무 많아. 돈궤를 연 손은 어른의 손이었고, 핏자국은 의원 본인 것이었다.\n…진짜 범인을 찾고 싶다. 도와주겠느냐?"},
	{"who": "{alias}", "pic": "hero_disguise", "text": "…네. 저도 꼭 찾고 싶어요."},
	{"who": "", "text": "돌아서는 {alias}의 뒷모습을 보며, 윤도결은 제 가슴께를 눌렀다."},
	{"who": "윤도결", "pic": "jongsagwan_blush", "text": "(…왜 이러지. 사내아이를 보고 가슴이 뛰다니.\n정신 차려라, 윤도결. 이러면 안 된다…)"},
]

const C3_TRUTH := [
	{"who": "", "bg": "street_ink", "text": "종로 뒷골목.\n머리를 쥐어뜯으며 벽에 머리를 찧는 사내가 있었다."},
	{"who": "백성", "pic": "addict", "text": "약… 약을 더 다오… 청심보명단…\n머리가… 머리가 깨질 것 같아…!"},
	{"who": "{alias}", "pic": "hero_disguise_surprised", "text": "청심보명단…? 내가 빚은 약이잖아!"},
	{"who": "", "text": "{alias}는 남은 환약 하나를 쪼개어 혀끝에 대 보았다.\n달콤한 감초 맛 뒤로, 혀가 저릿할 만큼 쓴맛이 번졌다."},
	{"who": "{alias}", "pic": "hero_disguise_surprised", "text": "이 붉은 씨앗… 만다라야. 그리고 주사(朱砂)까지.\n의원님이 흑심단에 넣던 거랑 똑같아…!"},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "처음엔 기운이 나는 것 같지만, 끊으면 머리가 깨질 듯 아프고…\n오래 먹으면 정신이 무너져. 내가… 내가 이걸 만들어서 팔았어…"},
	{"who": "", "text": "그날 밤, {alias}는 소굴로 달려가 서휘의 멱살을 잡았다."},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "당장 멈춰! 이건 약이 아니라 독이야!\n사람들이 미쳐 가고 있다고!"},
	{"who": "서휘", "pic": "seohwi", "text": "…알고 있다.\n하지만 이 약 한 알이면 쌀 한 되를 산다. 내 아이들 쉰 명이 그걸로 겨울을 난다."},
	{"who": "서휘", "pic": "seohwi", "text": "세상은 우릴 굶겨 죽이려 했지. 그런데 이제 와서 착하게 살라고?\n…계속 빚어라, 의원. 다래를 생각해서라도.",
		"choices": [{"text": "\"…알겠어.\" 일단 따르는 척한다", "set": "c3_pretend"}, {"text": "\"싫어. 차라리 날 때려.\"", "set": "c3_refuse"}]},
	{"if": "c3_refuse", "who": "서휘", "pic": "seohwi", "text": "…그 눈빛. 정말 싫군.\n오늘은 넘어가지. 하지만 약은 내일도 나간다."},
	{"if": "c3_pretend", "who": "{alias}", "pic": "hero_disguise_sad", "text": "(…몰래 만다라를 빼고 감초만 넣자. 그거라도 해야 해.)"},
	{"who": "", "text": "다음 날도, 그다음 날도 사람들은 청심보명단을 사러 줄을 섰다."},
]

const C3_BOSS := [
	{"who": "서휘", "pic": "seohwi_battle", "text": "몰래 처방을 바꿨더군. 손님들이 약발이 안 든다고 아우성이다.\n…다시 한번 가르쳐 줘야겠나?"},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "이번엔 안 져!"},
]
const C3_BOSS_WIN := [
	{"who": "서휘", "pic": "seohwi", "text": "…하. 처음 왔을 때랑은 딴사람이로군.\n좋아. 오늘 밤만큼은 네 처방대로 해라."},
	{"who": "", "text": "서휘는 깨진 애체를 고쳐 쓰고는, 무언가 고민하는 얼굴로 소굴 안쪽으로 사라졌다."},
]

const CH3_END := [
	{"bg": "den", "who": "", "text": "소굴 가장 안쪽, 늘 잠겨 있던 방.\n{alias}는 문틈에 귀를 댔다."},
	{"who": "서휘", "pose": "seohwi", "text": "…대대장 어른. 이제 그 약은 그만 만들게 해 주십시오.\n종로에서만 벌써 셋이 미쳐서 우물에 몸을 던졌습니다."},
	{"who": "???", "pose": "baegun_boss", "text": "그만? 서휘야, 넌 아직 셈을 모르는구나.\n그 약 한 상자가 은 열 냥이다. 내가 너희를 거둬 먹인 은혜를 벌써 잊었느냐?"},
	{"who": "???", "pose": "baegun_boss", "text": "그리고 그 꼬마 의원… 허가 놈이 거둔 계집아이 맞지?\n잘 붙잡아 둬라. 쓸모가 많을 게다."},
	{"who": "{alias}", "pose": "hero_disguise_surprised", "text": "(…계집아이인 걸 알고 있어?! 그리고 저 목소리… 어디서…)"},
	{"who": "", "text": "덜컥. 발밑의 널빤지가 울렸다.\n방문이 열리고, 서휘가 {alias}를 내려다보았다."},
	{"who": "서휘", "pose": "seohwi", "text": "…다 들었나.\n좋다. 이제 숨길 것도 없군. 내일 아침, 너에게 할 이야기가 있다.", "end": true},
]

# ── 제4장 「대대장」 ─────────────────────────────────────
const CH4_INTRO := [
	{"bg": "den", "who": "", "text": "― 제4장 「대대장」 ―"},
	{"who": "서휘", "pose": "seohwi", "text": "청심보명단의 처방을 준 건 대대장이다.\n얼굴은 늘 삿갓으로 가리지만, 돈은 전부 남쪽 지리산으로 실려 간다."},
	{"who": "서휘", "pose": "seohwi", "text": "나는 이제 더는 못 하겠다. 내 아이들한테 독을 팔게 할 순 없어.\n…네 힘을 빌리고 싶다, 의원."},
	{"who": "{alias}", "pose": "hero_disguise", "text": "그 전에, 다래부터 풀어 줘."},
	{"who": "서휘", "pose": "seohwi", "text": "이미 풀어 줬다. 할아버지께 알리겠다며 먼저 지리산으로 떠났지.\n…그리고, 너한테 이것도 돌려주마."},
	{"who": "", "text": "서휘가 내민 것은 허 의원 약방 지하실의 열쇠였다."},
	{"who": "서휘", "pose": "seohwi", "text": "지하실엔 아무것도 없었다. 해독약 처방을 적은 책장만 통째로 뜯겨 나갔더군.\n가져간 사람은… 대대장일 거다."},
	{"who": "", "text": "【목표】\n서휘와 함께 대대장의 돈이 흘러가는 지리산 화엄골로 향하라.\n이번에는 서쪽 바닷길이다.", "end": true},
]

const C4_STREAM := [
	{"who": "", "bg": "stream", "text": "한양을 떠나기 전날 밤, 장맛비가 쏟아졌다.\n불어난 청계천에 한 아이가 휩쓸려 가고 있었다."},
	{"who": "{alias}", "pic": "hero_disguise_surprised", "text": "안 돼!"},
	{"who": "", "text": "{alias}는 망설임 없이 물에 뛰어들었다.\n아이를 둑으로 밀어 올린 순간, 거센 물살이 {alias}를 삼켰다."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "{alias}!!"},
	{"who": "", "text": "철릭을 벗어 던진 윤도결이 뒤따라 뛰어들었다.\n한참 뒤, 둑 위로 끌어올려진 {alias}의 패랭이는 이미 떠내려가고 없었다."},
	{"who": "", "pic": "hero_sad", "text": "젖은 무명천 아래로 풀려 내린 긴 머리.\n가냘픈 어깨. 그리고 숨을 몰아쉬며 눈을 뜬 얼굴은…"},
	{"who": "윤도결", "pic": "jongsagwan_blush", "text": "…여, 여자였어…?\n그럼 네가… 방에 붙은 그 약방 계집아이…"},
	{"who": "{name}", "pic": "hero_sad", "text": "…제 이름은 {name}예요.\n속여서 죄송해요. 하지만 의원님을 해친 건 정말 제가 아니에요."},
	{"who": "윤도결", "pic": "jongsagwan_blush", "text": "(그동안 사내아이를 마음에 둔 줄 알고 얼마나 괴로웠는데…\n…다행이다. 정말, 다행이야.)"},
	{"who": "윤도결", "pic": "jongsagwan", "text": "알고 있다. 넌 범인이 아니야. 내가 증명해 주마.\n…그러니까, 다시는 그렇게 혼자 물에 뛰어들지 마라."},
	{"who": "", "text": "(윤도결이 몰래 뒤를 봐주기로 했다. 다음 전투 시작 시 막기 10)", "guard": 10},
]

const C4_CLUE := [
	{"who": "", "bg": "street_ink", "text": "어느 포구의 객주.\n장부를 뒤지던 서휘가 손가락으로 한 줄을 짚었다."},
	{"who": "서휘", "pic": "seohwi", "text": "'청심보명단 대금, 은 삼백 냥. 화엄골 백(白) 노인 앞.'\n…화엄골. 다래라는 아이의 고향 아닌가?"},
	{"who": "{alias}", "pic": "hero_disguise_surprised", "text": "백… 노인…?\n설마. 설마 다래 할아버지가…"},
	{"who": "서휘", "pic": "seohwi", "text": "아직 모른다. 하지만 각오는 해 두는 게 좋겠군."},
]

const CH4_GOAL := [
	{"who": "", "bg": "vault", "text": "화엄골 초당 아래, 대숲 바위틈에 숨겨진 석굴.\n안에는 은궤와 청심보명단 상자가 산처럼 쌓여 있었다."},
	{"who": "???", "pic": "baegun_boss", "text": "기어이 여기까지 왔구나. 서휘, 그리고… 허가 놈의 계집아이."},
	{"who": "", "text": "삿갓이 벗겨졌다.\n하얗게 센 수염, 자애롭게 웃던 다래의 할아버지."},
	{"who": "백운", "pic": "baegun_boss", "text": "흑심단은 원래 내 처방이었다. 마음의 검은 것을 떼어 내는 약?\n그건 허가 놈의 헛된 꿈이었지. 나는 그 약으로 사람을 길들이는 법을 알아냈을 뿐."},
	{"who": "백운", "pic": "baegun_boss", "text": "허가 놈이 제 몸에 흑심단을 시험하도록 부추긴 것도 나다.\n그 검은 사내는 내가 쓰기 좋은 개였지. 흐흐흐…"},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "당신이… 당신 때문에 의원님이…!\n다래가 얼마나 할아버지를 자랑스러워했는데!"},
	{"who": "서휘", "pic": "seohwi_battle", "text": "의원, 같이 간다. 내 아이들의 몫까지.", "end": true},
]

const CH4_END := [
	{"bg": "vault", "who": "", "text": "백운이 무릎을 꿇었다.\n뒤따라온 윤도결과 포졸들이 노인을 오랏줄로 묶었다."},
	{"who": "다래", "pose": "friend_worried", "text": "할아버지?! …{alias}, 너…\n우리 할아버지한테 무슨 짓을 한 거야!"},
	{"who": "{alias}", "pose": "hero_disguise_sad", "text": "다래야, 들어 봐. 할아버지가 청심보명단을…"},
	{"who": "다래", "pose": "friend_worried", "text": "듣기 싫어! 너만 믿고 따라왔는데…\n결국 우리 할아버지를 포도청에 넘기려고 날 이용한 거잖아!", "end": true},
]

const CH4_AFTER_DUEL := [
	{"bg": "vault", "who": "", "text": "다래의 주먹이 힘없이 풀렸다.\n그때, 묶여 있던 백운이 쉰 목소리로 입을 열었다."},
	{"who": "백운", "pose": "baegun", "text": "…그만해라, 다래야. 그 아이 말이 맞다.\n이 할애비가 돈에 눈이 멀어 몹쓸 짓을 했다."},
	{"who": "백운", "pose": "baegun", "text": "약방 지하에서 가져간 해독약 처방은 저 궤짝 안에 있다.\n…허가를 살려 다오. 그게 내가 할 수 있는 마지막 속죄다."},
	{"who": "다래", "pose": "friend_worried", "text": "할아버지…\n…{alias}, 아니, {name}아. 미안해. 정말 미안해…"},
	{"who": "{name}", "pose": "hero_sad", "text": "나도 미안해. 더 일찍 말했어야 했는데.\n…우리, 아직 친구지?"},
	{"who": "다래", "pose": "friend", "text": "당연하지, 바보야!"},
	{"who": "", "text": "석굴 입구에서 그 모습을 지켜보던 서휘가 깨진 애체를 고쳐 썼다."},
	{"who": "서휘", "pose": "seohwi", "text": "…{name}이라. 이제야 진짜 이름을 듣는군.\n(독을 빚게 한 나를 끝까지 사람으로 대해 준 사람. …잊지 못하겠군.)"},
	{"who": "", "text": "― 제4장 「대대장」 끝 ―", "end": true},
]

# ── 제5장 「어의」 ─────────────────────────────────────
const CH5_INTRO := [
	{"bg": "palace", "who": "", "text": "― 제5장 「어의」 ―"},
	{"who": "", "text": "청안파와 그 대대장을 쓰러뜨린 소녀 의원.\n소문은 바람보다 빨리 팔도에 퍼졌다."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "{name}, 너의 누명은 모두 벗겨졌다.\n그리고… 전하께서 너를 부르신다."},
	{"who": "", "text": "경복궁 강녕전."},
	{"who": "임금", "pose": "king", "text": "그대가 청심보명단의 독을 밝히고 백성을 구한 의원이로구나.\n여인의 몸으로 그리 하였다니 더욱 기특하도다."},
	{"who": "임금", "pose": "king", "text": "내 그대를 내의원의 의녀로 삼고, 특별히 어의의 소임을 맡기겠노라.\n청심보명단에 상한 백성들을 고쳐 다오."},
	{"who": "{name}", "pose": "hero_physician", "text": "황공하옵니다, 전하.\n…다만 한 가지 청이 있사옵니다. 제 동무 다래도 궁에 함께 들게 해 주시옵소서."},
	{"who": "다래", "pose": "darae_court", "text": "헤헤, 궁녀복 어때? 이제 매일 같이 있을 수 있어!\n약초 캐는 건 여전히 내가 최고니까, 필요하면 언제든 불러!"},
	{"who": "", "text": "{name|은} 내의원에서 백운의 궤짝 속 처방을 펼쳤다.\n허 의원이 남긴 해독약, '환심단(還心丹)'. 그러나 약재 몇 가지가 빠져 있었다."},
	{"who": "", "text": "【목표】\n한양 곳곳에서 환심단의 약재를 모아\n허 의원의 약방, 그 검은 사내가 기다리는 곳으로 가라.", "end": true},
]

const C5_SEOHWI := [
	{"who": "", "bg": "street_ink", "text": "종로 네거리. 낯익은 금빛 머리칼이 보였다."},
	{"who": "서휘", "pic": "seohwi", "text": "어의 나으리께서 여긴 어쩐 일이신가.\n…농담이다. 청안파는 이제 약방 대신 짐꾼 일을 한다. 정직하게 벌어서 정직하게 먹지."},
	{"who": "서휘", "pic": "seohwi", "text": "환심단에 들어갈 '백년 묵은 하수오'를 찾는다고?\n내 아이들이 남산 바위틈에서 하나 캐 왔다. 받아라."},
	{"who": "{name}", "pic": "hero_physician", "text": "서휘… 고마워."},
	{"who": "서휘", "pic": "seohwi", "text": "…고맙다는 말은 됐다.\n(그 말 한마디에 이렇게 흔들리다니. 나도 한심하군.)"},
	{"who": "", "text": "(서휘의 하수오: 최대 체력 +10, 체력 +10)", "maxhp": 10, "heal": 10},
]

const C5_DOGYEOL := [
	{"who": "", "bg": "palace", "text": "궁궐 담장 아래, 달밤.\n순찰을 돌던 윤도결이 걸음을 멈췄다."},
	{"who": "윤도결", "pic": "jongsagwan_blush", "text": "{name}. 내일 밤, 그 검은 사내를 상대하러 간다고 들었다.\n…나도 간다. 말리지 마라."},
	{"who": "윤도결", "pic": "jongsagwan_blush", "text": "처음엔 너를 흉악범으로 쫓았고, 그다음엔 사내아이인 줄 알고 혼자 괴로워했지.\n이제야 겨우… 너를 똑바로 볼 수 있게 됐다."},
	{"who": "{name}", "pic": "hero", "text": "종사관 나리…",
		"choices": [{"text": "\"같이 가요. 든든할 거예요.\"", "set": "c5_together"}, {"text": "\"나리는 꼭 살아 돌아오셔야 해요.\"", "set": ""}]},
	{"who": "윤도결", "pic": "jongsagwan", "text": "…그 말이면 충분하다."},
]

const CH5_GOAL := [
	{"who": "", "bg": "yakbang", "text": "그믐밤. 모든 것이 시작된 허 의원의 약방."},
	{"who": "검은 사내", "pic": "shadow", "text": "흐흐흐… 기다렸다, 꼬마야.\n백운 그 늙은이가 무너지니 이제 이 몸을 묶어 둘 것도 없지."},
	{"who": "검은 사내", "pic": "shadow", "text": "그 환심단을 이리 내라. 그 약이 허가 놈을 깨우면, 나는 사라진다.\n…싫다. 나는 영원히 밤이고 싶다!"},
	{"who": "{name}", "pic": "hero_angry", "text": "의원님은 저를 길에서 업어다 살려 주셨어요.\n이번엔 제가 의원님을 업고 돌아갈 차례예요!"},
	{"who": "윤도결", "pic": "jongsagwan", "text": "포도청 종사관 윤도결, 함께 간다!", "end": true},
]

const CH5_END := [
	{"bg": "yakbang", "who": "", "text": "검은 사내가 무릎을 꿇은 순간, {name|은} 환심단을 그의 입에 밀어 넣었다."},
	{"who": "검은 사내", "pose": "shadow", "text": "크으윽…! 안 돼… 밤이… 밤이 끝난다…"},
	{"who": "", "text": "검은 연기가 사내의 몸에서 빠져나와 새벽빛 속으로 흩어졌다.\n그리고 그 자리에, 지친 얼굴의 노인이 쓰러져 있었다."},
	{"who": "허 의원", "pose": "heo", "text": "…{name}아? 네가… 어찌 여기에…\n아아, 내가 무슨 짓을… 꿈이 아니었구나…"},
	{"who": "{name}", "pose": "hero_sad", "text": "의원님…! 괜찮아요. 이제 다 끝났어요.\n의원님 마음은 이제 의원님 거예요."},
	{"who": "허 의원", "pose": "heo", "text": "마음속 검은 것을 떼어 내려다 오히려 그것에 먹혔구나.\n…검은 것도 내 마음이었다. 버릴 게 아니라 안고 살아야 했던 것을."},
	{"bg": "palace", "who": "", "text": "봄. 내의원 뜰에 매화가 피었다."},
	{"who": "", "text": "허 의원은 궁 밖에 다시 약방을 열었다. 이번에도 가난한 이에게는 약값을 받지 않았다.\n백운은 유배지에서 약초밭을 일구며 죄를 씻는다고 했다."},
	{"who": "다래", "pose": "darae_court", "text": "{name}아! 오늘도 진료 끝나면 같이 떡 사 먹으러 가자!\n…아, 저기 또 두 사람이 서성인다. 인기 많네, 우리 어의 나으리?"},
	{"who": "", "text": "궁궐 담장 너머로 서휘가 들고 온 약초 바구니,\n그리고 순찰을 핑계로 세 번째 지나가는 윤도결."},
	{"who": "{name}", "pose": "hero_physician", "text": "…다들, 고마워요.\n자, 오늘도 아픈 사람 고치러 가 볼까!"},
	{"who": "", "text": "― 한양 숨바꼭질 · 완(完) ―\n\n끝까지 함께해 주셔서 고맙습니다.", "end": true},
]

# ── 장별 길 위 대화 ─────────────────────────────────────
const TALKS := {
	2: [
		{"who": "엿장수", "pic": "yeotjangsu", "text": "어이 총각들! 엿 하나 물고 가.\n…요새 한양에 '푸른 눈 왈패'가 설친다더구먼. 조심하라고.", "coin": 2},
		{"who": "물장수", "pic": "muljangsu", "text": "포도청 종사관 나리가 이 길로 지나갔소.\n젊은 양반이 어찌나 꼼꼼한지, 장꾼 짐까지 다 뒤지더이다.", "coin": 1},
		{"who": "약재 상인", "pic": "yakjae", "text": "만다라 씨앗을 찾는 이가 요새 부쩍 늘었어.\n그게 약이 아니라 독이란 걸 모르는 건지…", "potion": 1},
		{"who": "주막 주모", "pic": "jumo", "text": "아이고, 사내아이가 손이 참 곱기도 하지.\n…농담이야, 농담! 국밥이나 먹어.", "potion": 1},
	],
	3: [
		{"who": "왈패", "pic": "walpae", "text": "의원! 우리 막내가 열이 펄펄 끓어. 좀 봐 줘!\n…고마워. 이거 얼마 안 되지만 받아.", "coin": 3},
		{"who": "약재 상인", "pic": "yakjae", "text": "청심보명단? 요새 그거 없어서 못 판다던데.\n그런데 그걸 먹은 사람들 눈빛이 영 이상해.", "potion": 1},
		{"who": "주막 주모", "pic": "jumo", "text": "우리 바깥양반도 그 환약을 먹더니 밤마다 머리를 싸매.\n의원 양반, 뭐 좋은 약 없수?", "coin": 2},
		{"who": "엿장수", "pic": "yeotjangsu", "text": "청계천 다리 밑 푸른 눈 대장 말이야.\n고아들 밥은 다 그 양반이 먹인다더라. 나쁜 놈인지 좋은 놈인지 원.", "coin": 2},
	],
	4: [
		{"who": "물장수", "pic": "muljangsu", "text": "남쪽으로 가는 은 수레를 봤수.\n삿갓 쓴 노인이 앞장을 섰는데, 꼭 신선 같더이다.", "coin": 2},
		{"who": "주막 주모", "pic": "jumo", "text": "같이 다니는 그 푸른 눈 총각, 의외로 다정하네?\n국밥 식을까 봐 계속 입김을 불어 주던데.", "potion": 1},
		{"who": "약재 상인", "pic": "yakjae", "text": "화엄골 백운 노인? 요 몇 해 사이 큰 부자가 됐다는 소문이 있지.\n약초만 캐서 그리 될 리가 없는데…", "potion": 1},
		{"who": "엿장수", "pic": "yeotjangsu", "text": "포도청 나리 하나가 몰래 그대들 뒤를 따르던데.\n…원수는 아닌 것 같고, 그 눈빛은 딱 상사병이야!", "coin": 2},
	],
	5: [
		{"who": "백성", "pic": "addict", "text": "어의 나으리… 청심보명단 끊은 뒤로 머리가 덜 아파요.\n고맙습니다… 정말 고맙습니다…", "coin": 2},
		{"who": "약재 상인", "pic": "yakjae", "text": "어의 나으리라니, 출세했구먼!\n환심단에 쓸 감초는 내가 제일 좋은 걸로 골라 놨다네.", "potion": 1},
		{"who": "주막 주모", "pic": "jumo", "text": "궁에 들어가더니 얼굴이 폈네!\n참, 종사관 나리랑 푸른 눈 총각 중에 누가 좋아?", "potion": 1},
		{"who": "엿장수", "pic": "yeotjangsu", "text": "엿 사려~ 어의 나으리 단골 엿이오~!\n공짜로 하나 드리리다. 요즘 그 소문으로 장사가 잘돼서!", "coin": 3},
	],
}

const ALL := {
	"CH2_INTRO": CH2_INTRO, "C2_DOGYEOL": C2_DOGYEOL, "C2_PLAGUE": C2_PLAGUE, "CH2_GOAL": CH2_GOAL, "CH2_END": CH2_END,
	"CH3_INTRO": CH3_INTRO, "C3_DOGYEOL": C3_DOGYEOL, "C3_TRUTH": C3_TRUTH, "C3_BOSS": C3_BOSS, "C3_BOSS_WIN": C3_BOSS_WIN, "CH3_END": CH3_END,
	"CH4_INTRO": CH4_INTRO, "C4_STREAM": C4_STREAM, "C4_CLUE": C4_CLUE, "CH4_GOAL": CH4_GOAL, "CH4_END": CH4_END, "CH4_AFTER_DUEL": CH4_AFTER_DUEL,
	"CH5_INTRO": CH5_INTRO, "C5_SEOHWI": C5_SEOHWI, "C5_DOGYEOL": C5_DOGYEOL, "CH5_GOAL": CH5_GOAL, "CH5_END": CH5_END,
}

## 장마다 보드의 적 이름을 바꿔 끼움
const ENEMY_MAP := {
	3: {"walpae": "rival", "pojol": "pojol"},
	4: {"walpae": "sanjeok", "pojol": "pojol"},
	5: {"walpae": "mob", "pojol": "mob"},
}

## 전투를 거드는 동료
const ALLIES := {
	"seohwi": {"name": "서휘", "dmg": 7, "line": "서휘의 일격!"},
	"dogyeol": {"name": "윤도결", "dmg": 6, "block": 4, "line": "윤도결이 막아선다!"},
}

## 아직 그림이 없어 도트로 대신하는 인물 (진짜 그림이 오면 여기서 지운다)
const PLACEHOLDERS := ["jongsagwan", "jongsagwan_blush", "seohwi", "seohwi_battle", "baegun", "baegun_boss",
	"king", "darae_court", "hero_physician", "addict"]
