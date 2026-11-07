class_name StoryData
## 제2장~제5장 이야기, 장(章) 설정, 장별 길 위 대화
## 인물: 윤도결(포도청 종사관) · 서휘(왈패 대장, 푸른 눈의 혼혈, 애체(안경)) · 백운(다래 할아버지 = 왈패 대대장)

# ── 장 설정 ─────────────────────────────────────────────
# board: 보드 파일 / days: 기한 / goal: 목적지 이름 / goal_pre·goal_battle·goal_lose_ok: 목적지에서 벌어지는 이야기와 싸움
# stages: 작은 맵들 (map: assets/data/stages/<map>.json, after: 그 맵을 끝낸 뒤 나오는 이야기)
# world: true 이면 대동여지도식 큰 지도(board)를 그대로 쓴다
const CHAPTERS := {
	1: {"title": "제1장  누명", "goal": "화엄골", "intro": "PROLOGUE", "end": "CHAPTER1_END",
		"stages": [{"map": "s1_1", "name": "운종가를 지나 도망치기", "after": "story1"},
			{"map": "s1_2", "name": "문경새재 넘기", "after": "story2"},
			{"map": "s1_3", "name": "백운 노인 찾아가기"}],
		"goal_text": "안개 낀 계곡 끝, 대숲 속 초당이 보인다.\n지리산 화엄골에 도착했다!", "goal_title": "화엄골", "goal_pic": "friend", "goal_bg": "byeolchae",
		"end_battle": "shadow_s", "end_after": "CH1_AFTER_SHADOW"},
	2: {"title": "제2장  남장", "goal": "한양 약방", "intro": "CH2_INTRO", "end": "CH2_END",
		"stages": [{"map": "s2_1", "name": "검문소 피해 가기", "after": "C2_DOGYEOL"},
			{"map": "s2_2", "name": "새재 너머 주막거리"},
			{"map": "s2_3", "name": "한양 약방으로"}],
		"goal_pre": "CH2_GOAL", "goal_battle": "seohwi", "goal_lose_ok": true},
	3: {"title": "제3장  왈패 소굴", "goal": "왈패 소굴", "intro": "CH3_INTRO", "end": "CH3_END",
		"stages": [{"map": "s3_0", "name": "서휘와 흑룡파 몰아내기", "after": "C3_HEUK", "ally": "seohwi"},
			{"map": "s3_1", "name": "청계천 약재 심부름", "after": "C3_DOGYEOL"},
			{"map": "s3_2", "name": "종로 뒷골목", "after": "C3_TRUTH"},
			{"map": "s3_3", "name": "남산 아래 결투"}],
		"goal_text": "청계천 다리 밑, 왈패 소굴로 돌아왔다.\n안쪽 방에서 낮은 목소리가 새어 나온다…", "goal_title": "왈패 소굴", "goal_pic": "", "goal_bg": "den"},
	4: {"title": "제4장  대대장", "goal": "화엄골 지하", "intro": "CH4_INTRO", "end": "CH4_END",
		"stages": [{"map": "s4_0", "name": "성 밖 병든 마을", "after": "C4_PLAGUE"},
			{"map": "s4_1", "name": "비 오는 청계천", "after": "C4_STREAM"},
			{"map": "s4_2", "name": "군산 포구 뒤지기", "after": "C4_CLUE"},
			{"map": "s4_3", "name": "도적의 소굴 찾아가기"}],
		"goal_pre": "CH4_GOAL", "goal_battle": "baegun", "goal_ally": "seohwi",
		"end_battle": "darae", "end_after": "CH4_AFTER_DUEL"},
	5: {"title": "제5장  어의", "goal": "허 의원 약방", "intro": "CH5_INTRO", "end": "CH5_END",
		"stages": [{"map": "s5_1", "name": "내의원 환자 돌보기", "after": "C5_HEAL"},
			{"map": "s5_2", "name": "종로에서 약재 구하기", "after": "C5_SEOHWI"},
			{"map": "s5_3", "name": "궁궐 담장 아래", "after": "C5_DOGYEOL"},
			{"map": "s5_4", "name": "허 의원 약방으로"}],
		"goal_pre": "CH5_GOAL", "goal_battle": "shadow", "goal_ally": "dogyeol"},
	6: {"title": "제6장  작별", "goal": "산마루 약초밭", "intro": "CH6F_INTRO", "end": "CH6F_END", "stage_ally": "darae",
		"stages": [{"map": "s6_1", "name": "다래와 북한산 오르기", "after": "C6F_LESSON"},
			{"map": "s6_2", "name": "산마루 약초밭으로"}],
		"goal_text": "산마루, 볕 잘 드는 비탈에 닿았다.\n여기라면 약초가 잘 자라겠다!", "goal_title": "산마루 약초밭", "goal_pic": "friend", "goal_bg": "byeolchae"},
	7: {"title": "제7장  만리길", "world": true, "board": "board6", "days": 30, "goal": "화란", "intro": "CH6_INTRO", "end": "CH6_END",
		"goal_text": "멀리 바닷가에 풍차가 보인다.\n서쪽 끝 나라, 화란에 닿았다!", "goal_title": "화란", "goal_pic": "", "goal_bg": "holland"},
	8: {"title": "제8장  화란의 봄", "goal": "풍차 언덕", "intro": "CH7_INTRO", "end": "CH7_END", "stage_ally": "seohwi",
		"stages": [{"map": "s7_1", "name": "역병 도는 마을", "after": "C7_MID"},
			{"map": "s7_2", "name": "풍차 언덕 약초밭"}],
		"goal_text": "풍차 옆 언덕에 쓴 약초가 가득하다.\n이것이면 마을을 살릴 수 있다!", "goal_title": "풍차 언덕", "goal_pic": "seohwi_dutch", "goal_bg": "holland"},
	9: {"title": "마지막 장  한양의 봄", "goal": "남산 아래 집터", "intro": "CH9_INTRO", "end": "CH9_END", "epilogue": "EPILOGUE", "stage_ally": "seohwi",
		"stages": [{"map": "s9_1", "name": "운종가에서 청계천까지", "after": "C9_MEM"},
			{"map": "s9_2", "name": "남산 아래 집터로"}],
		"goal_text": "남산 아래, 볕 잘 드는 빈터에 닿았다.\n서휘가 말뚝 하나를 박았다. \"여기에 짓자.\"", "goal_title": "새 보금자리", "goal_pic": "seohwi", "goal_bg": "family"},
}

static func talks(ch: int) -> Array:
	if TALKS.has(ch):
		return TALKS[ch]
	if TALKS_EXTRA.has(ch):
		return TALKS_EXTRA[ch]
	return GameData.TALKS

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
	{"who": "다래", "pose": "friend", "text": "와… 할아버지 옷이 딱 맞네. 진짜 누가 봐도 사내아이야.\n목소리만 조금 낮추면 되겠어. 자, 이름을 불러 볼까? {alias}!"},
	{"who": "{alias}", "pose": "hero_disguise", "text": "…으, 응. 어색하다.\n그래도 이제 한양에 들어갈 수 있어."},
	{"who": "다래", "pose": "friend_worried", "text": "할아버지도 한양에 계시댔지. 의원님의 해독약도 한양 약방 지하에 있고.\n…저 검은 사내도 결국 한양으로 가겠지?"},
	{"who": "{alias}", "pose": "hero_disguise_angry", "text": "그러니까 우리가 먼저 가야 해.\n약방 지하에서 해독약을 찾아내기 전엔 절대 안 잡혀."},
	{"who": "", "text": "【목표】\n스물엿새 안에 서쪽 길로 돌아 한양 약방에 닿아라.\n남장이 들키지 않도록 조심할 것.", "end": true},
]

