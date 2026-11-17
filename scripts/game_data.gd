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
	{"bg": "yakbang_calm", "who": "", "text": "허 의원의 약방.\n그리고 그곳에서 약재 심부름을 하며 사는 열다섯 살 소녀, {name}."},
	{"who": "", "text": "{name|은} 일곱 살에 역병으로 부모를 잃었다.\n길가에 쓰러져 있던 {name|을} 업어 온 사람이 허 의원이었다."},
	{"who": "{name}", "pose": "hero", "text": "의원님! 당귀는 볕에 다 말려 두었고요, 감초는 썰어서 셋째 서랍에 넣어 놨어요."},
	{"who": "허 의원", "pose": "heo_smile", "text": "허허, 손이 빠르구나. 네가 이 약방에 온 지도 벌써 칠 년이로구나."},
	{"who": "허 의원", "pose": "heo_smile", "text": "그럼 오늘은 장에 좀 다녀오너라.\n당귀, 감초, 숙지황. 세 가지다. 운종가 약재상들한테 가면 있을 게다."},
	{"who": "{name}", "pose": "hero", "text": "네! 해 지기 전에 다 구해 올게요!"},
	{"who": "허 의원", "pose": "heo_smile", "text": "골목에 왈패들이 많으니 조심하고.\n…저녁엔 네가 좋아하는 팥죽을 쑤어 두마."},
	{"who": "", "text": "【목표】\n운종가 곳곳의 약재상을 돌며\n당귀·감초·숙지황을 모두 구해 약방으로 돌아가라."},
]