const C2_DOGYEOL := [
	{"who": "", "bg": "street_ink", "text": "어느 고을 어귀, 검문소.\n붉은 술 전립을 쓴 포졸들 사이로, 검은 철릭의 젊은 관리 하나가 걸어 나왔다."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "포도청 종사관 윤도결이다.\n한양 약방 사건의 계집아이를 쫓아 여기까지 왔지."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "…약초꾼이냐. 어디서 오는 길이냐?",
		"choices": [{"text": "지리산 약초꾼이라 둘러댄다", "set": "c2_lie"}, {"text": "고개를 숙이고 입을 다문다", "set": ""}]},
	{"if": "c2_lie", "who": "다래", "pic": "friend", "text": "맞아요, 나리! 얘는 제 사촌 동생이에요. 둘이 약초 팔러 한양 가는 길이고요!"},
	{"who": "윤도결", "pic": "jongsagwan", "text": "흠, 약초꾼 아이들이군. 가 봐라.\n…혹시 길에서 수상한 계집아이를 보거든 알려라. 그 계집아이는 의원을 해치고 돈궤를 턴 흉악범이다. 반드시 내 손으로 잡는다."},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "(…나 아니라고요. 정말로.)"},
]

const C4_PLAGUE := [
	{"bg": "street_ink", "who": "", "text": "한양을 떠나기 전, 성 밖 작은 마을.\n열병이 돌아 의원은 도망가고, 아이와 노인들만 거적 위에 누워 있었다."},
	{"who": "서휘", "pic": "seohwi", "text": "의원, 우리 갈 길이 바쁘다. 포졸들도 아직 너를 찾고 있고."},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "…의원님이라면 그냥 지나치지 않으셨을 거예요.\n쑥이랑 금은화부터 구해 주세요. 오늘 밤은 여기 있을래요."},
	{"who": "", "text": "{alias}는 밤새 아이들의 이마를 식히고 약을 달였다.\n새벽녘, 열이 내린 아이가 처음으로 웃었다."},
	{"who": "", "text": "그 모습을, 마을 어귀 큰 느티나무 뒤에서 누군가 숨죽여 지켜보고 있었다."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "(…밤새 한숨도 안 자고, 값도 안 받고.\n저렇게 고운 마음을 가진 아이가… 정말 사람을 해쳤을까?)"},
	{"who": "", "text": "새벽 햇살 속에서 {alias}가 아이를 안고 환하게 웃었다.\n그 순간, 윤도결의 가슴이 쿵 하고 내려앉았다."},
	{"who": "윤도결", "pic": "jongsagwan_blush", "text": "(…뭐지, 이건. 왜 가슴이 뛰는 거냐.\n저건 사내아이다. 그것도 쫓고 있는 도망자라고!)"},
	{"who": "윤도결", "pic": "jongsagwan_blush", "text": "(사내아이를 보고 두근거리다니… 이러면 안 된다, 윤도결.\n정신 차려라. 도망자는 도망자다.)"},
	{"who": "", "text": "(마을 사람들이 고맙다며 엽전과 약병을 쥐여 주었다.)", "coin": 6, "potion": 1},
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
	{"who": "서휘", "pose": "seohwi", "text": "솜씨가 좋군, 의원.\n그런데 이 녀석들 상처, 절반은 흑룡파 놈들 짓이다."},
	{"who": "서휘", "pose": "seohwi", "text": "흑룡파가 요즘 우리 구역 약한 놈들만 골라 털고 다니지.\n함께 가자, 의원. 치는 건 내가 하고, 다친 사람은 네가 고친다."},
	{"who": "{alias}", "pose": "hero_disguise", "text": "…다친 사람을 고치는 거라면, 갈게요."},
	{"who": "서휘", "pose": "seohwi", "text": "그리고 너에게 맡길 일이 하나 더 있다.\n'청심보명단(淸心保命丹)'. 기운을 북돋는 자양강장 환약이다. 이 처방대로 빚어라."},
	{"who": "{alias}", "pose": "hero_disguise", "text": "인삼, 녹용, 감초… 그리고 이건… 처음 보는 붉은 씨앗이네.\n그래도 처방은 훌륭해 보여. 이 정도면 몸이 약한 사람들한테 좋겠다."},
	{"who": "", "text": "【목표】\n서휘와 함께 흑룡파를 몰아내고,\n한양 곳곳을 돌며 약재를 모아 왈패 소굴로 돌아와라.", "end": true},
]

const C3_DOGYEOL := [
	{"bg": "street_ink", "who": "", "text": "그날 밤부터 한양 곳곳에 '패랭이 쓴 약초꾼'을 찾는 방이 새로 붙었다."},
	{"who": "주막 주모", "pose": "jumo", "text": "꼬마 의원, 이리 숨어! 포졸들이 골목마다 뒤지고 있어."},
	{"who": "{alias}", "pose": "hero_disguise_sad", "text": "(이제 윤도결 나리는 내가 도망자라는 걸 알아. 더 조심해야 해…)"},
	{"who": "주막 주모", "pose": "jumo", "text": "걱정 마. 우리 주막 사람들은 네가 공짜로 고쳐 준 걸 다 기억한다고."},
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
	{"who": "???", "pose": "baegun_boss", "text": "그리고 그 꼬마 의원… 내가 패랭이를 씌워 한양으로 보낸, 허가 놈의 계집아이다.\n잘 붙잡아 둬라. 쓸모가 많을 게다."},
	{"who": "{alias}", "pose": "hero_disguise_surprised", "text": "(내가 여자인 걸 아는 사람은 다래랑… 백운 할아버지뿐인데.\n…아니야. 그럴 리 없어. 저 목소리가 할아버지일 리…)"},
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
	{"bg": "stream", "who": "", "text": "한양을 떠나기 전날 밤, 장맛비가 쏟아졌다.\n불어난 청계천에 한 아이가 휩쓸려 가고 있었다."},
	{"who": "{alias}", "pose": "hero_disguise_surprised", "text": "안 돼!"},
	{"who": "", "text": "{alias}는 망설임 없이 물에 뛰어들었다.\n아이를 둑으로 밀어 올린 순간, 거센 물살이 {alias}를 삼켰다."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "{alias}!!"},
	{"who": "", "text": "철릭을 벗어 던진 윤도결이 뒤따라 뛰어들었다.\n한참 뒤 둑 위로 끌어올린 {alias}는… 숨을 쉬지 않았다."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "정신 차려! …숨을 안 쉬어. 안 돼, 이렇게 보낼 순 없다!"},
	{"who": "", "text": "윤도결은 망설임 없이 {alias}의 가슴을 누르고, 입으로 숨을 불어 넣었다.\n한 번, 두 번, 세 번—"},
	{"who": "", "pose": "hero_sad", "text": "콜록, 콜록…! {alias}가 물을 토해 내며 눈을 떴다.\n떠내려간 패랭이, 젖은 무명천 아래로 풀려 내린 긴 머리, 가냘픈 어깨…"},
	{"who": "윤도결", "pose": "jongsagwan", "text": "…여, 여자였어…?\n네가… 방에 붙은 그 약방 계집아이였구나."},
	{"who": "윤도결", "pose": "jongsagwan_blush", "text": "(…여자였어. 그날 병든 마을에서 가슴이 뛴 게… 이상한 게 아니었구나.\n…다행이다. 정말, 다행이야.)"},
	{"who": "{name}", "pose": "hero_sad", "text": "…제 이름은 {name}예요.\n속여서 죄송해요. 하지만 의원님을 해친 건 정말 제가 아니에요."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "…아이를 구하겠다고 제 목숨도 내던지는 사람이 의원을 해쳤을 리 없지.\n열병 마을에서 밤새 아이들을 돌보던 것도 너였고."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "약방 사건엔 이상한 게 너무 많았다. 돈궤를 연 손은 어른의 손이었고, 핏자국은 의원 본인 것이었지.\n…이제 확신한다. 넌 범인이 아니야. 내가 증명해 주마."},
	{"who": "윤도결", "pose": "jongsagwan_blush", "text": "그, 그리고… 방금 그건 숨을 살리려던 것뿐이다! 오해하지 마라!"},
	{"who": "{name}", "pose": "hero_surprised", "text": "…네? 무슨… 아."},
	{"who": "", "text": "그날 이후, 윤도결은 {name}를 볼 때마다 남몰래 가슴께를 누르곤 했다."},
	{"who": "윤도결", "pose": "jongsagwan_blush", "text": "(…진정해라, 윤도결. 심장이 왜 이리 시끄러운 거냐.)"},
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
	{"who": "", "text": "청안파와 그 대대장을 쓰러뜨린 소녀 의원.\n왈패를 때려잡은 약방 아이의 소문은 바람보다 빨리 팔도에 퍼졌다."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "{name}, 너의 누명은 모두 벗겨졌다.\n그리고… 전하께서 너를 부르신다."},
	{"who": "", "text": "그 사건의 공으로 윤도결은 포도청을 이끄는 포도대장이 되었다."},
	{"who": "", "text": "경복궁 강녕전."},
	{"who": "임금", "pose": "king", "text": "그대가 청심보명단의 독을 밝히고 백성을 구한 의원이로구나.\n여인의 몸으로 그리 하였다니 더욱 기특하도다."},
	{"who": "임금", "pose": "king", "text": "내 그대를 내의원의 의녀로 삼고, 특별히 어의의 소임을 맡기겠노라.\n청심보명단에 상한 백성들을 고쳐 다오."},
	{"who": "{name}", "pose": "hero_physician", "text": "황공하옵니다, 전하.\n…다만 한 가지 청이 있사옵니다. 제 동무 다래도 궁에 함께 들게 해 주시옵소서."},
	{"who": "임금", "pose": "king", "text": "허허, 어의의 첫 청이 동무 걱정이라. 좋다, 허락하노라.\n그 아이를 궁녀로 들여 그대 곁에 두도록 하라."},
	{"who": "다래", "pose": "darae_court", "text": "헤헤, 궁녀복 어때? 이제 매일 같이 있을 수 있어!\n약초 캐는 건 여전히 내가 최고니까, 필요하면 언제든 불러!"},
	{"who": "", "text": "그날부터 {name|은} 궁녀들의 고뿔부터 늙은 내관의 허리병,\n대비마마의 오랜 두통까지 하나하나 고쳐 나갔다."},
	{"who": "임금", "pose": "king", "text": "궁 안 사람들이 모두 그대 칭찬이로다.\n내의원 약재 창고를 모두 열어 줄 터이니, 마음 상한 백성들을 고칠 약을 만들어 보라."},
	{"who": "", "text": "{name|은} 백운의 궤짝 속 처방을 펼쳤다.\n허 의원이 남긴 해독약, '환심단(還心丹)'. 그러나 약재 몇 가지가 빠져 있었다."},
	{"who": "", "text": "【목표】\n궁궐과 한양 곳곳에서 환심단을 완성해\n허 의원의 약방, 그 검은 사내가 기다리는 곳으로 가라.", "end": true},
]

const C5_HEAL := [
	{"who": "", "bg": "palace", "text": "내의원 앞마당. 청심보명단에 정신이 무너진 사람들이 줄지어 들어왔다."},
	{"who": "백성", "pic": "addict", "text": "머리가… 머리가 깨질 것 같아요, 나으리…"},
	{"who": "{name}", "pic": "hero_physician", "text": "괜찮아요. 이 탕약부터 천천히 드세요.\n궁에서 내 준 약재로 빚은 환심단 첫 처방이에요."},
	{"who": "", "text": "사흘 밤낮을 달인 약이 효험을 보였다.\n멍하던 눈빛에 하나둘 빛이 돌아오기 시작했다."},
	{"who": "다래", "pic": "darae_court", "text": "{name}아, 저 아저씨 방금 자기 딸 이름을 불렀어!\n…됐어. 이 약이면 의원님도 돌아오실 수 있을 거야."},
	{"who": "{name}", "pic": "hero_physician", "text": "응. 하지만 의원님 몸속의 검은 것은 훨씬 깊어.\n더 센 약이 필요해. 백년 묵은 하수오가 있어야 해."},
	{"who": "", "text": "(내의원의 지원: 엽전 +8냥, 약병 +2)", "coin": 8, "potion": 2},
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
	{"who": "윤도결", "pic": "jongsagwan_blush", "text": "처음엔 너를 흉악범으로 쫓았고, 도망자라며 칼까지 겨눴지.\n…물에서 너를 건져 낸 그날부터는, 네 얼굴만 떠오르더군."},
	{"who": "{name}", "pic": "hero", "text": "포도대장 나리…",
		"choices": [{"text": "\"같이 가요. 든든할 거예요.\"", "set": "c5_together"}, {"text": "\"나리는 꼭 살아 돌아오셔야 해요.\"", "set": ""}]},
	{"who": "윤도결", "pic": "jongsagwan", "text": "…그 말이면 충분하다."},
]

const CH5_GOAL := [
	{"who": "", "bg": "yakbang", "text": "그믐밤. 모든 것이 시작된 허 의원의 약방."},
	{"who": "검은 사내", "pic": "shadow", "text": "흐흐흐… 기다렸다, 꼬마야.\n백운 그 늙은이가 무너지니 이제 이 몸을 묶어 둘 것도 없지."},
	{"who": "검은 사내", "pic": "shadow", "text": "그 환심단을 이리 내라. 그 약이 허가 놈을 깨우면, 나는 사라진다.\n…싫다. 나는 영원히 밤이고 싶다!"},
	{"who": "{name}", "pic": "hero_angry", "text": "의원님은 저를 길에서 업어다 살려 주셨어요.\n이번엔 제가 의원님을 업고 돌아갈 차례예요!"},
	{"who": "윤도결", "pic": "jongsagwan", "text": "포도대장 윤도결, 함께 간다!", "end": true},
]