## 심부름을 마친 저녁: 허 의원과의 말다툼 → 그날 밤 → 누명
const PROLOGUE_B := [
	{"bg": "jangteo", "who": "", "text": "마지막 숙지황을 받아 드는데, 약재 상인이 목소리를 낮췄다."},
	{"who": "약재 상인", "pose": "yakjae", "text": "허 의원님 심부름 왔구나? 그런데 요즘 의원님, 주사(朱砂)에 만다라 씨앗까지 사 가셔.\n그런 건 독에 가까운 것들인데… 걱정돼서 말이야."},
	{"who": "약재 상인", "pose": "yakjae", "text": "그리고 조심해. 요 며칠 밤, 종로 골목에 검은 갓 쓴 사내가 나타나\n사람들을 마구 해친단다. 웃으면서 말이야."},
	{"who": "{name}", "pose": "hero_sad", "text": "(검은 갓… 요즘 의원님도 밤마다 검은 갓을 쓰고 나가시던데…)"},
	{"bg": "yakbang_calm", "who": "", "text": "해 질 녘, 약방.\n약방 가득 비린 쇠 냄새가 났다."},
	{"who": "{name}", "pose": "hero", "text": "의원님, 다녀왔어요! 당귀, 감초, 숙지황 다 구했어요."},
	{"who": "허 의원", "pose": "heo_smile", "text": "오냐, 수고했다. 역시 우리 약방 살림꾼이로구나."},
	{"who": "{name}", "pose": "hero", "text": "그런데 의원님, 요즘 밤마다 뭘 그렇게 달이세요?"},
	{"who": "허 의원", "pose": "heo", "text": "…흑심단(黑心丹)이라는 약이다.\n사람 마음속의 검은 것, 미움과 욕심만을 따로 떼어 내는 약이지."},
	{"who": "허 의원", "pose": "heo", "text": "그것만 떼어 낼 수 있다면, 세상에 나쁜 사람은 하나도 남지 않을 게다."},
	{"who": "{name}", "pose": "hero", "text": "마음을… 떼어 낸다고요?",
		"choices": [{"text": "그런 약이 정말 있어요?", "goto": "p_wonder"}, {"text": "어쩐지 무섭게 들려요", "goto": "p_fear", "set": "feared"}]},
	{"label": "p_wonder", "who": "허 의원", "pose": "heo", "text": "있고말고. 내가 반드시 만들어 보일 게다.\n…다만, 떼어 낸 검은 것이 어디로 가는지가 문제로구나.", "goto": "p_next"},
	{"label": "p_fear", "who": "허 의원", "pose": "heo", "text": "…그래, 너는 늘 눈이 밝구나.\n나도 실은 조금 무섭단다. 떼어 낸 검은 것이 어디로 가는지 아직 모르거든."},
	{"label": "p_next", "who": "", "text": "허 의원은 웃었지만, 붓을 쥔 손등에는 손톱으로 할퀸 듯한 붉은 자국이 나 있었다.\n책상 위엔 봉해 둔 편지 한 통이 놓여 있었다."},
	{"who": "{name}", "pose": "hero_sad", "text": "의원님, 손등이 왜 그래요? 그리고 그 편지는요?\n독에 가까운 약재만 사 가신다면서요. 밤마다 검은 갓 쓰고 어디 가세요?"},
	{"who": "허 의원", "pose": "heo_angry", "text": "…네가 알 바 아니다!\n어른 일에 함부로 끼어들지 마라."},
	{"who": "{name}", "pose": "hero_angry", "text": "저도 이 약방 식구예요! 의원님이 아프신 것 같은데, 왜 저한테만 숨기세요!"},
	{"who": "허 의원", "pose": "heo_angry", "text": "식구라… 너는 그저 내가 길에서 거둔 아이일 뿐이다. 너는… 너는 내…"},
	{"who": "", "text": "허 의원은 무언가를 더 말하려다, 입술을 깨물고 고개를 돌렸다."},
	{"who": "{name}", "pose": "hero_sad", "text": "…알겠어요. 저는 그냥 심부름하는 아이죠.\n팥죽 같은 거, 안 먹어요!"},
	{"bg": "stream", "who": "", "text": "{name|은} 약방을 뛰쳐나가 청계천 다리 아래 쪼그려 앉았다.\n분하고 서러워서, 한참을 울었다."},
	{"who": "{name}", "pose": "hero_sad", "text": "(…길에서 거둔 아이. 그게 의원님 진심일까.\n아니야. 의원님은 그런 분이 아닌데…)"},
	{"bg": "yakbang_calm", "who": "", "text": "통금 인경이 울린 지 한참 뒤에야 {name|은} 약방으로 돌아왔다.\n부엌 아궁이 위엔 식은 팥죽 한 그릇이 덮여 있었다."},
	{"who": "", "text": "허 의원이 문간에 서 있었다. 얼굴은 흙빛이었고, 도포 자락에는 진흙이 말라붙어 있었다."},
	{"who": "허 의원", "pose": "heo", "text": "…{name}아. 할 말은 많다만, 오늘은 이것만 맡아 다오.\n이 편지와 열쇠다."},
	{"who": "허 의원", "pose": "heo", "text": "만일… 내가 내가 아니게 되거든, 이것을 지리산 화엄골의 백운 선생께 전해야 한다.\n내 스승이시다. 절대, 절대 열어 보지 말거라."},
	{"who": "{name}", "pose": "hero_sad", "text": "(…아까 일은 사과도 안 하시면서.)\n…알았어요."},
	{"who": "허 의원", "pose": "heo", "text": "오늘은 일찍 자거라.\n…그리고 오늘 밤엔 무슨 소리가 나도 방문을 열지 말거라."},
	{"who": "{name}", "pose": "hero_sad", "text": "(내일 아침엔… 내가 먼저 죄송하다고 말해야지.)"},
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
	{"who": "", "text": "【목표】\n뒤쫓는 그림자를 따돌리고\n지리산 화엄골의 백운 노인을 찾아가라.", "end": true},
]

# 보드 중간 이야기 (팝업으로 이어짐)
const STORY1 := [
	{"who": "", "bg": "jumak_street", "text": "문경새재 고갯마루.\n주막 앞 담벼락에도 어김없이 방이 붙어 있었다."},
	{"who": "다래", "pic": "friend_worried", "text": "여기까지 방이 붙었어… 그리고 저 사람들 얘기 들었어?\n한양에 밤마다 검은 갓 쓴 사내가 나타나서, 벌써 셋이나 다쳤대."},
	{"who": "{name}", "pic": "hero_sad", "text": "그날 밤 그 사내 목소리…\n이상하게 자꾸 의원님 목소리랑 겹쳐 들려."},
	{"who": "다래", "pic": "friend", "text": "지금은 생각하지 마. 할아버지를 만나면 다 알게 될 거야.\n자, 이 고개만 넘으면 경상도야!"},
]