const CH5_END := [
	{"bg": "yakbang", "who": "", "text": "검은 사내가 무릎을 꿇은 순간, {name|은} 환심단을 그의 입에 밀어 넣었다."},
	{"who": "검은 사내", "pose": "shadow", "text": "크으윽…! 안 돼… 밤이… 밤이 끝난다…"},
	{"who": "", "text": "검은 연기가 사내의 몸에서 빠져나와 새벽빛 속으로 흩어졌다.\n그리고 그 자리에, 지친 얼굴의 노인이 쓰러져 있었다."},
	{"who": "허 의원", "pose": "heo", "text": "…{name}아? 네가… 어찌 여기에…\n아아, 내가 무슨 짓을… 꿈이 아니었구나…"},
	{"who": "{name}", "pose": "hero_sad", "text": "의원님…! 괜찮아요. 이제 다 끝났어요.\n의원님 마음은 이제 의원님 거예요."},
	{"bg": "byeolchae", "who": "", "text": "그러나 허 의원의 몸은 이미 너무 오래 흑심단에 상해 있었다.\n그는 자리에서 일어나지 못했다."},
	{"who": "허 의원", "pose": "heo", "text": "울지 마라, {name}아.\n마음속 검은 것을 떼어 내려다 오히려 그것에 먹혔구나. 검은 것도 내 마음이었는데…"},
	{"who": "허 의원", "pose": "heo", "text": "길가에 쓰러져 있던 일곱 살 아이가… 이렇게 훌륭한 의원이 되었구나.\n네가 나를 되찾아 주었다. 그거면… 됐다."},
	{"who": "{name}", "pose": "hero_sad", "text": "의원님… 의원님!"},
	{"who": "", "text": "보름 뒤, 매화 꽃잎이 떨어지던 새벽.\n허 의원은 {name}의 손을 잡은 채 조용히 눈을 감았다."},
	{"bg": "jangteo", "who": "", "text": "장례 날. 북촌 어귀부터 운종가까지 사람들이 길게 늘어섰다."},
	{"who": "주막 주모", "pose": "jumo", "text": "약값 없는 우리 같은 사람들을 그리 살펴 주시던 분이…\n하늘도 무심하시지."},
	{"who": "물장수", "pose": "muljangsu", "text": "우리 아이 열병도 그 어른이 밤새 고쳐 주셨수.\n한양에 그런 의원이 또 어디 있겠소…"},
	{"who": "엿장수", "pose": "yeotjangsu", "text": "밤마다 날뛰던 검은 갓 사내 놈은 결국 못 잡았다지?\n그놈이 허 의원님을 해친 게 틀림없어!"},
	{"who": "{name}", "pose": "hero_sad", "text": "(아무도 몰라. 그 검은 사내가 의원님 마음 한구석이었다는 걸.\n…모르는 채로 두자. 사람들 기억 속 의원님은, 가난한 이의 의원님으로 남아야 해.)"},
	{"who": "윤도결", "pose": "jongsagwan", "text": "…포도청 문서에는 '검은 사내는 달아나 행방불명'이라고만 적겠다.\n그게 그 어른께 드릴 수 있는 내 마지막 예다."},
	{"who": "다래", "pose": "darae_court", "text": "{name}아, 울어도 돼. 오늘은 울어도 돼…"},
	{"who": "서휘", "pose": "seohwi", "text": "…의원. 나도 떠난다. 아버지의 나라, 바다 건너 화란(和蘭)으로.\n언젠가 세상 어디서든 다시 만나겠지."},
	{"bg": "palace", "who": "", "text": "{name|은} 슬픔을 삼키고 약을 달였다.\n한 해가 지나기 전, 청심보명단에 상한 사람들이 모두 제 정신을 되찾았다."},
	{"who": "", "text": "― 제5장 「어의」 끝 ―"},
]

# ── 제6장 「만리길」 (세계 지도) ─────────────────────────
const CH6_INTRO := [
	{"bg": "title", "who": "", "text": "― 제7장 「만리길」 ―"},
	{"who": "", "pose": "hero_disguise", "text": "의주에서 압록강을 건너, 청나라 연경으로.\n그리고 배를 타고 남쪽 바다로, 더 서쪽으로."},
	{"who": "{alias}", "pose": "hero_disguise", "text": "의원님, 보고 계세요?\n세상엔 우리가 모르는 약초도, 우리가 모르는 병도 이렇게 많아요."},
	{"who": "", "text": "【목표】\n바닷길을 따라 서쪽 끝 나라, 화란(和蘭)까지 가라.\n길에서 만나는 아픈 이들을 돌보며.", "end": true},
]

const C6_PORT := [
	{"who": "", "bg": "street_ink", "text": "남쪽 바다의 큰 항구. 온갖 빛깔의 사람들이 오갔다."},
	{"who": "역관", "pic": "yakjae", "text": "조선 사람이라고? 이 먼 데까지?\n푸른 눈 사내 하나가 반 년 전 '화란'행 배에 올랐지. 조선말을 하더구먼."},
	{"who": "{alias}", "pic": "hero_disguise_surprised", "text": "푸른 눈… 조선말…\n(설마… 서휘?)"},
	{"who": "", "text": "(역관이 노자를 보태 주었다: 엽전 +6냥)", "coin": 6},
]

const C6_STORM := [
	{"who": "", "bg": "stream", "text": "희망의 곶을 도는 밤, 큰 폭풍이 배를 덮쳤다."},
	{"who": "", "text": "{alias}는 밤새 다친 선원들의 상처를 꿰매고 열을 내렸다.\n새벽, 선장이 모자를 벗어 고개를 숙였다."},
	{"who": "선장", "pic": "pojol", "text": "조선의 젊은 의원이여, 그대 덕에 아무도 죽지 않았소.\n화란까지, 이 배가 모셔다 드리리다."},
	{"who": "", "text": "(선원들의 감사: 최대 체력 +5, 약병 +1)", "maxhp": 5, "potion": 1},
]

const CH6_END := [
	{"bg": "holland", "who": "", "text": "화란, 바닷가의 작은 마을.\n풍차는 멈춰 있었고, 집집마다 문에 흰 십자가가 그려져 있었다."},
	{"who": "", "text": "역병이었다. 아이들부터 쓰러지고 있었다."},
	{"who": "???", "pic": "seohwi_dutch", "text": "…거기 서 있는 동양 청년, 혹시 길을 잃었소?\n이 마을엔 지금 들어오면 안 되오."},
	{"who": "", "text": "낯선 나라의 옷, 그러나 낯익은 금빛 머리칼과 동그란 애체."},
	{"who": "{alias}", "pic": "hero_disguise_surprised", "text": "…서휘?"},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "그 목소리…! {name}?! 네가 왜 여기에…\n…아니, 지금은 그게 중요하지 않군."},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "나는 이 마을 서당… 아니, 학교에서 아이들을 가르치고 있다.\n그런데 내 아이들이 하나둘 죽어 가. 이 나라 의원들은 피를 뽑는 것밖에 모르고."},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "부탁이다, 의원. 다시 한번… 내게 힘을 빌려 다오.", "end": true},
]

# ── 제7장 「화란의 봄」 ─────────────────────────────────
const CH7_INTRO := [
	{"bg": "holland", "who": "", "text": "― 제8장 「화란의 봄」 ―"},
	{"who": "{alias}", "pose": "hero_disguise", "text": "물을 끓여서만 마시게 하고, 앓는 사람은 따로 눕혀.\n열이 오르는 병엔 금은화와 황련이 좋아. 비슷한 풀이 이 나라에도 있을 거야."},
	{"who": "서휘", "pose": "seohwi_dutch", "text": "알았다. 아이들 집은 내가 안다. 앞장서지."},
	{"who": "", "text": "【목표】\n역병 도는 마을을 돌며 아이들을 살피고\n언덕 너머 약초밭에서 약을 구해 와라.", "end": true},
]