const STORY2 := [
	{"who": "", "bg": "namsan_night", "text": "지리산 자락. 날이 저물고 달이 떠올랐다.\n두 소녀는 산길 옆 바위 아래 모닥불을 피웠다."},
	{"who": "{name}", "pic": "hero_sad", "text": "(의원님 편지… 이 안에 무슨 일이 있었는지 다 적혀 있을지도 몰라.)",
		"choices": [{"text": "몰래 봉인을 뜯어 본다", "set": "opened"}, {"text": "약속을 지킨다", "set": ""}]},
	{"if": "opened", "who": "", "pic": "hero_surprised", "text": "'스승님, 저는 둘이 되었습니다.\n해가 지면 제 안의 검은 것이 저를 밀어내고 거리로 나갑니다…'\n떨리는 글씨는 거기서 번져 끊겨 있었다."},
	{"if": "opened", "who": "{name}", "pic": "hero_surprised", "text": "둘이…? 그럼 그 검은 갓의 사내가…"},
	{"ifnot": "opened", "who": "다래", "pic": "friend", "text": "잘 참았어. 의원님이 열지 말라고 한 데는 이유가 있을 거야."},
	{"who": "다래", "pic": "friend_worried", "text": "…그런데 아까부터 누가 우리를 따라오는 것 같아.\n날이 밝으면 곧장 화엄골로 가자. 할아버지 초당까지 이제 하루 길이야."},
]

const CHAPTER1_END := [
	{"bg": "byeolchae", "who": "", "text": "지리산 화엄골.\n안개 낀 계곡 끝, 대숲에 둘러싸인 초당에 마침내 닿았다."},
	{"who": "다래", "pose": "friend", "text": "할아버지! 할아버지, 저 다래예요!"},
	{"who": "", "pose": "baegun", "text": "사립문이 열리고, 하얀 수염의 노인이 지팡이를 짚고 나왔다.\n웃을 때마다 눈가의 주름이 부채처럼 접혔다."},
	{"who": "백운", "pose": "baegun", "text": "허허, 우리 다래 왔구나. 얼굴이 반쪽이 됐어.\n…그리고 이 아이는 누구냐?"},
	{"who": "{name}", "pose": "hero_sad", "text": "허 의원님 약방에서 일하는 {name}이에요.\n의원님께서 이 편지를 백운 선생님께 꼭 전하라고 하셨어요."},
	{"who": "", "text": "백운 노인은 편지를 읽는 내내 말이 없었다.\n마지막 장을 접을 때, 그의 손이 조금 떨렸다."},
	{"who": "백운", "pose": "baegun", "text": "…허 그 녀석. 내 제자 중 가장 마음이 여린 아이였지.\n남의 아픔을 제 아픔처럼 앓는 아이라, 늘 걱정이었다."},
	{"who": "백운", "pose": "baegun", "text": "{name}아, 먼 길 오느라 애썼다. 오늘은 이 늙은이가 쑨 죽부터 먹거라.\n의원 일은 배를 채운 다음에 하는 법이다."},
	{"who": "", "text": "그날 밤, 초당의 등잔 아래.\n백운 노인은 {name}에게 약초 보는 법을 하나하나 일러 주었다."},
	{"who": "백운", "pose": "baegun", "text": "이건 산삼과 닮았지만 독이 있는 미치광이풀이다. 잎맥을 보거라.\n좋은 의원은 약보다 독을 먼저 알아보는 사람이다."},
	{"who": "{name}", "pose": "hero", "choices": [{"text": "가르침을 마음에 새긴다", "set": "baegun_lesson"}, {"text": "할아버지 손에 묻은 붉은 가루를 본다", "set": "baegun_doubt"}], "text": "약보다… 독을 먼저."},
	{"who": "백운", "pose": "baegun", "if": "baegun_lesson", "potion": 2, "maxhp": 5, "text": "허허, 그 눈빛이면 됐다. 옜다, 내가 지은 약이다. 먼 길에 쓰거라."},
	{"who": "백운", "pose": "baegun", "if": "baegun_doubt", "potion": 2, "text": "…이것 말이냐? 약을 빻다 묻은 주사(朱砂)다. 눈이 밝구나.\n옜다, 먼 길에 쓰거라."},
	{"who": "", "text": "(백운의 가르침: 약병 +2)"},
	{"who": "백운", "pose": "baegun", "text": "…허가 녀석이 둘이 되었다는 건 이 늙은이도 짐작하고 있었다.\n그 아이가 만든 해독약은 한양 약방 지하에 있다. 그것만 있으면 아직 늦지 않았어."},
	{"who": "{name}", "pose": "hero_angry", "text": "그럼 제가 가져올게요. 의원님을 꼭 되찾을 거예요."},
	{"who": "백운", "pose": "baegun", "text": "허허, 눈빛이 제 스승을 닮았구나.\n하지만 한양엔 네 얼굴이 그려진 방이 붙었다지. 그 얼굴로는 성문도 못 지나."},
	{"who": "백운", "pose": "baegun", "text": "내 젊을 적 약초꾼 옷을 내주마. 댕기를 풀고 패랭이를 쓰거라.\n아무도 의심하지 않을 게다."},
	{"bg": "namsan_night", "who": "", "text": "자정 무렵. 대숲이 크게 흔들렸다.\n초당 앞 달빛 어린 산길에, 검은 갓을 쓴 사내가 서 있었다."},
	{"who": "???", "pose": "shadow", "text": "흐흐흐… 고맙구나, 꼬마야. 그 편지를 여기까지 날라다 주어서.\n자, 이제 이리 내놔라!"},
	{"who": "{name}", "pose": "hero_angry", "text": "그 목소리…! 당신, 의원님 몸으로 무슨 짓을 한 거야!"},
]