const C7_MID := [
	{"who": "", "bg": "holland", "text": "밤늦은 학교 교실. 앓아누운 아이들 사이에서 서휘가 꾸벅꾸벅 졸고 있었다."},
	{"who": "", "pic": "dutch_child", "text": "열이 내린 여자아이가 서휘의 소매를 꼭 쥔 채 잠들어 있었다."},
	{"who": "{alias}", "pic": "hero_disguise", "text": "(조선에선 돈 때문에 독을 팔던 사람이…\n여기선 아이들 곁을 한시도 떠나지 않는구나.)"},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "…깼군. 나는 내 아버지처럼 떠도는 사람이 되기 싫었다.\n누군가 곁에 머물러 주는 사람이 되고 싶었지. 그때 그 다리 밑에서도."},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "그리고… 처음 너를 봤을 때부터, 너는 늘 머무는 사람이었다.\n…아니다. 피곤해서 헛소리를 하는군."},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "(가슴이… 왜 이렇게 뛰지.)",
		"choices": [{"text": "\"…헛소리 아니었으면 좋겠어.\"", "set": "c7_honest"}, {"text": "말없이 담요를 덮어 준다", "set": ""}]},
	{"if": "c7_honest", "who": "서휘", "pic": "seohwi_dutch", "text": "…!\n그럼, 역병이 끝나면 다시 말하지. 제대로."},
]

const CH7_END := [
	{"bg": "holland", "who": "", "text": "봄. 멈췄던 풍차가 다시 돌기 시작했다.\n마을 아이들이 튤립 꽃밭에서 뛰어놀았다."},
	{"who": "서휘", "pose": "seohwi_dutch", "text": "{name}. 약속대로 제대로 말하겠다.\n…너와 함께 조선으로 돌아가고 싶다. 네 곁에 머물고 싶다."},
	{"who": "{name}", "pose": "hero_disguise", "text": "…응. 나도.", "end": true},
]

const EPILOGUE := [
	{"bg": "family", "who": "", "text": "남산 아래, 작은 한옥 한 채.\n대문 위에는 '허씨 약방'이라는 현판이 걸렸다."},
	{"who": "", "pose": "children", "text": "마당엔 금빛 머리칼과 검은 머리칼의 아이들이 뛰어놀고,\n약방 안에선 오늘도 가난한 이에게 약값을 받지 않는다."},
	{"who": "다래", "pose": "darae_adult", "text": "얘들아, 이모 왔다! 오늘은 도라지 캐러 가자!"},
	{"who": "윤도결", "pose": "jongsagwan", "text": "…아이들 눈이 꼭 제 아비를 닮았군. 웃는 얼굴은 어미를 닮았고.\n이 집 앞이 내 순찰 길이오. 무슨 일 있으면 부르시오."},
	{"who": "{name}", "pose": "hero_adult", "text": "의원님. 저, 잘 지내고 있어요.\n의원님이 주신 마음, 이렇게 계속 이어 가고 있어요."},
	{"who": "", "text": "― 한양 숨바꼭질 · 완(完) ―\n\n끝까지 함께해 주셔서 고맙습니다."},
]

# ── 장별 길 위 대화 ─────────────────────────────────────
# ── v1.1 추가 이야기 ──
const CH1_AFTER_SHADOW := [
	{"bg": "byeolchae", "who": "", "text": "그 순간 동녘 능선 위로 해가 솟았다.\n사내는 비명을 지르며 얼굴을 감싸 쥐었다."},
	{"who": "검은 사내", "pose": "shadow", "text": "크윽… 해가…!\n꼬마야, 백운 그 늙은이를 너무 믿지 마라. 흐흐흐…"},
	{"who": "", "text": "사내는 안개 속으로 비틀비틀 달아났다."},
	{"who": "다래", "pose": "friend_worried", "text": "할아버지를 믿지 말라니… 무슨 소리야, 저 사람."},
	{"who": "", "pose": "baegun", "text": "이튿날 아침, 백운 노인은 짐을 꾸리고 있었다."},
	{"who": "백운", "pose": "baegun", "text": "간밤 일은 들었다. 나는 한양에 급히 알아볼 일이 생겼구나.\n먼저 떠나마. 너희는 이틀쯤 쉬었다 오거라."},
	{"who": "백운", "pose": "baegun", "text": "{name}아. …우리 다래를 부탁한다.\n저 아이는 겉으론 씩씩해도 속은 여리단다. 네 곁에 두면 마음이 놓이겠구나."},
	{"who": "{name}", "pose": "hero", "text": "네, 할아버지. 다래는 제가 꼭 지킬게요."},
	{"who": "다래", "pose": "friend", "text": "할아버지! 내가 얘를 지키는 거거든요?"},
	{"who": "", "text": "백운 노인은 허허 웃으며 안개 낀 산길로 사라졌다.\n{name|은} 그 등이 보이지 않을 때까지 고개를 숙였다."},
	{"who": "", "pose": "hero_disguise", "text": "{name|은} 댕기를 풀고, 백운 노인이 내준 패랭이를 깊게 눌러 썼다.\n그날부터 {name|은} 사내아이 '{alias}'가 되었다."},
	{"who": "", "text": "― 제1장 「누명」 끝 ―"},
]

const C2_DG_FIGHT := [
	{"bg": "street_ink", "who": "", "text": "한양 도성이 멀리 보이는 고갯길.\n붉은 술 전립 사이로 검은 철릭이 길을 막았다."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "거기 서라, 약초꾼. 한양 문턱까지 따라왔다.\n…가만, 사내아이치곤 손이 참 곱구나. 패랭이를 벗어 봐라."},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "(벗으면 끝이야…) 싫어요! 길 비켜 주세요!"},
	{"who": "윤도결", "pic": "jongsagwan", "text": "그렇다면 힘으로 확인하겠다."},
]

const C2_DG_FLEE := [
	{"who": "", "text": "윤도결이 무릎을 꿇은 틈에, {alias}는 허리춤의 고춧가루 주머니를 힘껏 던졌다.\n매운 연기가 고갯길을 덮었다."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "콜록… 고춧가루냐…!\n…놓쳤군. 저 녀석, 대체 정체가 뭐냐."},
	{"who": "다래", "pic": "friend", "text": "{alias}, 지금이야! 뛰어!"},
]

const C3_DG_FIGHT := [
	{"bg": "stream", "who": "", "text": "청계천 다리 위.\n약재 꾸러미를 든 {alias} 앞을 포졸들이 에워쌌다."},
	{"who": "포졸", "pic": "pojol", "text": "나리! 이놈입니다, 패랭이 쓴 약초꾼!\n운종가에서 고춧가루를 뿌리고 달아난 바로 그 일행이랍니다."},
	{"who": "포졸", "pic": "pojol", "text": "검문소에서 놓친 놈도, 고갯길에서 놓친 놈도 이놈이었습지요.\n방에 붙은 약방 사건 도망자와 한패가 틀림없습니다!"},
	{"who": "윤도결", "pic": "jongsagwan", "text": "…그랬군. 네가 바로 그 도망자였어.\n두 번이나 속았다. 세 번은 없다."},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "저는 아무 죄도 없어요!"},
]

const C3_DG_AFTER := [
	{"who": "", "text": "{alias}는 포졸들 사이를 빠져나가 다리 밑으로 몸을 날렸다."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "놓쳤군…\n도망자 주제에 발이 빠르구나. 다음엔 반드시 잡는다."},
]

const C3_SHADOW := [
	{"bg": "alley", "who": "", "text": "종로 뒷골목, 통금 인경이 울린 뒤.\n등불이 하나씩 꺼졌다."},
	{"who": "검은 사내", "pic": "shadow", "text": "흐흐… 냄새가 나는구나. 사내 옷을 입어도 약방 냄새는 못 감추지, 꼬마야."},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "의원님 몸에서 나가!"},
]

const C3_SHADOW_FLEE := [
	{"who": "", "text": "파루 종이 울리자, 사내는 몸을 비틀며 지붕 위로 뛰어올랐다."},
	{"who": "검은 사내", "pic": "shadow", "text": "크흐흐… 아직 밤은 길다. 다음엔 놓치지 않으마!"},
	{"who": "", "text": "검은 그림자는 기와지붕 너머로 사라졌다."},
]

const C4_MASK1 := [
	{"bg": "street_ink", "who": "", "text": "포구 뒷길. 은 궤짝을 실은 수레 곁에 삿갓 쓴 노인이 서 있었다."},
	{"who": "삿갓 노인", "pic": "baegun_boss", "text": "…청안파의 서휘로구나. 그리고 그 꼬마 의원.\n장부를 뒤지는 쥐새끼들이 있다더니."},
	{"who": "서휘", "pic": "seohwi_battle", "text": "대대장…! 이번엔 얼굴을 보여 주시지."},
	{"who": "{alias}", "pic": "hero_disguise_surprised", "text": "(저 목소리… 설마…)"},
]

const C4_MASK1_FLEE := [
	{"who": "", "text": "노인의 소매에서 흰 가루가 터졌다.\n매캐한 약 연기 속에서, 수레와 노인은 감쪽같이 사라졌다."},
	{"who": "서휘", "pic": "seohwi", "text": "연막약이군. …약을 아는 자다. 그것도 아주 깊이."},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "약초를 그렇게 잘 다루는 사람은…\n내가 아는 사람 중엔 한 분밖에 없어."},
]

const C4_MASK2 := [
	{"bg": "stream", "who": "", "text": "지리산 어귀, 화엄골로 드는 외나무다리."},
	{"who": "삿갓 노인", "pic": "baegun_boss", "text": "질긴 아이들이로구나. 여기서 돌아가거라.\n이 산은 너희가 들어올 곳이 아니다."},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "이 산은 다래의 고향이에요! 비켜 주세요!"},
]

const C4_MASK2_FLEE := [
	{"who": "", "text": "삿갓이 반쯤 찢겨 나갔다.\n노인은 얼굴을 가린 채 대숲 속으로 몸을 날렸다."},
	{"who": "{alias}", "pic": "hero_disguise_surprised", "text": "방금… 하얀 수염…\n그리고 웃을 때 부채처럼 접히던 그 눈가 주름…"},
	{"who": "서휘", "pic": "seohwi", "text": "쫓자. 놈의 소굴이 이 산 어딘가에 있다."},
]

const C5_SHADOW := [
	{"bg": "palace", "who": "", "text": "궁궐 담장 아래, 달빛이 끊긴 골목."},
	{"who": "검은 사내", "pic": "shadow", "text": "어의가 되었다지? 출세했구나, 꼬마야.\n그 환심단 냄새… 역겹다. 당장 버려라!"},
	{"who": "{name}", "pic": "hero_angry", "text": "버릴 거면 처음부터 만들지도 않았어!"},
]

const C5_SHADOW_FLEE := [
	{"who": "검은 사내", "pic": "shadow", "text": "크윽…! 그 약 냄새만 맡아도 머리가… 허가 놈이 깨어난다…!"},
	{"who": "", "text": "사내는 담을 넘어 달아났다.\n담벼락엔 붉은 손톱자국이 길게 남아 있었다."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "또 놓쳤군. 하지만 이제 알겠다. 놈은 그 약방으로 돌아간다."},
]

const CH6F_INTRO := [
	{"bg": "palace", "who": "", "text": "― 제6장 「작별」 ―"},
	{"who": "{name}", "pose": "hero_physician", "text": "…이제 조선에 내가 고칠 사람은 다 고쳤어.\n의원님이 보지 못한 넓은 세상을, 의원님 대신 보고 싶어."},
	{"who": "", "text": "경복궁 강녕전. {name|은} 임금 앞에 엎드렸다."},
	{"who": "임금", "pose": "king", "text": "세상을 보러 떠나겠다고? 아니 된다.\n그대는 이 나라의 어의다. 궁을 비우는 것을 허락할 수 없노라."},
	{"who": "{name}", "pose": "hero_physician", "text": "전하…"},
	{"who": "", "text": "그때, 뒤에 서 있던 포도대장 윤도결이 무릎을 꿇었다."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "전하, 신 포도대장 윤도결 감히 아뢰옵니다.\n저 아이는 누명을 쓰고도 끝내 백성을 먼저 살핀 의원이옵니다."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "새장에 가두면 저 아이의 의술도 그 안에서 시들 것이옵니다.\n궁의 안위는 신이 목숨을 걸고 지키겠사오니, 부디 길을 열어 주시옵소서."},
	{"who": "임금", "pose": "king", "text": "…포도대장이 이토록 간곡히 청하는 것은 처음 보는구나.\n좋다. 다만 조건이 있다."},
	{"who": "임금", "pose": "king", "text": "궁에서 쓸 약을 넉넉히 지어 두고,\n그대의 의술을 이어받을 사람을 길러 놓고 떠나라."},
	{"who": "{name}", "pose": "hero_physician", "text": "성은이 망극하옵니다, 전하!"},
	{"bg": "yakbang", "who": "", "text": "그날부터 {name|은} 내의원 약방에서 밤낮으로 약을 빚었다.\n환심단, 우황청심환, 쌍화탕… 약장 서랍이 하나둘 가득 찼다."},
	{"who": "다래", "pose": "darae_court", "text": "{name}아, 그럼 네 의술을 이어받을 사람은… 설마 나?"},
	{"who": "{name}", "pose": "hero_physician", "text": "응. 약초 보는 눈은 네가 조선 제일이잖아.\n이제 약 짓는 법까지 배우면, 너는 진짜 의녀가 되는 거야."},
	{"who": "다래", "pose": "darae_court", "text": "…해 볼게. 너 없는 동안 궁은 내가 지킬게!"},
	{"who": "{name}", "pose": "hero_physician", "text": "그럼 첫 수업은 산에서 하자.\n약초는 책보다 산에서 배우는 거라고, 의원님이 그러셨거든."},
	{"who": "", "text": "【목표】\n다래와 함께 북한산에 올라 약초를 가르치며\n산마루 약초밭까지 가라."},
]

const C6F_LESSON := [
	{"bg": "stream", "who": "", "text": "산 중턱 계곡. 다래가 바위틈의 풀 한 포기를 가리켰다."},
	{"who": "다래", "pic": "friend", "text": "이건 내가 알아! 도라지야. 근데 이걸 어떻게 약으로 써?"},
	{"who": "{name}", "pic": "hero_physician", "text": "뿌리를 캐서 껍질을 벗기고 볕에 말려.\n기침과 가래에 좋아. 감초를 조금 넣어 달이면 쓴맛도 덜하고."},
	{"who": "다래", "pic": "friend_worried", "text": "그럼 이건? 할아버지가 독초라고 절대 만지지 말랬던 거."},
	{"who": "{name}", "pic": "hero_physician", "text": "미치광이풀. 할아버지가 나한테도 처음 가르쳐 주신 거야.\n…좋은 의원은 약보다 독을 먼저 알아보는 사람이래."},
	{"who": "다래", "pic": "friend_worried", "text": "…할아버지 생각난다. 그 가르침만큼은 진짜였을 거야."},
	{"who": "", "potion": 2, "text": "(다래가 캔 약초로 약을 달였다: 약병 +2)"},
]