# ── 보드 칸 대화 ───────────────────────────────────────
const TALKS := [
	{"who": "엿장수", "pic": "yeotjangsu", "text": "엿 사려, 엿! 어이 처자들, 어디까지 가누?\n남쪽 길엔 산적이 들끓는다니, 서낭당에 돌이라도 하나 얹고 가게.", "coin": 2},
	{"who": "주막 주모", "pic": "jumo", "text": "어머, 둘 다 얼굴이 반쪽이네. 국밥이나 먹고 가.\n…참, 어제 포졸들이 계집아이 둘을 찾는다며 지나갔단다.", "potion": 1},
	{"who": "약재 상인", "pic": "yakjae", "text": "화엄골 백운 노인? 그분 약초 보는 눈은 조선 제일이지.\n자, 약병 하나 가져가. 내가 주는 거야. 길이 멀다.", "potion": 1},
	{"who": "물장수", "pic": "muljangsu", "text": "목 좀 축이고 가쇼!\n왈패들은 고춧가루에 약하다오. 눈에 들어가면 한동안 기세가 꺾이지!", "coin": 1},
]

# ── 길 위의 사건 ───────────────────────────────────────
# heal: 체력 / maxhp: 최대 체력 / energy: 다음 전투 첫 차례 기력 / guard: 다음 전투 시작 막기
# day: 남은 날 / coin: 엽전 / battle: 전투
const BUFFS := [
	{"title": "약수터", "text": "바위틈에서 솟는 맑은 약수를 마셨다.\n몸이 가뿐해진다.\n\n(체력 +10, 다음 전투 첫 차례 기력 +1)", "heal": 10, "energy": 1},
	{"title": "서낭당", "text": "서낭당 돌무더기에 돌을 하나 얹고 빌었다.\n마음이 든든해진다.\n\n(다음 전투 시작 시 막기 8)", "guard": 8},
	{"title": "어린 산삼", "pic": "friend", "text": "다래가 바위틈에서 어린 산삼 한 뿌리를 찾아냈다!\n\n(최대 체력 +5, 체력 +5)", "maxhp": 5, "heal": 5},
	{"title": "인심 좋은 할머니", "text": "길가 할머니가 주먹밥을 싸 주셨다.\n\"먼 길 가는구먼, 든든히 먹어.\"\n\n(체력 +12)", "heal": 12},
	{"title": "떨어진 엽전", "text": "돌 틈에 반짝이는 것이 있었다.\n누가 흘린 엽전 꾸러미다!\n\n(엽전 +5냥)", "coin": 5},
	{"title": "좋은 약초", "text": "길섶에서 귀한 당귀를 발견했다.\n씹으니 기운이 돈다.\n\n(체력 +8, 다음 전투 첫 차례 기력 +1)", "heal": 8, "energy": 1},
	{"title": "지름길", "text": "나무꾼이 숲속 지름길을 알려 주었다.\n시간을 벌었다!\n\n(남은 시각 +2)", "day": 2},
	{"title": "마음 다잡기", "text": "잠시 멈춰 숨을 고르고 의원님을 떠올렸다.\n두려움이 가라앉는다.\n\n(다음 전투 시작 시 막기 6, 기력 +1)", "guard": 6, "energy": 1},
	{"title": "냇가 휴식", "text": "맑은 냇물에 발을 담그고 잠시 쉬었다.\n\n(체력 +15)", "heal": 15},
	{"title": "보부상의 선물", "text": "보부상이 남은 짐을 덜어 주었다.\n\"약값에 보태 쓰게.\"\n\n(엽전 +4냥, 체력 +5)", "coin": 4, "heal": 5},
]
const DEBUFFS := [
	{"title": "진흙탕", "text": "밤새 내린 비로 길이 온통 진창이 되었다.\n하루를 더 허비했다.\n\n(남은 날 -1)", "day": -1},
	{"title": "독초", "text": "허기에 산딸기를 따 먹었는데 독초가 섞여 있었다…\n\n(체력 -6)", "hp": -6},
	{"title": "소매치기", "text": "장꾼들 틈에서 엽전 주머니를 털렸다!\n\n(엽전 -3냥)", "coin": -3},
	{"title": "발목 삠", "text": "돌부리에 걸려 발목을 삐었다.\n절뚝이며 걸으니 시간이 걸린다.\n\n(남은 시각 -1, 체력 -4)", "day": -1, "hp": -4},
	{"title": "소나기", "text": "갑자기 쏟아진 소나기에 흠뻑 젖었다.\n몸이 으슬으슬 떨린다.\n\n(체력 -7)", "hp": -7},
	{"title": "찢어진 주머니", "text": "엽전 주머니에 구멍이 나 있었다!\n몇 닢이 어디론가 사라졌다.\n\n(엽전 -4냥)", "coin": -4},
	{"title": "길을 잃음", "text": "갈림길에서 엉뚱한 길로 들어섰다.\n한참을 돌아 나왔다.\n\n(남은 시각 -2)", "day": -2},
	{"title": "벌떼", "text": "덤불을 헤치다 벌집을 건드렸다!\n\n(체력 -8)", "hp": -8},
	{"title": "상한 음식", "text": "장터에서 사 먹은 떡이 쉬어 있었다.\n배가 살살 아프다.\n\n(체력 -5, 엽전 -2냥)", "hp": -5, "coin": -2},
	{"title": "수상한 눈길", "text": "누군가 계속 뒤를 밟는 것 같다.\n골목을 몇 번이나 돌아 따돌렸다.\n\n(남은 시각 -1, 체력 -3)", "day": -1, "hp": -3},
]
const TRAPS := [
	{"title": "사냥꾼의 덫", "text": "수풀 속 덫에 발목이 걸렸다!\n\n(체력 -8)", "hp": -8},
	{"title": "산적 매복", "text": "길가 수풀에서 산적이 뛰쳐나왔다!\n\"가진 것 다 내놓고 가라!\"", "battle": "sanjeok"},
	{"title": "관아 검문", "pic": "pojol", "text": "고을 어귀에 검문이 섰다. 방에 그려진 얼굴과 대조하고 있다!\n산길로 돌아가느라 이틀을 잃었다.\n\n(남은 날 -2)", "day": -2},
]
const REST := {"title": "주막", "pic": "jumo", "text": "주막에서 하룻밤 묵어 갔다.\n따뜻한 국밥에 기운이 돈다.\n\n(체력 +20)", "heal": 20}