const CH6F_END := [
	{"bg": "byeolchae", "who": "", "text": "산마루 양지바른 비탈. 둘은 해가 질 때까지 흙을 일구었다."},
	{"who": "{name}", "pose": "hero_physician", "text": "약초는 해가 잘 드는 데 심고, 물은 흙이 마를 때만 줘.\n뿌리 약초는 삼 년은 기다려야 해. 조급하면 안 돼."},
	{"who": "다래", "pose": "friend", "text": "삼 년… 그럼 이 도라지가 다 자랄 때쯤엔 너도 돌아와 있겠다."},
	{"who": "{name}", "pose": "hero_physician", "text": "응. 약속할게."},
	{"bg": "title", "who": "", "text": "떠나는 날 새벽, 숭례문 앞."},
	{"who": "다래", "pose": "darae_court", "text": "바보야, 꼭, 꼭 돌아와야 해. 안 오면 내가 찾으러 간다!"},
	{"who": "윤도결", "pose": "jongsagwan", "text": "먼 길에 여인 혼자는 위험하다. …또 사내아이 차림으로 가겠군.\n기다리고 있겠다. 네가 돌아올 때까지."},
	{"who": "", "pose": "hero_disguise", "text": "두 번째 남장. 그리고 이번에는, 세상 끝까지.\n{name|은} 다시 '{alias}'가 되어 한양을 떠났다."},
	{"who": "", "text": "― 제6장 「작별」 끝 ―"},
]

const CH9_INTRO := [
	{"bg": "title", "who": "", "text": "― 마지막 장 「한양의 봄」 ―"},
	{"who": "", "text": "몇 해가 흘렀다.\n열다섯 살 소녀는 어느덧 단아한 아가씨가 되어 있었다."},
	{"who": "", "pose": "hero_adult", "text": "남장을 벗고, 다시 댕기를 맨 {name}.\n서휘와 함께 한양 숭례문을 들어섰다."},
	{"who": "다래", "pose": "darae_adult", "text": "{name}아아아!!\n진짜… 진짜 너야? 바보, 편지라도 좀 하지! 보고 싶었단 말이야!"},
	{"who": "{name}", "pose": "hero_adult", "text": "다래야! 나도 보고 싶었어.\n…그리고 소개할 사람이 있어. 아니, 너도 아는 사람이지만."},
	{"who": "다래", "pose": "darae_adult", "text": "그 도라지 말이야, 올봄에 꽃이 피었어!\n너 돌아오면 같이 캐려고 아껴 뒀지!"},
	{"who": "", "text": "문 곁에는 포도대장 윤도결이 서 있었다.\n마치 그날부터 줄곧 거기 서 있었던 것처럼."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "…돌아왔구나, {name}. 기다리겠다고 했었지.\n매일 아침 순찰 길을 일부러 이 문 앞으로 돌렸다."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "…그런데, 혼인을 한다고?"},
	{"who": "윤도결", "pose": "jongsagwan_blush", "text": "…하. 결국 그 푸른 눈이군.\n축하한다. 진심이다. …조금, 아니 아주 많이 아까울 뿐이다."},
	{"who": "서휘", "pose": "seohwi", "text": "고맙소, 포도대장 나리. 그대가 지켜 준 덕에 이 사람이 여기 있지."},
	{"bg": "wedding", "who": "", "text": "그해 가을, 허 의원의 옛 약방 마당에서 혼례가 열렸다.\n다래는 하루 종일 울다 웃다 했고, 윤도결은 맨 앞자리에서 끝까지 박수를 쳤다."},
	{"bg": "jangteo", "who": "", "text": "혼례 이튿날 아침. 서휘가 {name}의 손을 잡았다."},
	{"who": "서휘", "pose": "seohwi", "text": "우리가 처음 만난 길을 다시 걸어 보지 않겠소?\n그때는 서로 주먹을 겨눴지만, 이번엔 나란히."},
	{"who": "", "text": "【목표】\n서휘와 함께 추억이 깃든 한양 길을 걸어\n남산 아래 새 보금자리 터까지 가라."},
]

const C9_MEM := [
	{"bg": "stream", "who": "", "text": "청계천 수표교 아래.\n옛 왈패 소굴은 이제 아이들 글방이 되어 있었다."},
	{"who": "서휘", "pic": "seohwi", "text": "여기서 네가 처음 내 애체를 노렸지. 한 번도 못 맞혔지만."},
	{"who": "{name}", "pic": "hero_adult", "text": "그땐 사람을 때려 본 적이 없었으니까!\n…지금은 다르다는 거, 아까 그 왈패들한테서 봤지?"},
	{"who": "서휘", "pic": "seohwi", "text": "봤소. 등을 맡길 수 있는 사람이 생긴다는 게 이런 거로군."},
	{"who": "", "text": "다리 밑에서 글 읽는 아이들의 소리가 냇물처럼 흘렀다."},
]

const CH9_END := [
	{"bg": "byeolchae", "who": "", "text": "볕 잘 드는 빈터에서, 서휘와 {name|은} 손수 주춧돌을 놓았다."},
]

const C3_HEUK := [
	{"bg": "alley", "who": "", "text": "흑룡파 왈패들이 꽁무니를 빼고 달아난 골목.\n서휘가 피 묻은 주먹을 털었다."},
	{"who": "{alias}", "pic": "hero_disguise", "text": "가만있어 봐요. 손등 찢어졌잖아요."},
	{"who": "", "text": "{alias}는 서휘의 손에 고약을 바르고 무명천을 감아 주었다."},
	{"who": "{alias}", "pic": "hero_disguise", "text": "…이상해요. 아까 흑룡파한테 맞은 아이를 업고 뛰던 거 봤어요.\n마음은 따뜻한 사람 같은데… 왜 청안파에서 도둑질을 해요?"},
	{"who": "서휘", "pic": "seohwi", "text": "……"},
	{"who": "", "text": "서휘는 한참을 머뭇거리다, 애체를 고쳐 쓰며 입을 열었다."},
	{"who": "서휘", "pic": "seohwi", "text": "이 눈 색깔 말이다. 화란 뱃사람이던 아비가 남기고 간 거지.\n어릴 땐 서당 문턱도 못 넘었다. '양귀(洋鬼) 새끼'라고 돌을 맞았지."},
	{"who": "서휘", "pic": "seohwi", "text": "품을 팔려 해도 아무도 써 주지 않더군. 배가 고파 떡 한 조각을 훔친 게 시작이었다.\n…그러다 보니, 나 같은 놈들이 하나둘 모여 청안파가 됐다."},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "…그랬구나. 미안해요, 함부로 물어서."},
	{"who": "서휘", "pic": "seohwi", "text": "사과할 건 없다. 처음으로 누가 '왜'냐고 물어봐 줬으니까.\n…다들 그냥 '역시 그럴 줄 알았다'고만 했지."},
	{"who": "", "text": "다리 밑 소굴로 돌아가는 서휘의 발걸음은 어쩐지 조금 가벼워 보였다."},
]

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
		{"who": "엿장수", "pic": "yeotjangsu", "text": "포도청 포졸들이 그대들을 찾는다고 장터를 다 뒤지고 갔소.\n조심하시오, 젊은이들.", "coin": 2},
	],
	5: [
		{"who": "백성", "pic": "addict", "text": "어의 나으리… 청심보명단 끊은 뒤로 머리가 덜 아파요.\n고맙습니다… 정말 고맙습니다…", "coin": 2},
		{"who": "약재 상인", "pic": "yakjae", "text": "어의 나으리라니, 출세했구먼!\n환심단에 쓸 감초는 내가 제일 좋은 걸로 골라 놨다네.", "potion": 1},
		{"who": "주막 주모", "pic": "jumo", "text": "궁에 들어가더니 얼굴이 폈네!\n참, 종사관 나리랑 푸른 눈 총각 중에 누가 좋아?", "potion": 1},
		{"who": "엿장수", "pic": "yeotjangsu", "text": "엿 사려~ 어의 나으리 단골 엿이오~!\n공짜로 하나 드리리다. 요즘 그 소문으로 장사가 잘돼서!", "coin": 3},
	],
}

const TALKS_EXTRA := {
	6: [
		{"who": "다래", "pic": "friend", "text": "이건 당귀지? 냄새가 달큰해!\n…맞혔다! 상으로 이건 내가 들고 갈게.", "coin": 2},
		{"who": "약초꾼", "pic": "yakjae", "text": "어의 나으리가 산에 다 오시고!\n이 위 산마루는 볕이 좋아 약초밭으로 그만이오.", "potion": 1},
		{"who": "다래", "pic": "friend", "text": "{name}아, 손 다쳤지? 쑥 짓이겨서 붙여 줄게.\n…봐, 나도 이제 할 줄 알아.", "potion": 1},
		{"who": "엿장수", "pic": "yeotjangsu", "text": "산 위까지 엿 팔러 왔수!\n궁녀님, 어의님, 하나씩 드시구려!", "coin": 3},
	],
	7: [
		{"who": "청나라 약재상", "pic": "yakjae", "text": "조선 인삼이라면 금값이지!\n대신 우리 남쪽 약초 몇 가지를 알려 주리다.", "potion": 1},
		{"who": "항구 주모", "pic": "jumo", "text": "말은 안 통해도 국수는 통하지?\n먹고 가, 젊은이!", "potion": 1},
		{"who": "물장수", "pic": "muljangsu", "text": "이 나라 물은 그냥 마시면 배탈 나우.\n꼭 끓여 마시시오.", "coin": 2},
		{"who": "엿장수", "pic": "yeotjangsu", "text": "엿 대신 이 나라 사탕수수라오!\n하나 맛보고 가쇼.", "coin": 3},
	],
	8: [
		{"who": "마을 아이", "pic": "dutch_child", "text": "(서휘가 통역해 주었다)\n\"동양 의원님, 우리 엄마도 살려 주세요…!\"", "potion": 1},
		{"who": "서휘", "pic": "seohwi_dutch", "text": "저 집 아이는 어제 열이 내렸다.\n…고맙다. 네가 와 줘서.", "coin": 3},
		{"who": "빵집 주인", "pic": "jumo", "text": "(서휘의 통역)\n\"먹고 힘내시오. 이 마을의 은인이니까.\"", "potion": 1},
		{"who": "약초꾼", "pic": "yakjae", "text": "(서휘의 통역)\n\"언덕 너머 풍차 옆에 쓴 풀이 많소. 열병에 쓴다더군.\"", "coin": 2},
	],
	9: [
		{"who": "엿장수", "pic": "yeotjangsu", "text": "아이고, 그때 그 사내아이 의원이…! 아가씨였어?!\n…어쩐지 손이 곱더라니!", "coin": 3},
		{"who": "주막 주모", "pic": "jumo", "text": "이 헛간 기억나? 둘이 국밥 먹고 숨어 있던 데.\n오늘은 신랑이랑 왔네? 국밥 두 그릇, 공짜야!", "potion": 1},
		{"who": "왈패", "pic": "walpae", "text": "형님! 아니, 서휘 선생님! 그리고 형수님!\n저희 이제 다 짐꾼이랑 목수 일 해요. 집 지으실 때 부르세요!", "coin": 4},
		{"who": "물장수", "pic": "muljangsu", "text": "청계천에 뛰어들던 그 아이가 아가씨였다니.\n포도대장 나리가 따라 뛰어든 것도 다 이유가 있었구먼!"},
		{"who": "약재 상인", "pic": "yakjae", "text": "허 의원님 약방을 다시 연다고?\n감초는 평생 내가 대 주지!", "potion": 1},
	],
}

const ALL := {
	"C3_HEUK": C3_HEUK,
	"CH1_AFTER_SHADOW": CH1_AFTER_SHADOW, "C2_DG_FIGHT": C2_DG_FIGHT, "C2_DG_FLEE": C2_DG_FLEE, "C3_DG_FIGHT": C3_DG_FIGHT, "C3_DG_AFTER": C3_DG_AFTER, "C3_SHADOW": C3_SHADOW, "C3_SHADOW_FLEE": C3_SHADOW_FLEE, "C4_MASK1": C4_MASK1, "C4_MASK1_FLEE": C4_MASK1_FLEE, "C4_MASK2": C4_MASK2, "C4_MASK2_FLEE": C4_MASK2_FLEE, "C5_SHADOW": C5_SHADOW, "C5_SHADOW_FLEE": C5_SHADOW_FLEE, "CH6F_INTRO": CH6F_INTRO, "C6F_LESSON": C6F_LESSON, "CH6F_END": CH6F_END, "CH9_INTRO": CH9_INTRO, "C9_MEM": C9_MEM, "CH9_END": CH9_END,
	"CH2_INTRO": CH2_INTRO, "C2_DOGYEOL": C2_DOGYEOL, "C4_PLAGUE": C4_PLAGUE, "CH2_GOAL": CH2_GOAL, "CH2_END": CH2_END,
	"CH3_INTRO": CH3_INTRO, "C3_DOGYEOL": C3_DOGYEOL, "C3_TRUTH": C3_TRUTH, "C3_BOSS": C3_BOSS, "C3_BOSS_WIN": C3_BOSS_WIN, "CH3_END": CH3_END,
	"CH4_INTRO": CH4_INTRO, "C4_STREAM": C4_STREAM, "C4_CLUE": C4_CLUE, "CH4_GOAL": CH4_GOAL, "CH4_END": CH4_END, "CH4_AFTER_DUEL": CH4_AFTER_DUEL,
	"CH5_INTRO": CH5_INTRO, "C5_HEAL": C5_HEAL, "C5_SEOHWI": C5_SEOHWI,
	"CH6_INTRO": CH6_INTRO, "C6_PORT": C6_PORT, "C6_STORM": C6_STORM, "CH6_END": CH6_END,
	"CH7_INTRO": CH7_INTRO, "C7_MID": C7_MID, "CH7_END": CH7_END, "EPILOGUE": EPILOGUE, "C5_DOGYEOL": C5_DOGYEOL, "CH5_GOAL": CH5_GOAL, "CH5_END": CH5_END,
}

## 장마다 보드의 적 이름을 바꿔 끼움
const ENEMY_MAP := {
	3: {"walpae": "rival", "pojol": "pojol"},
	4: {"walpae": "sanjeok", "pojol": "pojol"},
	5: {"walpae": "mob", "pojol": "mob"},
	6: {"walpae": "sanjeok", "pojol": "sanjeok"},
	7: {"walpae": "haejeok", "pojol": "haejeok"},
	8: {"walpae": "rat", "pojol": "haejeok"},
	9: {"walpae": "walpae", "pojol": "walpae"},
}

## 전투를 거드는 동료
const ALLIES := {
	"seohwi": {"name": "서휘", "dmg": 7, "line": "서휘의 일격!"},
	"dogyeol": {"name": "윤도결", "dmg": 6, "block": 4, "line": "윤도결이 막아선다!"},
	"darae": {"name": "다래", "dmg": 4, "block": 3, "line": "다래의 고춧가루 공격!"},
}

## 아직 그림이 없어 도트로 대신하는 인물 (진짜 그림이 오면 여기서 지운다)
const PLACEHOLDERS := []