# ── 전투 카드 ─────────────────────────────────────────
# cost: 기력 / dmg: 피해 / block: 막기 / slow: 적 기세 감소(칸, 99 = 초기화) / coin: 엽전
# 같은 카드 두 장을 합치면 단계(★)가 오르고, 피해·막기가 50%씩 커진다 (최대 ★5)
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
const MAX_LV := 5
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
	"sanjeok": {"name": "산적", "sprite": "walpae", "hp": 30, "coin": 5, "charge": 3,
		"moves": [{"t": "atk", "v": 7, "n": "몽둥이질"}, {"t": "atk", "v": 5, "n": "멱살잡이"}, {"t": "def", "v": 7, "n": "버티기"}],
		"heavy": {"t": "atk", "v": 14, "n": "통나무 휘두르기"}},
	"rival": {"name": "흑룡파 왈패", "sprite": "gatekeeper", "hp": 30, "coin": 4, "charge": 3,
		"moves": [{"t": "atk", "v": 7, "n": "칼등 치기"}, {"t": "def", "v": 7, "n": "버티기"}, {"t": "atk", "v": 8, "n": "박치기"}],
		"heavy": {"t": "atk", "v": 15, "n": "쇠사슬 휘두르기"}},
	"mob": {"name": "청심보명단 중독자", "sprite": "addict", "hp": 28, "coin": 3, "charge": 2,
		"moves": [{"t": "atk", "v": 6, "n": "할퀴기"}, {"t": "atk", "v": 7, "n": "달려들기"}],
		"heavy": {"t": "atk", "v": 12, "n": "광란"}},
	"seohwi": {"name": "청안 서휘", "sprite": "seohwi_battle", "hp": 70, "coin": 0, "charge": 3, "boss": true,
		"moves": [{"t": "atk", "v": 9, "n": "정권 찌르기"}, {"t": "def", "v": 10, "n": "흘려 막기"}, {"t": "atk", "v": 11, "n": "돌려차기"}],
		"heavy": {"t": "atk", "v": 22, "n": "청안 연격"}},
	"seohwi3": {"name": "청안 서휘", "sprite": "seohwi_battle", "hp": 64, "coin": 8, "charge": 3, "boss": true,
		"moves": [{"t": "atk", "v": 9, "n": "정권 찌르기"}, {"t": "def", "v": 10, "n": "흘려 막기"}, {"t": "atk", "v": 10, "n": "돌려차기"}],
		"heavy": {"t": "atk", "v": 19, "n": "청안 연격"}},
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
	"haejeok": {"name": "해적 졸개", "sprite": "haejeok_young", "hp": 34, "coin": 6, "charge": 3,
		"moves": [{"t": "atk", "v": 8, "n": "단검 찌르기"}, {"t": "def", "v": 8, "n": "몸 피하기"}, {"t": "atk", "v": 9, "n": "갈고리 휘두르기"}],
		"heavy": {"t": "atk", "v": 17, "n": "선원 칼춤"}},
	"cheong_merchant": {"name": "가짜 인삼 장수", "sprite": "cheong_merchant", "hp": 52, "coin": 8, "charge": 3, "boss": true,
		"moves": [{"t": "atk", "v": 8, "n": "주판 내려치기"}, {"t": "def", "v": 9, "n": "비단 소매로 막기"}, {"t": "atk", "v": 10, "n": "가짜 인삼 던지기"}],
		"heavy": {"t": "atk", "v": 18, "n": "패거리 부르기"}},
	"pirate_boss": {"name": "해적 두목", "sprite": "pirate_captain", "hp": 70, "coin": 14, "charge": 3, "boss": true,
		"moves": [{"t": "atk", "v": 10, "n": "갈고리 휘두르기"}, {"t": "def", "v": 10, "n": "돛줄 타고 피하기"}, {"t": "atk", "v": 12, "n": "단검 난도질"}],
		"heavy": {"t": "atk", "v": 20, "n": "선상 칼춤"}},
	"qing_soldier": {"name": "청나라 국경 군졸", "sprite": "sumunjang", "hp": 34, "coin": 5, "charge": 3,
		"moves": [{"t": "atk", "v": 8, "n": "창 찌르기"}, {"t": "def", "v": 8, "n": "창대로 막기"}, {"t": "atk", "v": 9, "n": "창대 휘두르기"}],
		"heavy": {"t": "atk", "v": 16, "n": "국경 수비 돌격"}},
	"mapo_thug": {"name": "마포 나루 짐꾼패", "sprite": "mapo_thug", "hp": 34, "coin": 6, "charge": 3,
		"moves": [{"t": "atk", "v": 9, "n": "짐 갈고리 휘두르기"}, {"t": "def", "v": 8, "n": "궤짝 뒤로 숨기"}, {"t": "atk", "v": 10, "n": "밧줄 후려치기"}],
		"heavy": {"t": "atk", "v": 17, "n": "짐더미 무너뜨리기"}},
	"masked_henchman": {"name": "복면 하수인", "sprite": "masked_henchman", "hp": 34, "coin": 5, "charge": 4,
		"moves": [{"t": "atk", "v": 8, "n": "단검 찌르기"}, {"t": "def", "v": 9, "n": "어둠에 숨기"}, {"t": "atk", "v": 9, "n": "독침 던지기"}],
		"heavy": {"t": "atk", "v": 16, "n": "흑심단 연막"}},
	"naegeumwi": {"name": "내금위 순라군", "sprite": "pojol_battle", "hp": 34, "coin": 5, "charge": 4,
		"moves": [{"t": "atk", "v": 8, "n": "육모방망이"}, {"t": "def", "v": 9, "n": "등롱 비추기"}, {"t": "atk", "v": 9, "n": "창대 찌르기"}],
		"heavy": {"t": "atk", "v": 16, "n": "호루라기 불기"}},
	"jeong_shadow1": {"name": "흑화한 정 의관", "sprite": "jeong_shadow", "hp": 80, "coin": 12, "charge": 3, "boss": true,
		"moves": [{"t": "atk", "v": 9, "n": "검은 침 놓기"}, {"t": "def", "v": 10, "n": "먹물 연기 두르기"}, {"t": "atk", "v": 11, "n": "흑심단 뿌리기"}],
		"heavy": {"t": "atk", "v": 20, "n": "서른 해의 미움"}},
	"jeong_shadow": {"name": "흑화한 정 의관", "sprite": "jeong_shadow", "hp": 110, "coin": 20, "charge": 3, "boss": true,
		"moves": [{"t": "atk", "v": 11, "n": "검은 침 놓기"}, {"t": "def", "v": 12, "n": "먹물 연기 두르기"}, {"t": "atk", "v": 13, "n": "흑심단 뿌리기"}],
		"heavy": {"t": "atk", "v": 24, "n": "서른 해의 미움"}},
	"merchant_gang": {"name": "약재상 패거리", "sprite": "cheong_merchant", "hp": 32, "coin": 6, "charge": 3,
		"moves": [{"t": "atk", "v": 8, "n": "주판 휘두르기"}, {"t": "def", "v": 7, "n": "약재 궤짝 뒤로 숨기"}, {"t": "atk", "v": 9, "n": "말린 대추 던지기"}],
		"heavy": {"t": "atk", "v": 15, "n": "패거리 몰매"}},
	"rat": {"name": "역병 쥐떼", "sprite": "rat", "hp": 26, "coin": 2, "charge": 2,
		"moves": [{"t": "atk", "v": 6, "n": "물어뜯기"}, {"t": "atk", "v": 5, "n": "우르르 몰려들기"}],
		"heavy": {"t": "atk", "v": 12, "n": "역병 퍼뜨리기"}},
	"pojol": {"name": "포도청 포졸", "sprite": "pojol_battle", "hp": 34, "coin": 5, "charge": 4,
		"moves": [{"t": "atk", "v": 7, "n": "창대 치기"}, {"t": "def", "v": 8, "n": "창 겨누기"}, {"t": "atk", "v": 8, "n": "오랏줄 던지기"}],
		"heavy": {"t": "atk", "v": 16, "n": "창 찌르기"}},
	"dogyeol": {"name": "종사관 윤도결", "sprite": "jongsagwan_battle", "hp": 64, "coin": 8, "charge": 3, "boss": true,
		"moves": [{"t": "atk", "v": 7, "n": "오랏줄 던지기"}, {"t": "def", "v": 9, "n": "칼집으로 막기"}, {"t": "atk", "v": 9, "n": "육모방망이"}],
		"heavy": {"t": "atk", "v": 17, "n": "포도청 체포술"}},
	"shadow_s": {"name": "검은 사내", "sprite": "shadow", "hp": 78, "coin": 6, "charge": 3, "boss": true,
		"moves": [{"t": "atk", "v": 9, "n": "검은 손아귀"}, {"t": "def", "v": 10, "n": "그림자 두르기"}, {"t": "atk", "v": 10, "n": "어둠 찢기"}],
		"heavy": {"t": "atk", "v": 20, "n": "밤의 웃음"}},
	"baegun_mask": {"name": "삿갓 노인", "sprite": "baegun_boss", "hp": 72, "coin": 12, "charge": 3, "boss": true,
		"moves": [{"t": "atk", "v": 8, "n": "독침 날리기"}, {"t": "def", "v": 10, "n": "연막약"}, {"t": "atk", "v": 10, "n": "지팡이 후려치기"}],
		"heavy": {"t": "atk", "v": 19, "n": "흑심 독무"}},
	"gatekeeper": {"name": "성 문지기", "sprite": "gatekeeper", "hp": 52, "coin": 8, "charge": 3,
		"moves": [{"t": "atk", "v": 8, "n": "철퇴 휘두르기"}, {"t": "def", "v": 10, "n": "대문 막기"}, {"t": "atk", "v": 9, "n": "어깨로 들이받기"}],
		"heavy": {"t": "atk", "v": 18, "n": "철퇴 내려찍기"}},
	"heukdu": {"name": "흑룡파 두목", "sprite": "heukdu", "hp": 85, "coin": 10, "charge": 3, "boss": true,
		"moves": [{"t": "atk", "v": 9, "n": "쇠사슬 채찍"}, {"t": "def", "v": 9, "n": "버티기"}, {"t": "atk", "v": 7, "n": "독안개 뿌리기"}],
		"heavy": {"t": "atk", "v": 19, "n": "흑룡 쇠사슬"}},
	"mob_boss": {"name": "중독된 일꾼 무리", "sprite": "addict", "hp": 56, "coin": 6, "charge": 2,
		"moves": [{"t": "atk", "v": 7, "n": "달려들기"}, {"t": "atk", "v": 8, "n": "할퀴기"}, {"t": "def", "v": 8, "n": "엉겨 붙기"}],
		"heavy": {"t": "atk", "v": 16, "n": "한꺼번에 덮치기"}},
	"heukdu1": {"name": "흑룡파 두목", "sprite": "heukdu", "hp": 69, "coin": 7, "charge": 3, "boss": true,
		"moves": [{"t": "atk", "v": 7, "n": "쇠사슬 채찍"}, {"t": "def", "v": 7, "n": "버티기"}, {"t": "atk", "v": 6, "n": "발길질"}],
		"heavy": {"t": "atk", "v": 14, "n": "흑룡 쇠사슬"}},
	"heukdu2": {"name": "흑룡파 두목", "sprite": "heukdu", "hp": 77, "coin": 9, "charge": 3, "boss": true,
		"moves": [{"t": "atk", "v": 8, "n": "쇠사슬 채찍"}, {"t": "def", "v": 8, "n": "버티기"}, {"t": "atk", "v": 7, "n": "소금 뿌리기"}],
		"heavy": {"t": "atk", "v": 16, "n": "흑룡 쇠사슬"}},
}
