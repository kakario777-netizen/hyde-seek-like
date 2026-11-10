class_name StoryData
## 제2장~제5장 이야기, 장(章) 설정, 장별 길 위 대화
## 인물: 윤도결(포도청 종사관) · 서휘(왈패 대장, 푸른 눈의 혼혈, 애체(안경)) · 백운(다래 할아버지 = 왈패 대대장)

# ── 장 설정 ─────────────────────────────────────────────
# board: 보드 파일 / days: 기한 / goal: 목적지 이름 / goal_pre·goal_battle·goal_lose_ok: 목적지에서 벌어지는 이야기와 싸움
# stages: 작은 맵들 (map: assets/data/stages/<map>.json, after: 그 맵을 끝낸 뒤 나오는 이야기)
# world: true 이면 대동여지도식 큰 지도(board)를 그대로 쓴다
const CHAPTERS := {
	1: {"title": "제1장  누명", "goal": "화엄골", "intro": "PROLOGUE", "end": "CHAPTER1_END",
		"stages": [{"map": "s1_0", "name": "운종가 약재 심부름", "after": "PROLOGUE_B", "after_story": true,
				"errand": ["당귀", "감초", "숙지황"], "foes": {"walpae": "walpae", "pojol": "walpae"}, "extra_guards": 1},
			{"map": "s1_1", "name": "운종가를 지나 도망치기", "after": "story1"},
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
		"stages": [{"map": "s3_h", "name": "자양강장 약재 찾기", "after": "C3_BREW", "errand": ["인삼", "황기", "감초"]},
			{"map": "s3_0", "name": "서휘와 흑룡파 몰아내기", "after": "C3_HEUK", "ally": "seohwi"},
			{"map": "s3_1", "name": "청계천 약재 심부름", "after": "C3_DOGYEOL"},
			{"map": "s3_k", "name": "소금 창고의 아이들", "after": "C3_HK2", "ally": "seohwi"},
			{"map": "s3_2", "name": "종로 뒷골목", "after": "C3_TRUTH"},
			{"map": "s3_3", "name": "남산 아래 결투"}],
		"goal_text": "청계천 다리 밑, 왈패 소굴로 돌아왔다.\n안쪽 방에서 낮은 목소리가 새어 나온다…", "goal_title": "왈패 소굴", "goal_pic": "", "goal_bg": "den"},
	4: {"title": "제4장  대대장", "goal": "천수각", "intro": "CH4_INTRO", "end": "CH4_END",
		"stages": [{"map": "s4_0", "foes": {"walpae": "walpae", "pojol": "pojol"}, "name": "성 밖 병든 마을", "after": "C4_PLAGUE"},
			{"map": "s4_1", "foes": {"walpae": "walpae", "pojol": "pojol"}, "name": "비 오는 청계천", "after": "C4_STREAM"},
			{"map": "s4_2", "name": "군산 포구 뒤지기", "after": "C4_CLUE"},
			{"map": "s4_3", "name": "화엄골 가는 길", "after": "C4_CASTLE",
				"after_battle": {"battle": "seohwi3", "pre": "C4_GATE_PRE", "post": "C4_GATE_POST", "lose_ok": true}},
			{"map": "s4_f1", "foes": {"walpae": "rival", "pojol": "mob"}, "name": "백운의 성 1층 · 창고", "after": "C4_F1"},
			{"map": "s4_f2", "foes": {"walpae": "rival", "pojol": "mob"}, "name": "백운의 성 2층 · 독안개 회랑", "after": "C4_F2"},
			{"map": "s4_f3", "foes": {"walpae": "rival", "pojol": "mob"}, "name": "백운의 성 3층 · 약 공방", "after": "C4_F3"},
			{"map": "s4_f4", "foes": {"walpae": "rival", "pojol": "mob"}, "name": "백운의 성 4층 · 보물고", "after": "C4_F4"},
			{"map": "s4_f5", "foes": {"walpae": "rival", "pojol": "mob"}, "name": "백운의 성 5층 · 천수각", "ally": "seohwi"}],
		"goal_pre": "CH4_GOAL", "goal_battle": "baegun", "goal_ally": "seohwi",
		"end_battle": "darae", "end_after": "CH4_AFTER_DUEL"},
	5: {"title": "제5장  어의", "goal": "허 의원 약방", "intro": "CH5_INTRO", "end": "CH5_END",
		"stages": [{"map": "s5_1", "foes": {"walpae": "mob", "pojol": "mob"}, "name": "내의원 환자 돌보기", "after": "C5_HEAL"},
			{"map": "s5_2", "name": "종로에서 약재 구하기", "after": "C5_SEOHWI"},
			{"map": "s5_3", "name": "궁궐 담장 아래", "after": "C5_DOGYEOL"},
			{"map": "s5_4", "name": "허 의원 약방으로"}],
		"goal_pre": "CH5_GOAL", "goal_battle": "shadow", "goal_ally": "dogyeol"},
	6: {"title": "제6장  작별", "goal": "산마루 약초밭", "intro": "CH6F_INTRO", "end": "CH6F_END", "stage_ally": "darae",
		"stages": [{"map": "s6_1", "foes": {"walpae": "sanjeok", "pojol": "sanjeok"}, "name": "다래와 북한산 오르기", "after": "C6F_LESSON"},
			{"map": "s6_2", "name": "산마루 약초밭으로"}],
		"goal_text": "산마루, 볕 잘 드는 비탈에 닿았다.\n여기라면 약초가 잘 자라겠다!", "goal_title": "산마루 약초밭", "goal_pic": "friend", "goal_bg": "mountain"},
	7: {"title": "제7장  만리길", "world": true, "board": "board6", "days": 30, "goal": "화란", "intro": "CH6_INTRO", "end": "CH6_END",
		"goal_text": "멀리 바닷가에 풍차가 보인다.\n서쪽 끝 나라, 화란에 닿았다!", "goal_title": "화란", "goal_pic": "", "goal_bg": "holland"},
	8: {"title": "제8장  화란의 봄", "goal": "풍차 언덕", "intro": "CH7_INTRO", "end": "CH7_END", "stage_ally": "seohwi",
		"stages": [{"map": "s7_1", "name": "역병 도는 마을", "after": "C7_MID", "patients": 3},
			{"map": "s7_2", "name": "풍차 언덕 약초밭", "after": "C7_SICK", "patients": 3}],
		"goal_text": "풍차 옆 언덕에 쓴 약초가 가득하다.\n이것이면 마을을 살릴 수 있다!", "goal_title": "풍차 언덕", "goal_pic": "seohwi_dutch", "goal_bg": "holland"},
	9: {"title": "마지막 장  돌아오는 봄", "goal": "남산 아래 집터", "intro": "C9_LEAVE", "end": "CH9_END", "epilogue": "EPILOGUE", "stage_ally": "seohwi",
		"stages": [{"map": "h_port", "name": "화란 항구, 떠나는 날", "after": "C9_SHIP", "foes": {"walpae": "haejeok", "pojol": "haejeok"}},
			{"map": "h_deck", "name": "귀향의 바닷길", "after": "C9_RETURN", "after_story": true, "foes": {"walpae": "haejeok", "pojol": "haejeok"}},
			{"map": "s9_p", "name": "포도청 수련", "after": "C10_SHOP_LETTER", "after_story": true, "ally": "", "token": "seohwi_podo", "me_name": "서휘",
				"foes": {"walpae": "walpae", "pojol": "rival"}},
			{"map": "s10_isle", "name": "남쪽 유배 섬 가는 길", "after": "C10_ISLE", "after_story": true, "ally": "darae",
				"foes": {"walpae": "haejeok", "pojol": "haejeok"}},
			{"map": "s10_palace", "name": "밤의 궁궐 잠입", "after": "C10_CLUE", "after_story": true,
				"foes": {"walpae": "naegeumwi", "pojol": "naegeumwi"}, "ally": "seohwi"},
			{"map": "s10_mapo", "name": "마포 나루 청 상인 창고", "after": "C10_CURE_WED", "after_story": true,
				"foes": {"walpae": "mapo_thug", "pojol": "merchant_gang"}, "ally": "seohwi"},
			{"map": "s9_1", "name": "운종가에서 청계천까지", "after": "C9_MEM"},
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
		"PROLOGUE_B": return GameData.PROLOGUE_B
		"C9_RETURN": return C9_HOMEWARD + [{"bg": "title", "who": "", "text": "그리고, 한양."}] + CH9_INTRO.slice(2, 11) + C9_KING + C9_DARAE + C9_BRIDGE
		"C9_SHOP_WED": return C9_SHOP + CH9_INTRO.slice(11)
		"C10_SHOP_LETTER": return C9_SHOP + C10_LETTER
		"C10_ISLE": return C10_EXILE + C10_FALL
		"C10_CURE_WED": return C10_CURE + CH9_INTRO.slice(11)
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
	{"music": "heart_flutter", "who": "윤도결", "pic": "jongsagwan_blush", "text": "(사내아이를 보고 두근거리다니… 이러면 안 된다, 윤도결.\n정신 차려라. 도망자는 도망자다.)"},
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
	{"who": "서휘", "pose": "seohwi", "text": "그리고 너에게 맡길 일이 하나 더 있다.\n먹으면 기운이 펄펄 나는 자양강장 환약. 그걸 만들어 팔면 내 아이들이 겨울을 난다."},
	{"who": "{alias}", "pose": "hero_disguise_surprised", "text": "처방은요? 무슨 약재를 얼마나 넣는지 알려 주셔야…"},
	{"who": "서휘", "pose": "seohwi", "text": "처방 같은 건 없다. 의원이라며?\n네 머리로, 네 손으로 만들어 봐라. 약재는 직접 구해 오고."},
	{"who": "{alias}", "pose": "hero_disguise", "text": "(기운을 북돋는 약이라면… 인삼, 황기, 감초.\n의원님 어깨 너머로 본 것만으로 될까…)"},
	{"who": "", "text": "【목표】\n청계천 둔치와 산기슭을 돌며\n인삼·황기·감초를 모두 구해 소굴로 돌아와라."},
]

## 약재를 구해 왔지만 약이 잘 안 된다 → 삿갓 노인의 재료 → 청심보명단 완성
const C3_BREW := [
	{"bg": "den", "who": "", "text": "소굴 구석, 약탕관 앞.\n{alias}는 사흘 밤낮 인삼과 황기, 감초를 달이고 빻고 환으로 빚었다."},
	{"who": "왈패", "pose": "walpae", "text": "꼬마 의원, 이거… 쓰기만 하고 아무렇지도 않은데?\n기운이 나긴커녕 졸리기만 하다."},
	{"who": "{alias}", "pose": "hero_disguise_sad", "text": "(배합이 틀렸나… 달이는 시간이 모자랐나.\n의원님이라면 금방 아셨을 텐데. 나는 아무것도 몰라…)"},
	{"who": "", "text": "그날 밤, 소굴 문간에 삿갓을 깊이 눌러쓴 백운 노인이 서휘를 찾아왔다."},
	{"who": "백운", "pose": "baegun_boss", "text": "서휘야. 그 의원 아이의 약이 잘 안 된다지?\n이 붉은 씨앗과 가루를 그 아이에게 건네거라. 약에 조금만 섞으면 효험이 확 오를 게다."},
	{"who": "백운", "pose": "baegun_boss", "text": "…내가 줬다는 말은 하지 말고."},
	{"who": "서휘", "pose": "seohwi", "text": "…예, 대대장님."},
	{"who": "", "text": "삿갓 노인은 다시 어둠 속으로 사라졌다."},
	{"who": "서휘", "pose": "seohwi", "text": "…의원. 이걸 써 봐라.\n어떤 어른이 주신 거다. 약에 조금만 섞으면 효험이 확 오른다더군."},
	{"who": "", "text": "주머니 안에는 처음 보는 붉은 씨앗과, 반짝이는 붉은 가루가 들어 있었다."},
	{"who": "{alias}", "pose": "hero_disguise", "text": "(처음 보는 약재야… 이름도 모르는데.)",
		"choices": [{"text": "\"…써 볼게요. 아이들 겨울나기가 걸렸으니까.\"", "set": ""}, {"text": "\"이게 뭔지 알아요?\" 하고 묻는다", "set": "c3_asked"}]},
	{"if": "c3_asked", "who": "서휘", "pose": "seohwi", "text": "모른다. 나도 묻지 않았다.\n…그 어른이 주는 건, 늘 잘 들었지."},
	{"who": "", "text": "붉은 씨앗을 조금 빻아 넣자, 탕약 빛깔이 순식간에 맑은 금빛으로 바뀌었다."},
	{"who": "왈패", "pose": "walpae", "text": "오, 오오…! 이거다, 꼬마 의원!\n삼 일 굶은 것처럼 축 처져 있었는데 몸이 날아갈 것 같아!"},
	{"who": "서휘", "pose": "seohwi", "text": "…됐군. 이름은 '청심보명단(淸心保命丹)'이라 하자.\n마음을 맑게 하고 목숨을 지키는 약."},
	{"who": "{alias}", "pose": "hero_disguise", "text": "(내 손으로 만든 첫 약이야.\n…이걸로 아픈 사람들이 기운을 차리면 좋겠다.)"},
	{"who": "", "text": "【목표】\n서휘와 함께 흑룡파를 몰아내고,\n한양 곳곳을 돌며 약재를 모아 왈패 소굴로 돌아와라."},
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
	{"who": "{alias}", "pic": "hero_disguise_surprised", "text": "그 붉은 씨앗… 만다라야. 그리고 그 붉은 가루는 주사(朱砂).\n의원님이 흑심단에 넣던 거랑 똑같아…!"},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "처음엔 기운이 나는 것 같지만, 끊으면 머리가 깨질 듯 아프고…\n오래 먹으면 정신이 무너져."},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "…내 탓이야.\n약초를 제대로 알지도 못하면서, 이름도 모르는 재료를 남이 준다고 덥석 넣었어."},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "의원님은 늘 '약보다 독을 먼저 알아보라'고 하셨는데.\n내 지식이 모자라서, 남한테 기대서… 이런 참사를 만들었어."},
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
	{"bg": "den", "who": "", "text": "이튿날 아침, 소굴 안쪽 방.\n서휘는 창밖 청계천을 바라본 채 한참을 말이 없었다."},
	{"who": "서휘", "pose": "seohwi", "text": "…어젯밤 대대장이 그러더군. 꼬마 의원은 '허가 놈의 계집아이'라고."},
	{"who": "{alias}", "pose": "hero_disguise_sad", "text": "……"},
	{"who": "", "pose": "hero_sad", "text": "{alias}는 천천히 패랭이를 벗었다.\n동여맨 머리를 풀자, 긴 머리칼이 어깨 위로 흘러내렸다."},
	{"who": "{name}", "pose": "hero_sad", "text": "…제 이름은 {name}예요. 허 의원님 약방에서 자란 아이요.\n누명을 쓰고 쫓기느라, 사내아이인 척할 수밖에 없었어요."},
	{"who": "서휘", "pose": "seohwi", "text": "……"},
	{"who": "서휘", "pose": "seohwi", "text": "…어쩐지. 다친 놈들 이마를 짚던 손이 사내 손치곤 너무 조심스러웠지.\n처음부터 조금은 알고 있었는지도 모르겠군."},
	{"who": "{name}", "pose": "hero_surprised", "text": "화… 화 안 나요? 속였는데."},
	{"who": "서휘", "pose": "seohwi", "text": "속인 건 나도 마찬가지다. 그 씨앗이 수상한 줄 알면서도 너에게 건넸으니.\n…사내든 계집이든, 너는 내 아이들을 고쳐 준 의원이다. 그건 변하지 않아."},
	{"who": "서휘", "pose": "seohwi", "text": "(…그런데 왜 이렇게 가슴이 시끄럽지.\n정신 차려라, 서휘. 지금은 그럴 때가 아니다.)"},
	{"who": "", "pose": "hero_disguise", "text": "{name}는 다시 머리를 동여매고 패랭이를 눌러 썼다.\n\"밖에선 여전히 '{alias}'예요. 아직은 쫓기는 몸이니까요.\""},
	{"who": "서휘", "pose": "seohwi", "text": "그 붉은 씨앗과 가루를 준 건 대대장이다.\n얼굴은 늘 삿갓으로 가리지만, 돈은 전부 남쪽 지리산으로 실려 간다."},
	{"who": "서휘", "pose": "seohwi", "text": "나는 이제 더는 못 하겠다. 내 아이들한테 독을 팔게 할 순 없어.\n…네 힘을 빌리고 싶다, 의원."},
	{"who": "{alias}", "pose": "hero_disguise", "text": "그 전에, 다래부터 풀어 줘."},
	{"who": "서휘", "pose": "seohwi", "text": "이미 풀어 줬다. 할아버지께 알리겠다며 먼저 지리산으로 떠났지.\n…그리고, 너한테 이것도 돌려주마."},
	{"who": "", "text": "서휘가 내민 것은 허 의원 약방 지하실의 열쇠였다."},
	{"who": "서휘", "pose": "seohwi", "text": "지하실엔 아무것도 없었다. 해독약 처방을 적은 책장만 통째로 뜯겨 나갔더군.\n가져간 사람은… 대대장일 거다."},
	{"who": "", "text": "【목표】\n서휘와 함께 대대장의 돈이 흘러가는 지리산 화엄골로 향하라.\n이번에는 서쪽 바닷길이다.", "end": true},
]

const C4_STREAM := [
	{"bg": "stream", "who": "", "pose": "hero_disguise", "text": "한양을 떠나기 전날 밤, 장맛비가 쏟아졌다.\n불어난 청계천에 한 아이가 휩쓸려 가고 있었다."},
	{"who": "{alias}", "pose": "hero_disguise_surprised", "text": "안 돼!"},
	{"who": "", "pose": "hero_disguise_surprised", "text": "{alias}는 망설임 없이 물에 뛰어들었다.\n아이를 둑으로 밀어 올린 순간, 거센 물살이 {alias}를 삼켰다."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "{alias}!!"},
	{"who": "", "pose": "jongsagwan", "text": "철릭을 벗어 던진 윤도결이 뒤따라 뛰어들었다.\n한참 뒤 둑 위로 끌어올린 {alias}는… 숨을 쉬지 않았다."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "정신 차려! …숨을 안 쉬어. 안 돼, 이렇게 보낼 순 없다!"},
	{"who": "", "pose": "jongsagwan", "text": "윤도결은 망설임 없이 {alias}의 가슴을 누르고, 입으로 숨을 불어 넣었다.\n한 번, 두 번, 세 번—"},
	{"who": "", "pose": "hero_sad", "text": "콜록, 콜록…! {alias}가 물을 토해 내며 눈을 떴다.\n떠내려간 패랭이, 젖은 무명천 아래로 풀려 내린 긴 머리, 가냘픈 어깨…"},
	{"music": "heart_flutter", "who": "윤도결", "pose": "jongsagwan", "text": "…여, 여자였어…?\n네가… 방에 붙은 그 약방 계집아이였구나."},
	{"who": "윤도결", "pose": "jongsagwan_blush", "text": "(…여자였어. 그날 병든 마을에서 가슴이 뛴 게… 이상한 게 아니었구나.\n…다행이다. 정말, 다행이야.)"},
	{"who": "{name}", "pose": "hero_sad", "text": "…제 이름은 {name}예요.\n속여서 죄송해요. 하지만 의원님을 해친 건 정말 제가 아니에요."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "…아이를 구하겠다고 제 목숨도 내던지는 사람이 의원을 해쳤을 리 없지.\n열병 마을에서 밤새 아이들을 돌보던 것도 너였고."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "약방 사건엔 이상한 게 너무 많았다. 돈궤를 연 손은 어른의 손이었고, 핏자국은 의원 본인 것이었지.\n…이제 확신한다. 넌 범인이 아니야. 내가 증명해 주마."},
	{"who": "윤도결", "pose": "jongsagwan_blush", "text": "그, 그리고… 방금 그건 숨을 살리려던 것뿐이다! 오해하지 마라!"},
	{"who": "{name}", "pose": "hero_surprised", "text": "…네? 무슨… 아."},
	{"who": "", "pose": "jongsagwan_blush", "text": "그날 이후, 윤도결은 {name}를 볼 때마다 남몰래 가슴께를 누르곤 했다."},
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
	{"who": "", "bg": "cheonsugak", "text": "백운의 성 5층, 천수각.\n금칠한 기둥 사이로 화엄골 골짜기가 발아래 펼쳐졌다."},
	{"who": "???", "pic": "baegun_boss", "text": "기어이 여기까지 왔구나. 서휘, 그리고… 허가 놈의 계집아이."},
	{"who": "", "text": "삿갓이 벗겨졌다.\n하얗게 센 수염, 자애롭게 웃던 다래의 할아버지."},
	{"who": "백운", "pic": "baegun_boss", "text": "흑심단은 원래 내 처방이었다. 마음의 검은 것을 떼어 내는 약?\n그건 허가 놈의 헛된 꿈이었지. 나는 그 약으로 사람을 길들이는 법을 알아냈을 뿐."},
	{"who": "백운", "pic": "baegun_boss", "text": "허가 놈이 제 몸에 흑심단을 시험하도록 부추긴 것도 나다.\n그 검은 사내는 내가 쓰기 좋은 개였지. 흐흐흐…"},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "당신이… 당신 때문에 의원님이…!\n다래가 얼마나 할아버지를 자랑스러워했는데!"},
	{"who": "서휘", "pic": "seohwi_battle", "text": "의원, 같이 간다. 내 아이들의 몫까지.", "end": true},
]

const CH4_END := [
	{"bg": "cheonsugak", "who": "", "text": "백운이 무릎을 꿇었다.\n성 아래에서 뒤따라 올라온 윤도결과 포졸들이 노인을 오랏줄로 묶었다."},
	{"who": "다래", "pose": "friend_worried", "text": "할아버지?! …{alias}, 너…\n우리 할아버지한테 무슨 짓을 한 거야!"},
	{"who": "{alias}", "pose": "hero_disguise_sad", "text": "다래야, 들어 봐. 할아버지가 청심보명단을…"},
	{"who": "다래", "pose": "friend_worried", "text": "듣기 싫어! 너만 믿고 따라왔는데…\n결국 우리 할아버지를 포도청에 넘기려고 날 이용한 거잖아!", "end": true},
]

const CH4_AFTER_DUEL := [
	{"bg": "cheonsugak", "who": "", "text": "다래의 주먹이 힘없이 풀렸다.\n그때, 묶여 있던 백운이 쉰 목소리로 입을 열었다."},
	{"who": "백운", "pose": "baegun", "text": "…그만해라, 다래야. 그 아이 말이 맞다.\n이 할애비가 돈에 눈이 멀어 몹쓸 짓을 했다."},
	{"who": "백운", "pose": "baegun", "text": "약방 지하에서 가져간 해독약 처방은 저 궤짝 안에 있다.\n…허가를 살려 다오. 그게 내가 할 수 있는 마지막 속죄다."},
	{"who": "다래", "pose": "friend_worried", "text": "할아버지…\n…{alias}, 아니, {name}아. 미안해. 정말 미안해…"},
	{"who": "{name}", "pose": "hero_sad", "text": "나도 미안해. 더 일찍 말했어야 했는데.\n…우리, 아직 친구지?"},
	{"who": "다래", "pose": "friend", "text": "당연하지, 바보야!"},
	{"who": "서휘", "pose": "seohwi", "text": "…{name}. 이제 다래도 너를 진짜 이름으로 부르는군.\n(독을 빚게 한 나를 끝까지 사람으로 대해 준 사람. …잊지 못하겠군.)"},
	{"who": "윤도결", "pose": "jongsagwan", "text": "{name}, 그리고 서휘.\n너희 덕분에 삿갓 노인을 잡을 수 있었다. …고맙다."},
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
	{"who": "{name}", "pose": "hero", "text": "황공하옵니다, 전하.\n…다만 한 가지 청이 있사옵니다. 제 동무 다래도 궁에 함께 들게 해 주시옵소서."},
	{"who": "임금", "pose": "king", "text": "허허, 어의의 첫 청이 동무 걱정이라. 좋다, 허락하노라.\n그 아이를 궁녀로 들여 그대 곁에 두도록 하라."},
	{"music": "darae_cheer", "who": "다래", "pose": "darae_court", "text": "헤헤, 궁녀복 어때? 이제 매일 같이 있을 수 있어!\n약초 캐는 건 여전히 내가 최고니까, 필요하면 언제든 불러!"},
	{"who": "", "text": "그날부터 {name|은} 궁녀들의 고뿔부터 늙은 내관의 허리병,\n대비마마의 오랜 두통까지 하나하나 고쳐 나갔다."},
	{"who": "임금", "pose": "king", "text": "궁 안 사람들이 모두 그대 칭찬이로다.\n내의원 약재 창고를 모두 열어 줄 터이니, 마음 상한 백성들을 고칠 약을 만들어 보라."},
	{"who": "", "text": "{name|은} 백운의 궤짝 속 처방을 펼쳤다.\n허 의원이 남긴 해독약, '환심단(還心丹)'. 그러나 약재 몇 가지가 빠져 있었다."},
	{"who": "", "text": "【목표】\n궁궐과 한양 곳곳에서 환심단을 완성해\n허 의원의 약방, 그 검은 사내가 기다리는 곳으로 가라.", "end": true},
]

const C5_HEAL := [
	{"who": "", "bg": "palace", "text": "내의원 앞마당. 청심보명단에 정신이 무너진 사람들이 줄지어 들어왔다."},
	{"who": "백성", "pic": "addict", "text": "머리가… 머리가 깨질 것 같아요, 나으리…"},
	{"who": "{name}", "pic": "hero", "text": "괜찮아요. 이 탕약부터 천천히 드세요.\n궁에서 내 준 약재로 빚은 환심단 첫 처방이에요."},
	{"who": "", "text": "사흘 밤낮을 달인 약이 효험을 보였다.\n멍하던 눈빛에 하나둘 빛이 돌아오기 시작했다."},
	{"who": "다래", "pic": "darae_court", "text": "{name}아, 저 아저씨 방금 자기 딸 이름을 불렀어!\n…됐어. 이 약이면 의원님도 돌아오실 수 있을 거야."},
	{"who": "{name}", "pic": "hero", "text": "응. 하지만 의원님 몸속의 검은 것은 훨씬 깊어.\n더 센 약이 필요해. 백년 묵은 하수오가 있어야 해."},
	{"who": "", "text": "(내의원의 지원: 엽전 +8냥, 약병 +2)", "coin": 8, "potion": 2},
	{"who": "", "bg": "street_ink", "text": "해 질 녘, 약재를 사러 궁 밖으로 나선 길.\n순찰을 돌던 포도대장 윤도결과 우연히 마주쳤다."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "{name}. …이제 쫓기는 몸이 아닌 너를 길에서 만나니, 어쩐지 낯설군."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "한 가지 늘 궁금했다.\n포도청 문서에 네 이름이 처음 오른 건 허 의원이 사라진 날 새벽이었지.\n…어쩌다 네가 의심을 받아 도망자가 된 거냐?"},
	{"who": "{name}", "pic": "hero_sad", "text": "그날 밤, 검은 갓 쓴 사내가 약방을 다 뒤엎고 갔어요.\n새벽에 포졸들이 들이닥쳤는데… 의원님은 사라지고, 돈궤는 비어 있고, 핏자국까지 있었죠."},
	{"who": "{name}", "pic": "hero_sad", "text": "밤새 그 집에 있던 건 저 하나뿐이라고, 검은 갓 이야기는 핑계라며 오랏줄부터 꺼내더라고요.\n잡히면 의원님을 찾을 사람이 아무도 없을 것 같아서… 편지를 품고 뒷문으로 달아났어요."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "…그랬군. 그 새벽 보고에는 '수상한 계집아이가 돈궤를 털고 달아났다'는 한 줄뿐이었다.\n나도 그 한 줄만 믿고 너를 쫓았지."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "포도청이 진짜 범인 대신 억울한 아이를 쫓은 셈이다. …미안하다.\n이제부터는 문서 한 줄보다 사람의 말을 먼저 듣겠다."},
	{"who": "{name}", "pic": "hero", "text": "나리가 그렇게 말해 주시니까…\n그때 그 밤들이 조금은 덜 무서웠던 것 같아요."},
	{"who": "윤도결", "pic": "jongsagwan_blush", "text": "…흠. 순찰을 마저 돌아야겠군.\n해 지기 전에 궁으로 들어가라. 조심하고."},
]

const C5_SEOHWI := [
	{"who": "", "bg": "street_ink", "text": "종로 네거리. 낯익은 금빛 머리칼이 보였다."},
	{"who": "서휘", "pic": "seohwi", "text": "어의 나으리께서 여긴 어쩐 일이신가.\n…농담이다. 청안파는 이제 약방 대신 짐꾼 일을 한다. 정직하게 벌어서 정직하게 먹지."},
	{"who": "서휘", "pic": "seohwi", "text": "환심단에 들어갈 '백년 묵은 하수오'를 찾는다고?\n내 아이들이 남산 바위틈에서 하나 캐 왔다. 받아라."},
	{"who": "{name}", "pic": "hero", "text": "서휘… 고마워."},
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
	{"bg": "byeolchae", "music": "sad_farewell", "who": "", "text": "그러나 허 의원의 몸은 이미 너무 오래 흑심단에 상해 있었다.\n그는 자리에서 일어나지 못했다."},
	{"who": "허 의원", "pose": "heo", "text": "울지 마라, {name}아.\n마음속 검은 것을 떼어 내려다 오히려 그것에 먹혔구나. 검은 것도 내 마음이었는데…"},
	{"who": "허 의원", "pose": "heo", "text": "길가에 쓰러져 있던 일곱 살 아이가… 이렇게 훌륭한 의원이 되었구나.\n네가 나를 되찾아 주었다. 그거면… 됐다."},
	{"who": "{name}", "pose": "hero_sad", "text": "의원님… 그날 밤, 소리 지르고 뛰쳐나가서 죄송해요.\n그게 마지막 말이 될까 봐… 쫓기는 내내 그게 제일 무서웠어요."},
	{"who": "허 의원", "pose": "heo", "text": "아니다. 미안한 건 나다.\n너를 지키려고 숨긴 것이, 오히려 너를 혼자 세상에 떠돌게 만들었구나."},
	{"who": "허 의원", "pose": "heo", "text": "그날 하지 못한 말을 이제 하마.\n…피는 섞이지 않았어도, 넌 나의 하나밖에 없는 소중한 딸이다."},
	{"who": "{name}", "pose": "hero_sad", "text": "…아버지.\n아버지… 아버지…!"},
	{"who": "{name}", "pose": "hero_sad", "text": "의원님… 의원님!"},
	{"who": "", "text": "보름 뒤, 매화 꽃잎이 떨어지던 새벽.\n허 의원은 {name}의 손을 잡은 채 조용히 눈을 감았다."},
	{"bg": "jangteo", "music": "sad_farewell", "who": "", "text": "장례 날. 북촌 어귀부터 운종가까지 사람들이 길게 늘어섰다."},
	{"who": "주막 주모", "pose": "jumo", "text": "약값 없는 우리 같은 사람들을 그리 살펴 주시던 분이…\n하늘도 무심하시지."},
	{"who": "물장수", "pose": "muljangsu", "text": "우리 아이 열병도 그 어른이 밤새 고쳐 주셨수.\n한양에 그런 의원이 또 어디 있겠소…"},
	{"who": "엿장수", "pose": "yeotjangsu", "text": "밤마다 날뛰던 검은 갓 사내 놈은 결국 못 잡았다지?\n그놈이 허 의원님을 해친 게 틀림없어!"},
	{"who": "{name}", "pose": "hero_sad", "text": "(아무도 몰라. 그 검은 사내가 의원님 마음 한구석이었다는 걸.\n…모르는 채로 두자. 사람들 기억 속 의원님은, 가난한 이의 의원님으로 남아야 해.)"},
	{"who": "윤도결", "pose": "jongsagwan", "text": "…포도청 문서에는 '검은 사내는 달아나 행방불명'이라고만 적겠다.\n그게 그 어른께 드릴 수 있는 내 마지막 예다."},
	{"who": "다래", "pose": "darae_court", "text": "{name}아, 울어도 돼. 오늘은 울어도 돼…"},
	{"who": "서휘", "pose": "seohwi", "text": "…의원. 나도 떠난다. 아버지의 나라, 바다 건너 화란(和蘭)으로.\n언젠가 세상 어디서든 다시 만나겠지."},
	{"who": "{name}", "pose": "hero_sad", "text": "서휘…! 벌써 가는 거야?\n…그동안 정말 고마웠어. 쫓기던 나를 몇 번이나 구해 주고, 하수오까지 캐다 주고."},
	{"who": "{name}", "pose": "hero_sad", "text": "솔직히… 많이 아쉬워. 이제 좀 친해졌다 싶었는데.\n인연이 닿는다면, 꼭 다시 만나자. 바다 건너 어디서든."},
	{"who": "서휘", "pose": "seohwi", "text": "…그래. 그 약속, 잊지 않겠다.\n(아쉬운 건 나도 마찬가지다. …바보 같은 의원.)"},
	{"bg": "palace", "music": "lonely_night", "who": "", "text": "{name|은} 슬픔을 삼키고 약을 달였다.\n한 해가 지나기 전, 청심보명단에 상한 사람들이 모두 제 정신을 되찾았다."},
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

# ── 제7장 만리길: 구간별 사건 ─────────────────────────
const C7_FERRY := [
	{"who": "", "bg": "ferry", "text": "의주, 압록강 나루.\n강 건너 안개 너머로 청나라 관문의 깃발이 펄럭였다."},
	{"who": "수문장", "pic": "sumunjang", "text": "멈춰라! 조선에서 넘어오는 자는 통행첩부터 내놔라."},
	{"who": "수문장", "pic": "sumunjang", "text": "흠… 의원이라? 사내치고는 목소리가 곱구나. 손도 희고.\n수상한데."},
	{"who": "{alias}", "pic": "hero_disguise_surprised", "text": "(들키면 안 돼…!)",
		"choices": [{"text": "침착하게 수문장의 맥을 짚어 보인다", "set": "c7_calm"}, {"text": "수문장의 배를 짚어 체증부터 풀어 준다", "set": ""}]},
	{"if": "c7_calm", "who": "수문장", "pic": "sumunjang", "text": "…손목만 잡고도 내가 밤마다 속이 쓰린 걸 맞히다니.\n진짜 의원이로군."},
	{"ifnot": "c7_calm", "who": "수문장", "pic": "sumunjang", "text": "오, 오오…! 사흘 묵은 체기가 쑥 내려가는군!\n진짜 의원이로군."},
	{"who": "수문장", "pic": "sumunjang", "text": "그런데 짐 속의 이 서찰은 뭐냐?\n…조선 포도대장의 인장이군. '이 자의 신분은 내가 보증한다. 윤도결.'"},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "(나리… 언제 이걸 짐 속에 넣어 두셨어요.)"},
	{"who": "수문장", "pic": "sumunjang", "text": "좋다, 건너가라. 연경까지 몸조심하고."},
	{"who": "", "text": "(수문장의 배웅: 엽전 +4냥)", "coin": 4},
]

const C7_YANJING_PRE := [
	{"who": "", "bg": "yanjing", "text": "청나라의 도읍 연경.\n약재 시장 거리는 처음 보는 약재로 가득했다."},
	{"who": "{alias}", "pic": "hero_disguise_surprised", "text": "녹용, 서양에서 온 쓴 나무껍질, 남방 열매까지…\n조선에선 이름도 못 들어 본 약재들이야."},
	{"who": "약재 상인", "pic": "cheong_merchant", "text": "어이, 조선 손님! 백 년 묵은 고려 인삼이오.\n특별히 반값에 드리지!"},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "…잠깐. 이건 도라지 뿌리에 인삼 껍질을 붙인 가짜잖아요.\n방금 저 할아버지한테도 이걸 비싸게 파셨죠?"},
	{"who": "약재 상인", "pic": "cheong_merchant", "text": "이, 이놈이 남의 장사를 망치려고!\n얘들아, 이 조선 놈 혼쭐을 내 줘라!"},
]

const C7_YANJING_POST := [
	{"who": "약재 상인", "pic": "cheong_merchant", "text": "아이고, 내가 졌소, 졌어!\n가짜 판 돈은 다 돌려드리리다…"},
	{"who": "노인", "text": "고맙소, 젊은 의원. 내 손주 약값이었다오."},
	{"who": "약재 상인", "pic": "cheong_merchant", "text": "…대신 하나 알려 드리지.\n남쪽 광주 항구에서 서양 배가 곧 떠난다오. 화란이라는 나라로 간다더군."},
	{"who": "", "text": "(노인의 사례: 엽전 +6냥)", "coin": 6},
]

const C7_PORT := [
	{"who": "", "bg": "port", "text": "광주 항구.\n돛대 셋 달린 화란 상선이 노을 속에 닻을 내리고 있었다."},
	{"who": "선장", "pic": "dutch_captain", "text": "배에 타고 싶다고? 우리 배엔 빈자리가 없네.\n…다만, 배 의사가 지난 항구에서 내려 버렸지."},
	{"who": "선장", "pic": "dutch_captain", "text": "마침 선원 하나가 사흘째 열병으로 앓고 있네.\n그 녀석을 고쳐 내면 선의(船醫)로 태워 주지."},
	{"who": "", "text": "{alias}는 선실로 내려가 맥을 짚고 시호와 황금을 달여 먹였다.\n이튿날 새벽, 선원의 열이 거짓말처럼 내렸다."},
	{"who": "붉은 머리 선원", "pic": "redhair_sailor", "text": "살았다! 고마워요, 동양 의원님!\n난 얀이에요. 이 배에서 제일 빠른 돛잡이죠!"},
	{"who": "선장", "pic": "dutch_captain", "text": "좋아, 약속은 약속이지.\n오늘부터 자네가 이 배의 선의일세."},
	{"who": "얀", "pic": "redhair_sailor", "text": "그런데 말이죠… 몇 해 전 우리 배에 금발에 동그란 안경 쓴 사내가 탔었어요.\n조선말을 하던데, 화란 바닷가 마을로 간다더라고요."},
	{"who": "{alias}", "pic": "hero_disguise_surprised", "text": "금발에… 동그란 애체…\n(서휘…? 정말 서휘야?)"},
	{"who": "", "text": "(선의 자리를 얻었다: 엽전 +5냥, 약병 +1)", "coin": 5, "potion": 1},
]

const C7_ISLAND := [
	{"who": "", "bg": "island", "text": "배가 물을 채우러 남쪽 섬 바타비아에 닿았다.\n숨이 막힐 듯 더운 한낮."},
	{"who": "섬마을 아이", "pic": "island_child", "text": "의원님…? 우리 동생이 며칠째 열이 나고 배가 아파요.\n아무도 못 고쳐요…"},
	{"who": "{alias}", "pic": "hero_disguise", "text": "가 보자.\n…더위를 먹은 데다 물이 나빠서 탈이 났구나.",
		"choices": [{"text": "아껴 둔 귀한 약을 아이에게 쓴다", "set": "c7_gave"}, {"text": "약초만 달여 주고 귀한 약은 아껴 둔다", "set": ""}]},
	{"if": "c7_gave", "who": "", "text": "{alias}는 품에 아껴 둔 약을 아이의 입에 흘려 넣었다.\n저녁 무렵, 아이가 눈을 뜨고 배시시 웃었다."},
	{"if": "c7_gave", "who": "섬마을 아이", "pic": "island_child", "text": "이거, 할머니가 준 행운의 부적이에요.\n의원님이 가져가요!"},
	{"if": "c7_gave", "who": "", "text": "(섬 아이의 부적: 최대 체력 +8)", "maxhp": 8},
	{"ifnot": "c7_gave", "who": "", "text": "밤새 달인 약초 물에 아이의 열이 천천히 내렸다.\n아이 어머니가 말린 열매를 한 바구니 내밀었다."},
	{"ifnot": "c7_gave", "who": "", "text": "(말린 열매: 체력 +10)", "heal": 10},
	{"who": "섬마을 아이", "pic": "island_child", "text": "고마워요, 의원님!\n…아, 저 배 선원들이 그러는데, 화란 바닷가 마을에 무서운 병이 돈대요."},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "(역병…? 서휘가 있는 곳일지도 몰라.\n서둘러야 해.)"},
]

const C7_PIRATE_PRE := [
	{"who": "", "bg": "deck", "text": "천축 앞바다를 지나던 밤.\n검은 돛을 단 배 한 척이 소리 없이 다가왔다."},
	{"who": "얀", "pic": "redhair_sailor", "text": "해적이다! 의원님, 선실로 숨어요!"},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "숨으면 다친 사람은 누가 고쳐요.\n…저도 싸울게요!"},
	{"who": "해적 두목", "pic": "pirate_captain", "text": "흐흐흐, 비단에 은화를 가득 실은 화란 배로구나.\n몽땅 내놓아라!"},
]

const C7_PIRATE_POST := [
	{"who": "", "bg": "deck", "text": "해적들은 바다로 뛰어들어 달아났다.\n{alias}는 갑판 위에서 다친 선원들의 상처를 꿰매고 피를 멎게 했다."},
	{"who": "선장", "pic": "dutch_captain", "text": "동양 의원이 싸움까지 할 줄이야.\n…선원들이 자넬 '우리 의원님'이라고 부르더군."},
	{"who": "얀", "pic": "redhair_sailor", "text": "의원님 없었으면 우리 다 죽었어요!"},
	{"who": "", "text": "(선원들의 믿음: 최대 체력 +5)", "maxhp": 5},
]

const C6_STORM := [
	{"who": "", "bg": "deck", "text": "희망의 곶을 도는 밤, 큰 폭풍이 배를 덮쳤다."},
	{"who": "", "text": "{alias}는 밤새 다친 선원들의 상처를 꿰매고 열을 내렸다.\n새벽, 선장이 모자를 벗어 고개를 숙였다."},
	{"who": "선장", "pic": "dutch_captain", "text": "조선의 젊은 의원이여, 그대 덕에 아무도 죽지 않았소.\n화란까지, 이 배가 모셔다 드리리다."},
	{"who": "", "text": "(선원들의 감사: 최대 체력 +5, 약병 +1)", "maxhp": 5, "potion": 1},
	{"who": "", "bg": "deck_night", "text": "폭풍이 지나간 밤.\n곶을 돌아 나온 검은 바다 위로 별이 쏟아졌다."},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "(의원님… 의원님이 그토록 보고 싶어 하던 넓은 세상이에요.)"},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "(다래는 지금쯤 산마루 약초밭에 물을 주고 있겠지.\n도결 나리는 오늘 밤도 순찰을 돌고 계시겠고.)"},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "(…그리고 서휘. 정말 이 바다 끝에 있을까.)"},
	{"who": "", "text": "고향 생각에 눈가가 뜨거워질 무렵,\n갑판 저편에서 서툰 조선말이 들려왔다."},
	{"who": "얀", "pic": "redhair_sailor", "text": "의—원—님! 밤바람 차요!\n따뜻한 차 끓여 놨어요!"},
	{"who": "{alias}", "pic": "hero_disguise", "text": "…응. 고마워요, 얀. 금방 갈게요."},
	{"who": "", "text": "(마음을 다잡았다: 체력 +10)", "heal": 10},
]

const CH6_END := [
	{"bg": "holland", "who": "", "text": "한편, 서쪽 끝 나라 화란.\n바닷가 작은 마을의 학교 창가에서, 금빛 머리의 선생이 저녁 바다를 바라보고 있었다."},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "(벌써 해가 몇 번이나 바뀌었군.\n…한양의 봄은 지금쯤 어떨까.)"},
	{"who": "", "text": "서휘는 품에서 낡은 무명천 조각을 꺼냈다.\n다리 밑 소굴에서, 찢어진 손등에 누군가 감아 주었던 바로 그 천이었다."},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "(아이들 상처를 싸맬 때마다 그 손이 떠오른다.\n고약을 바르며 '가만있어 봐요' 하던 목소리도.)"},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "(…어의가 되었으니 이제 궁 밖으로 나올 일도 없겠지.\n바보 같군. 다시 볼 수 없는 사람을 이렇게 그리워하다니.)"},
	{"who": "", "text": "그 무렵 마을엔 역병이 번지기 시작했고, 서휘는 매일 밤 앓는 아이들 곁을 지켰다.\n…바다 건너에서 한 척의 배가 다가오고 있다는 것도 모른 채."},
	{"bg": "holland", "who": "", "text": "며칠 뒤, 화란 바닷가의 작은 마을.\n풍차는 멈춰 있었고, 집집마다 문에 흰 십자가가 그려져 있었다."},
	{"who": "", "text": "역병이었다. 아이들부터 쓰러지고 있었다."},
	{"who": "???", "pic": "seohwi_dutch", "text": "…거기 서 있는 동양 청년, 혹시 길을 잃었소?\n이 마을엔 지금 들어오면 안 되오."},
	{"who": "", "text": "낯선 나라의 옷, 그러나 낯익은 금빛 머리칼과 동그란 애체."},
	{"who": "{alias}", "pic": "hero_disguise_surprised", "text": "…서휘?"},
	{"who": "", "text": "서휘의 손에서 약초 바구니가 툭 떨어졌다."},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "그 목소리…\n…아니야. 그럴 리가 없어. 내가 너무 보고 싶어서 헛것을 보는 거다."},
	{"who": "{alias}", "pic": "hero_disguise", "text": "헛것 아니에요. 패랭이 벗어 볼까요?\n…저예요, 서휘. {name}."},
	{"who": "", "text": "서휘는 성큼 다가와 {alias}의 두 어깨를 붙잡았다.\n떨리는 손끝이 그것이 꿈이 아님을 확인하듯 한참을 머물렀다."},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "정말… 정말 너로구나. 이 먼 바다를 건너서…\n하하, 믿을 수가 없군. 매일 밤 그 무명천을 꺼내 보면서 생각했는데."},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "…저도요. 배 위에서 푸른 눈 사내 얘기를 들은 날부터,\n하루도 빠짐없이 이 바다 끝을 생각했어요."},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "…반갑다는 말로는 모자라는군.\n하지만 미안하다. 지금은 너를 붙잡고 기뻐만 할 수가 없어."},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "나는 이 마을 학교에서 아이들을 가르치고 있다.\n그런데 내 아이들이 하나둘 죽어 가. 이 나라 의원들은 피를 뽑는 것밖에 모르고."},
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
	{"bg": "holland", "who": "", "text": "마을에 들어서자 집집마다 문간에 어른들이 쓰러져 있었다.\n아이들만이 아니었다. 역병은 마을 전체를 덮치고 있었다."},
	{"who": "앓는 어부", "pic": "dutch_sick_man", "text": "물… 물 좀…\n머리가… 깨질 것 같소…"},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "서휘, 끓인 물부터 나눠 줘요!\n열이 높은 사람은 그늘로 옮기고, 쓰던 물은 절대 마시지 말라고 해요."},
	{"who": "앓는 여인", "pic": "dutch_sick_woman", "text": "우리 아이… 우리 아이가 우물가에 갔어요…\n거긴 쥐가 들끓는 곳인데…"},
	{"who": "", "text": "마을 어귀, 우물가에서 아이의 비명이 들렸다."},
	{"who": "마을 아이", "pic": "dutch_child_sick", "text": "아파… 아파요… 큰 쥐가… 팔을 물었어요…"},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "역병을 옮기는 쥐다. 물린 자리부터 열이 오를 거다."},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "상처부터 소주로 씻고, 쑥을 짓이겨 붙여 줘요. 열 내리는 약은 제가 달일게요.\n괜찮아, 금방 나을 거야. 언니가 꼭 낫게 해 줄게."},
	{"who": "마을 아이", "pic": "dutch_child", "text": "…정말요? 고마워요, 동양 의원님."},
	{"who": "앓는 여인", "pic": "dutch_sick_woman", "text": "…우리 아이를 살려 주셨군요.\n이 몸도 성치 않은데… 이 은혜를 어떻게 갚아야 할지…"},
	{"who": "{alias}", "pic": "hero_disguise", "text": "어머니도 환자예요. 이 탕약 드시고 푹 주무세요.\n아이는 저희가 볼게요."},
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
	{"who": "", "text": "풍차 아래 언덕. 둘은 나란히 앉아 다시 도는 날개를 바라보았다."},
	{"who": "{name}", "pose": "hero_adult", "text": "있잖아요, 서휘. 한양에서 누명을 쓰고 쫓기던 때…\n세상에서 제일 불행한 아이가 나라고 생각했어요."},
	{"who": "{name}", "pose": "hero_adult", "text": "그런데 그 일이 없었으면 다래랑 길을 떠나지도, 다리 밑에서 당신을 만나지도 못했겠죠.\n…이제는 그때 일이 고마워요. 그 길 끝에 당신이 있었으니까."},
	{"who": "서휘", "pose": "seohwi_dutch", "text": "…나도 그렇다. 평생 이 푸른 눈을 원망하며 살았는데,\n이 눈 덕에 화란까지 와서… 너를 다시 만났지."},
	{"who": "서휘", "pose": "seohwi_dutch", "text": "불행이라 여긴 길이, 돌아보니 전부 너에게 오는 길이었군."},
	{"who": "서휘", "pose": "seohwi_dutch", "text": "{name}. 약속대로 제대로 말하겠다.\n…너와 함께 조선으로 돌아가고 싶다. 네 곁에 머물고 싶다."},
	{"who": "{name}", "pose": "hero_disguise", "text": "…응. 나도.", "end": true},
]

const EPILOGUE := [
	{"bg": "family", "who": "", "text": "남산 아래, 작은 한옥 한 채.\n대문 위에는 '허씨 약방'이라는 현판이 걸렸다."},
	{"who": "", "text": "마당엔 금빛 머리칼과 검은 머리칼의 아이들이 뛰어놀고,\n약방 안에선 오늘도 가난한 이에게 약값을 받지 않는다."},
	{"music": "darae_cheer", "who": "다래", "pose": "darae_adult", "text": "얘들아, 이모 왔다! 오늘은 도라지 캐러 가자!"},
	{"who": "윤도결", "pose": "jongsagwan", "text": "…아이들 눈이 꼭 제 아비를 닮았군. 웃는 얼굴은 어미를 닮았고.\n이 집 앞이 내 순찰 길이오. 무슨 일 있으면 부르시오."},
	{"who": "", "text": "해 질 녘, 마당에서 뛰놀던 딸아이가 대문 위 현판을 가리켰다."},
	{"who": "딸", "pose": "children", "text": "어머니, 저기 '허씨 약방'의 허씨는 누구예요?\n우리 집은 허씨가 아니잖아요."},
	{"who": "아들", "pose": "children", "text": "맞아! 아버지는 서씨고, 어머니는… 음, 어머니는 뭐더라?"},
	{"who": "{name}", "pose": "hero_adult", "text": "허 의원님은… 길가에 쓰러져 있던 일곱 살 어미를 업어 와서,\n딸처럼 보살피고 키워 주신 분이란다."},
	{"who": "{name}", "pose": "hero_adult", "text": "가난한 사람에게는 약값을 받지 않으셨고,\n한양 사람들 모두가 존경하던 훌륭한 의원님이셨지."},
	{"who": "딸", "pose": "children", "text": "그럼 어머니도 그분을 좋아했어요?"},
	{"who": "{name}", "pose": "hero_adult", "text": "…그럼. 세상 누구보다 존경했고,\n지금도 매일 그분이 그리워. 그래서 이 약방에 그분 이름을 걸어 둔 거란다."},
	{"who": "서휘", "pose": "seohwi", "text": "너희 어머니가 의원이 된 것도, 아버지가 어머니를 만난 것도…\n다 그 어른 덕분이란다. 그러니 우리 집 할아버지나 마찬가지지."},
	{"who": "아들", "pose": "children", "text": "그럼 허 할아버지한테 인사해야겠다!\n허 할아버지, 안녕하세요! 우리 잘 지내요!"},
	{"who": "", "text": "아이들의 맑은 목소리가 남산 위 노을 속으로 퍼져 나갔다."},
	{"who": "{name}", "pose": "hero_adult", "text": "의원님. 저, 잘 지내고 있어요.\n의원님이 주신 마음, 이렇게 계속 이어 가고 있어요."},
	{"who": "", "text": "― 한양 숨바꼭질 · 완(完) ―\n\n끝까지 함께해 주셔서 고맙습니다."},
]

# ── 장별 길 위 대화 ─────────────────────────────────────
# ── v1.1 추가 이야기 ──
const CH1_AFTER_SHADOW := [
	{"bg": "mountain", "who": "", "text": "그 순간 동녘 능선 위로 해가 솟았다.\n사내는 비명을 지르며 얼굴을 감싸 쥐었다."},
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
	{"who": "", "text": "삿갓이 반쯤 찢겨 나갔다.\n노인은 얼굴을 가린 채 골짜기 쪽으로 몸을 날렸다."},
	{"who": "{alias}", "pic": "hero_disguise_surprised", "text": "방금… 하얀 수염…\n그리고 웃을 때 부채처럼 접히던 그 눈가 주름…"},
	{"who": "서휘", "pic": "seohwi", "text": "쫓자. 놈의 소굴이 이 골짜기에 있다."},
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
	{"who": "{name}", "pose": "hero", "text": "…이제 조선에 내가 고칠 사람은 다 고쳤어.\n의원님이 보지 못한 넓은 세상을, 의원님 대신 보고 싶어."},
	{"who": "", "text": "경복궁 강녕전. {name|은} 임금 앞에 엎드렸다."},
	{"who": "임금", "pose": "king", "text": "세상을 보러 떠나겠다고? 아니 된다.\n그대는 이 나라의 어의다. 궁을 비우는 것을 허락할 수 없노라."},
	{"who": "{name}", "pose": "hero", "text": "전하…"},
	{"who": "", "text": "그때, 뒤에 서 있던 포도대장 윤도결이 무릎을 꿇었다."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "전하, 신 포도대장 윤도결 감히 아뢰옵니다.\n저 아이는 누명을 쓰고도 끝내 백성을 먼저 살핀 의원이옵니다."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "새장에 가두면 저 아이의 의술도 그 안에서 시들 것이옵니다.\n궁의 안위는 신이 목숨을 걸고 지키겠사오니, 부디 길을 열어 주시옵소서."},
	{"who": "임금", "pose": "king", "text": "…포도대장이 이토록 간곡히 청하는 것은 처음 보는구나.\n좋다. 다만 조건이 있다."},
	{"who": "임금", "pose": "king", "text": "궁에서 쓸 약을 넉넉히 지어 두고,\n그대의 의술을 이어받을 사람을 길러 놓고 떠나라."},
	{"who": "{name}", "pose": "hero", "text": "성은이 망극하옵니다, 전하!"},
	{"bg": "yakbang", "music": "yakbang_day", "who": "", "text": "그날부터 {name|은} 내의원 약방에서 밤낮으로 약을 빚었다.\n환심단, 우황청심환, 쌍화탕… 약장 서랍이 하나둘 가득 찼다."},
	{"who": "다래", "pose": "darae_court", "text": "{name}아, 그럼 네 의술을 이어받을 사람은… 설마 나?"},
	{"who": "{name}", "pose": "hero", "text": "응. 약초 보는 눈은 네가 조선 제일이잖아.\n이제 약 짓는 법까지 배우면, 너는 진짜 의녀가 되는 거야."},
	{"who": "다래", "pose": "darae_court", "text": "…해 볼게. 너 없는 동안 궁은 내가 지킬게!"},
	{"who": "{name}", "pose": "hero", "text": "그럼 첫 수업은 산에서 하자.\n약초는 책보다 산에서 배우는 거라고, 의원님이 그러셨거든."},
	{"who": "", "text": "【목표】\n다래와 함께 북한산에 올라 약초를 가르치며\n산마루 약초밭까지 가라."},
]

const C6F_LESSON := [
	{"bg": "stream", "who": "", "text": "산 중턱 계곡. 다래가 바위틈의 풀 한 포기를 가리켰다."},
	{"who": "다래", "pic": "friend", "text": "이건 내가 알아! 도라지야. 근데 이걸 어떻게 약으로 써?"},
	{"who": "{name}", "pic": "hero", "text": "뿌리를 캐서 껍질을 벗기고 볕에 말려.\n기침과 가래에 좋아. 감초를 조금 넣어 달이면 쓴맛도 덜하고."},
	{"who": "다래", "pic": "friend_worried", "text": "그럼 이건? 할아버지가 독초라고 절대 만지지 말랬던 거."},
	{"who": "{name}", "pic": "hero", "text": "미치광이풀. 할아버지가 나한테도 처음 가르쳐 주신 거야.\n…좋은 의원은 약보다 독을 먼저 알아보는 사람이래."},
	{"who": "다래", "pic": "friend_worried", "text": "…할아버지 생각난다. 그 가르침만큼은 진짜였을 거야."},
	{"who": "", "potion": 2, "text": "(다래가 캔 약초로 약을 달였다: 약병 +2)"},
]

const CH6F_END := [
	{"bg": "mountain", "who": "", "text": "산마루 양지바른 비탈. 둘은 해가 질 때까지 흙을 일구었다."},
	{"who": "{name}", "pose": "hero", "text": "약초는 해가 잘 드는 데 심고, 물은 흙이 마를 때만 줘.\n뿌리 약초는 삼 년은 기다려야 해. 조급하면 안 돼."},
	{"who": "다래", "pose": "friend", "text": "삼 년… 그럼 이 도라지가 다 자랄 때쯤엔 너도 돌아와 있겠다."},
	{"who": "{name}", "pose": "hero", "text": "응. 약속할게."},
	{"bg": "palace", "who": "", "text": "며칠 뒤, 경복궁 강녕전.\n{name|은} 다래와 나란히 임금 앞에 엎드렸다."},
	{"who": "{name}", "pose": "hero", "text": "전하, 분부하신 대로 궁에서 쓸 약을 넉넉히 지어 두었사옵니다.\n환심단의 처방, 약초 보는 법, 약 달이는 법까지… 제가 아는 모든 것을 다래에게 전하였사옵니다."},
	{"who": "다래", "pose": "darae_court", "text": "황공하옵니다, 전하.\n이제 궁 안 사람들의 약은 소녀가 책임지고 달이겠사옵니다."},
	{"who": "임금", "pose": "king", "text": "허허, 약속을 지켰구나.\n내의원 의관들도 다래의 솜씨를 칭찬하더구나. 더는 그대를 붙잡을 핑계가 없도다."},
	{"who": "임금", "pose": "king", "text": "어의 {name}. 세상을 보고 오너라.\n그리고 돌아와서, 그대가 본 넓은 세상의 의술로 이 나라 백성을 다시 고쳐 다오. 떠나는 것을 허락하노라."},
	{"who": "{name}", "pose": "hero", "text": "성은이 망극하옵니다, 전하.\n…반드시 돌아오겠사옵니다."},
	{"bg": "title", "who": "", "text": "떠나는 날 새벽, 숭례문 앞."},
	{"who": "다래", "pose": "darae_court", "text": "바보야, 꼭, 꼭 돌아와야 해. 안 오면 내가 찾으러 간다!"},
	{"who": "윤도결", "pose": "jongsagwan", "text": "먼 길에 여인 혼자는 위험하다. …또 사내아이 차림으로 가겠군.\n기다리고 있겠다. 네가 돌아올 때까지."},
	{"who": "", "pose": "hero_disguise", "text": "두 번째 남장. 그리고 이번에는, 세상 끝까지.\n{name|은} 다시 '{alias}'가 되어 한양을 떠났다."},
	{"who": "", "text": "― 제6장 「작별」 끝 ―"},
]

# ── 마지막 장 앞머리: 귀향 ─────────────────────────────
const C9_LEAVE := [
	{"bg": "holland", "who": "", "text": "― 마지막 장 「돌아오는 봄」 ―"},
	{"who": "", "text": "역병이 물러간 이듬해 봄.\n풍차 언덕의 튤립이 다 피었을 무렵, 둘은 떠날 채비를 마쳤다."},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "…아이들아, 오늘이 마지막 수업이다.\n아픈 사람을 보면 먼저 손을 씻고, 끓인 물을 먹여라. 그거면 반은 산다."},
	{"who": "마을 아이", "pic": "dutch_child", "text": "선생님, 진짜 가요?\n…동양 의원님이랑 꼭, 꼭 다시 와요. 약속!"},
	{"who": "", "text": "아이가 내민 것은 꽃밭에서 갓 꺾은 튤립 한 송이였다."},
	{"who": "{name}", "pic": "hero_disguise_sad", "text": "…응. 약속할게.\n이 꽃, 조선까지 잘 말려서 가져갈게."},
	{"who": "앓던 여인", "pic": "dutch_sick_woman", "text": "의원님 덕에 우리 아이도, 나도 살았어요.\n가는 길에 드시라고 빵을 좀 구웠어요."},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "(아버지의 나라. 평생 원망만 하던 곳.\n…나는 이제 떠도는 사람이 아니라, 머무는 사람이 되러 간다.)"},
	{"who": "", "text": "【목표】\n배웅 나온 마을 사람들 사이를 지나\n항구에 정박한 상선까지 가라."},
]

const C9_SHIP := [
	{"bg": "holland_port", "who": "", "text": "부두 끝, 돛 셋 달린 상선.\n갑판에서 낯익은 붉은 머리가 손을 흔들었다."},
	{"who": "얀", "pic": "redhair_sailor", "text": "의원님?! 의원님이다!\n선장님, 우리 의원님이 돌아가는 배를 타신대요!"},
	{"who": "선장", "pic": "dutch_captain", "text": "허허, 인연이란 질기구먼.\n갈 때도 우리 배, 올 때도 우리 배일세. 선의 자리는 늘 비워 두었지."},
	{"who": "얀", "pic": "redhair_sailor", "text": "그런데 옆에 이분… 금발에 동그란 안경…\n아! 그때 말한 그 조선말 하던 사내가 바로 당신이었구나!"},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "…몇 해 전 이 배에 탔었지. 그때 네가 돛대에서 떨어질 뻔한 것도 기억한다."},
	{"bg": "deck", "who": "", "text": "배가 항구를 벗어나 먼바다로 나선 날 저녁.\n{name}는 선실에서 패랭이를 벗고, 동여맨 머리를 풀었다."},
	{"who": "", "pic": "hero_adult_ribbon", "text": "긴 머리를 붉은 댕기로 묶고 갑판으로 나서자,\n바닷바람에 머리칼과 댕기가 함께 흩날렸다."},
	{"who": "{name}", "pic": "hero_adult_ribbon", "text": "…이제 숨을 일이 없으니까요.\n조선에는 {name}로 돌아가고 싶어서."},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "……"},
	{"who": "얀", "pic": "redhair_sailor", "text": "…선생님, 숨은 쉬셔야죠. 넋이 나가셨어요."},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "시, 시끄럽다. …바람이 차서 그런 거다."},
]

const C9_PIRATE_PRE := [
	{"bg": "deck", "who": "", "text": "희망의 곶을 앞둔 밤, 검은 돛을 단 배가 다시 나타났다."},
	{"who": "해적 두목", "pic": "pirate_captain", "text": "크하하! 몇 해 전 내 배를 망신 준 동양 의원 놈 아니냐!\n이번엔 갑판째로 바다에 처넣어 주마!"},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "…이 사람한테 손대는 순간, 네가 먼저 바다에 빠질 거다."},
	{"who": "{name}", "pic": "hero_adult_ribbon", "text": "이번엔 둘이에요. 덤벼요!"},
]

const C9_PIRATE_POST := [
	{"who": "해적 두목", "pic": "pirate_captain", "text": "크윽… 둘이 되니 더 독하구나…!\n후퇴다, 후퇴!"},
	{"who": "", "text": "해적선이 어둠 속으로 사라지고, 선원들의 환호가 갑판을 울렸다."},
]

## 폭풍 뒤 고백 → 돌아오는 길 회상 → 압록강 → 허 의원 묘 → 숭례문(CH9_INTRO 뒷부분)
const C9_HOMEWARD := [
	{"bg": "deck_night", "who": "", "text": "해적이 물러간 밤. 갑판 위로 별이 쏟아졌다."},
	{"music": "heart_flutter", "who": "서휘", "pose": "seohwi_dutch", "text": "…{name}. 이것 기억하나?"},
	{"who": "", "text": "서휘가 품에서 꺼낸 것은 낡은 무명천 조각이었다.\n다리 밑 소굴에서, {name}가 찢어진 서휘의 손등을 싸매 주었던 바로 그 천."},
	{"who": "서휘", "pose": "seohwi_dutch", "text": "화란에서 몇 해를 사는 동안, 한 번도 버리지 못했다.\n아이들 상처를 싸맬 때마다 네 손이 떠올라서."},
	{"who": "서휘", "pose": "seohwi_dutch", "text": "조선에 닿으면… 네 아버지 묘 앞에서 정식으로 청하겠다.\n평생 네 곁에 머물게 해 달라고."},
	{"who": "{name}", "pose": "hero_adult_ribbon", "text": "…바보. 그런 건 묘 앞에서 말고, 지금도 말해도 되잖아요."},
	{"who": "서휘", "pose": "seohwi_dutch", "text": "…그럼 지금 한 번, 그리고 묘 앞에서 한 번 더 하지."},
	{"bg": "island", "who": "", "text": "돌아오는 바닷길. 배는 갈 때 들렀던 항구들에 다시 닻을 내렸다."},
	{"who": "섬마을 아이", "pose": "island_child", "text": "의원님! 저 기억해요? 이제 동생도 저만큼 컸어요!\n의원님이 준 약 덕분이에요!"},
	{"bg": "yanjing", "who": "", "text": "연경 약재 시장에선, 가짜 인삼에 속을 뻔했던 노인의 손주가\n씩씩하게 약재를 나르고 있었다."},
	{"who": "{name}", "pose": "hero_adult_ribbon", "text": "(갈 때 뿌린 작은 인연들이…\n돌아오는 길엔 꽃이 되어 있었네.)"},
	{"bg": "ferry", "who": "", "text": "그리고 압록강 나루."},
	{"who": "수문장", "pose": "sumunjang", "text": "응? 이 얼굴… 그때 그 고운 목소리의 조선 의원!\n…허허, 이번엔 아가씨로구먼! 어쩐지 손이 희더라니."},
	{"who": "수문장", "pose": "sumunjang", "text": "그 포도대장 서찰, 아직 내 품에 있소.\n그리 귀한 보증은 처음이었거든. 어서 가시오, 고향이 기다리오."},
	{"bg": "grave", "who": "", "text": "한양에 들기 전, 둘은 먼저 도성 밖 산자락에 올랐다.\n매화 꽃잎이 흩날리는 작은 봉분. 허 의원의 묘였다."},
	{"who": "{name}", "pose": "hero_adult", "text": "아버지, 다녀왔어요.\n아버지가 보고 싶어 하던 넓은 세상, 끝까지 보고 왔어요."},
	{"who": "{name}", "pose": "hero_adult", "text": "화란에서 가져온 튤립이에요. 말려서 오느라 좀 바랬지만…\n아버지 약방 마당에도 심어 볼게요."},
	{"music": "heart_flutter", "who": "", "text": "서휘가 봉분 앞에 무릎을 꿇었다."},
	{"who": "서휘", "pose": "seohwi", "text": "허 의원 어른. 한때 당신의 딸에게 독을 빚게 한 못난 놈입니다.\n…그래도 감히 청합니다. 평생 이 사람 곁에서, 이 사람이 고치는 사람들을 함께 지키게 해 주십시오."},
	{"who": "", "text": "산들바람이 불어, 매화 꽃잎 하나가 서휘의 어깨에 내려앉았다."},
	{"who": "{name}", "pose": "hero_adult", "text": "…아버지가 허락하신 것 같아요.\n아버지는 늘, 대답 대신 꽃잎을 떨구셨거든요."},
]

## 돌아온 뒤: 임금 알현 → 다래의 장난 → 수표교에서 윤도결의 부탁 → 포도청 수련 맵
const C9_KING := [
	{"bg": "palace", "who": "", "text": "이튿날, 경복궁 강녕전.\n{name|은} 서휘와 나란히 임금 앞에 엎드렸다."},
	{"who": "임금", "pose": "king", "text": "허허, {name}! 먼 길 무사히 잘 돌아왔구나.\n그동안 참으로 수고 많았다."},
	{"who": "임금", "pose": "king", "text": "바다 건너 화란이라니… 그곳에서 무슨 일이 있었는지 궁금하구나.\n어디 하나도 빼놓지 말고 들려주거라."},
	{"who": "{name}", "pose": "hero_adult", "text": "예, 전하. 역병이 도는 화란의 마을에서 아픈 아이들을 돌보았사옵니다.\n끓인 물과 깨끗한 손으로 병을 막는 서양의 법도 배워 왔사옵니다."},
	{"who": "임금", "pose": "king", "text": "…그런데 그 곁의 금발 청년. 그대가 청안파의 그 서휘로구나."},
	{"who": "{name}", "pose": "hero_adult", "text": "예, 전하. 화란의 역병 마을에서 밤낮으로 아이들을 살린 사람이옵니다.\n이제는… 소녀와 평생을 함께할 사람이옵니다."},
	{"who": "서휘", "pose": "seohwi", "text": "한때 그릇된 길을 걸었던 몸이옵니다, 전하.\n남은 생은 이 나라 백성을 지키는 데 쓰겠사옵니다."},
	{"who": "임금", "pose": "king", "text": "그 말, 잊지 않겠노라. 두 사람 모두 이 나라의 보배로다.\n이제 편히 쉬며 한양의 봄을 누리거라."},
	{"who": "{name}", "pose": "hero_adult", "text": "전하의 깊은 배려에 감사드리옵니다.\n하오나 쉬기보다는, 이제부터 다시 궁에서 다래와 함께 내의원에 복귀하여\n전하와 백성을 살피겠사옵니다."},
	{"who": "임금", "pose": "king", "text": "허허, 역시 그대답구나. 내의원이 다시 든든해지겠어.\n좋다, 그리하거라."},
]

const C9_DARAE := [
	{"bg": "palace", "who": "", "text": "강녕전을 나서자, 의녀 차림의 다래가 달려와 {name}의 두 볼을 잡아당겼다."},
	{"music": "darae_cheer", "who": "다래", "pose": "darae_adult", "text": "야, 이 바보야! 너 없는 동안 이 다래님이 궁 안 약을 혼자 다 달였거든?\n고뿔에 체기에 대비마마 두통까지! 손목이 남아나질 않았어!"},
	{"who": "{name}", "pose": "hero_adult", "text": "아야야… 알았어, 알았어! 고생 많았어, 다래야."},
	{"who": "다래", "pose": "darae_adult", "text": "…사실은 많이 힘들었어. 밤에 혼자 약 달이다가,\n네가 있었으면 하고 몇 번이나 생각했는지 몰라."},
	{"who": "다래", "pose": "darae_adult", "text": "근데 이제 네가 와 줬으니까,\n둘이서 훨씬 더 많은 사람들을 낫게 해 줄 수 있겠다!"},
	{"who": "{name}", "pose": "hero_adult", "text": "응. 이번엔 혼자 두지 않을게. 같이 하자, 다래야."},
	{"who": "다래", "pose": "darae_adult", "text": "그리고 그쪽, 우리 {name} 데려간 그 푸른 눈.\n흠… 얼굴은 합격. 근데 이 애 울리면 고춧가루 뿌린다? 나 그거 잘하거든."},
	{"who": "서휘", "pose": "seohwi", "text": "…기억하고 있소. 첫날 포졸 눈에 그걸 뿌렸다던 이야기.\n울릴 일은 없을 거요."},
	{"who": "{name}", "pose": "hero_adult", "text": "다래야, 정말 고마워. 네가 궁을 지켜 줘서 마음 놓고 다녀올 수 있었어."},
	{"who": "다래", "pose": "darae_adult", "text": "…치. 그런 말 하면 울잖아, 바보야.\n…잘 왔어. 정말, 잘 돌아왔어."},
]

const C9_BRIDGE := [
	{"bg": "stream", "who": "", "text": "그날 밤, 청계천 수표교 위.\n순찰을 돌던 윤도결이 다리 끝에서 걸음을 멈췄다."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "{name}. 물에서 너를 건져 낸 그날부터, 네가 돌아오기를 매일 기다렸다.\n…답은 이미 알고 있었지만."},
	{"who": "{name}", "pose": "hero_adult", "text": "나리가 없었으면 저는 그 강에서 죽었을 거예요.\n그 은혜는 평생 잊지 않을게요."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "혼례 선물이다. 받아라."},
	{"who": "", "text": "윤도결이 내민 것은 누렇게 바랜 포도청 문서 한 장이었다.\n'약방의 수상한 계집아이가 돈궤를 털고 달아났다.' 그 새벽의 첫 보고서."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "이건 이제 필요 없다."},
	{"who": "", "text": "둘은 문서를 함께 찢어 강물에 띄워 보냈다.\n종잇조각이 달빛을 받으며 천천히 흘러갔다."},
	{"who": "", "text": "윤도결이 돌아서다 말고, 다리 아래에서 기다리던 서휘를 불렀다."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "서휘. 그 사람을 잘 부탁한다.\n내가 지켜 주고 싶었지만… 그 사람이 고른 건 너다."},
	{"who": "서휘", "pose": "seohwi", "text": "…목숨을 걸고 지키겠소. 나리가 지켜 온 만큼."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "그리고 하나 더. 청안파 아이들을 이끌던 그 솜씨, 이제 나라를 위해 써 보지 않겠나.\n포도청에 들어와라. 내가 직접 가르치겠다."},
	{"who": "서휘", "pose": "seohwi", "text": "한때 쫓기던 몸이 포졸이 된다라… 재밌군.\n받아들이지. 대신 봐주지는 마시오."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "봐줄 생각 없다. 내일 새벽, 포도청 마당으로 와라."},
	{"bg": "podocheong", "who": "", "text": "【목표】\n포도청에 들어간 서휘가 되어\n윤도결과 함께 한양 순찰을 돌고, 마지막 대련을 치러라."},
]

const C9_SPAR_PRE := [
	{"bg": "podocheong", "who": "", "text": "순찰을 마친 저녁, 포도청 마당.\n윤도결이 육모방망이를 들고 서 있었다."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "오늘 수련의 마지막이다. 나를 한 번이라도 쓰러뜨려 봐라."},
	{"who": "서휘", "pose": "seohwi_podo", "text": "…청안파 시절처럼 해도 되겠소?"},
	{"who": "윤도결", "pose": "jongsagwan", "text": "그래야 가르칠 맛이 나지."},
]

const C9_SPAR_POST := [
	{"who": "윤도결", "pose": "jongsagwan", "text": "…후. 이제 내가 가르칠 게 없군.\n내일부터 너는 포졸이 아니라 내 부장이다."},
	{"who": "서휘", "pose": "seohwi_podo", "text": "…고맙소, 스승님."},
	{"who": "윤도결", "pose": "jongsagwan_blush", "text": "스, 스승님은 무슨. …흠. 나쁘지 않군, 그 말."},
]

## 약방 다시 열기 → 혼례 → 추억 길
const C9_SHOP := [
	{"bg": "yakbang_calm", "who": "", "text": "낮에는 내의원, 해가 지면 북촌 어귀의 옛 약방.\n오래 비어 있던 허 의원의 약방에 다시 불이 켜졌다."},
	{"who": "", "text": "{name|은} 약장을 닦고, 당귀와 감초와 숙지황을 칸칸이 채웠다.\n열다섯 살 그날, 심부름으로 구해 왔던 바로 그 약재들이었다."},
	{"who": "다래", "pose": "darae_adult", "text": "궁 약재 남은 거 챙겨 왔어!\n이 약장 칸은 내가 채운다?"},
	{"who": "", "text": "서휘가 화란에서 가져온 가죽 왕진 가방을 약장 옆에 걸었다.\n조선의 약장과 화란의 가방이 나란히 놓였다."},
	{"who": "{name}", "pose": "hero_adult", "text": "가난한 이에게는 약값을 받지 않습니다.\n…아버지가 늘 하시던 말씀이에요. 이 약방도 그렇게 할 거예요."},
	{"who": "", "text": "첫 손님이 문을 두드렸다. 얼굴을 보자 {name|은} 숨을 삼켰다.\n청심보명단에 무너졌다가, 환심단으로 겨우 돌아왔던 그 사내였다."},
	{"who": "백성", "pose": "addict", "text": "의원님… 그때 의원님 약 덕분에 사람답게 살고 있습니다.\n약방을 다시 연다기에, 첫 손님이 되고 싶었어요."},
	{"who": "{name}", "pose": "hero_adult", "text": "(아버지. 약방, 다시 열었어요.\n이번엔… 약보다 독을 먼저 알아보는 의원이 될게요.)"},
]

const CH9_INTRO := [
	{"bg": "title", "who": "", "text": "― 마지막 장 「한양의 봄」 ―"},
	{"who": "", "text": "몇 해가 흘렀다.\n열다섯 살 소녀는 어느덧 단아한 아가씨가 되어 있었다."},
	{"who": "", "pose": "hero_adult", "text": "남장을 벗고, 다시 댕기를 맨 {name}.\n서휘와 함께 한양 숭례문을 들어섰다."},
	{"music": "darae_cheer", "who": "다래", "pose": "darae_adult", "text": "{name}아아아!!\n진짜… 진짜 너야? 바보, 편지라도 좀 하지! 보고 싶었단 말이야!"},
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
	{"bg": "mountain", "who": "", "text": "볕 잘 드는 빈터에서, 서휘와 {name|은} 손수 주춧돌을 놓았다."},
	{"bg": "podocheong", "who": "", "text": "그리고 몇 해가 흘렀다.\n서휘는 공을 쌓아 도성 서쪽을 맡는 우포도대장이 되었다.\n윤도결은 좌포도대장으로, 둘은 나란히 도성의 밤을 지켰다."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "오늘은 내 쪽에서 도적을 더 잡았다. 열둘이다."},
	{"who": "서휘", "pose": "seohwi_podo", "text": "숫자는 그쪽이 많지만, 거물은 내가 잡았지. 흑룡파 잔당 두목 하나."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "…그건 내가 몰아 준 거다."},
	{"who": "{name}", "pose": "hero_adult", "text": "두 대장 나리, 또 싸우세요?\n약방에서 도시락 싸 왔으니까, 싸우지 말고 드세요."},
	{"who": "윤도결", "pose": "jongsagwan_blush", "text": "…흠. 이 집 주먹밥은 여전히 맛있군."},
	{"who": "서휘", "pose": "seohwi_podo", "text": "남의 아내 도시락이오. 천천히 드시오."},
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

const C7_SICK := [
	{"bg": "holland", "who": "", "text": "마을 학교 교실은 앓는 아이들뿐 아니라 어른들로도 가득 찼다.\n{alias}와 서휘는 사흘 밤낮 탕약을 달여 날랐다."},
	{"who": "앓는 어부", "pic": "dutch_sick_man", "text": "동양 의원 양반… 당신 약 덕에 열이 내렸소.\n이제 내 발로 집에 갈 수 있겠어. 고맙소."},
	{"bg": "holland", "who": "", "text": "약초밭에서 돌아온 날 밤, 서휘가 쓰러졌다.\n아이들을 돌보던 사이 역병이 옮은 것이었다."},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "…괜찮다. 아이들부터… 살펴라."},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "바보! 지금은 당신이 환자예요. 의원 말 들어요."},
	{"who": "", "text": "{alias}는 언덕에서 캐 온 약초를 달여 밤새 서휘의 입술을 적셨다.\n젖은 수건을 갈고 식은땀을 닦으며, 거친 숨이 잦아들 때까지 손을 놓지 않았다."},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "…다리 밑 소굴에서도… 네가 이렇게 밤새 아이들 곁을 지켰지.\n이제야… 그 손이 얼마나 따뜻한지 알겠군."},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "말하지 말고 자요. 아침까지 여기 있을게요."},
	{"who": "", "text": "새벽녘, 열이 내렸다.\n눈을 뜬 서휘가 맞잡은 두 손을 내려다보고 희미하게 웃었다."},
	{"who": "서휘", "pic": "seohwi_dutch", "text": "…밤새 이 손을 놓지 않았군."},
	{"who": "{alias}", "pic": "hero_disguise", "text": "놓으면… 당신이 어디 가 버릴 것 같아서요."},
	{"who": "", "text": "그날 이후, 둘 사이엔 말하지 않아도 알 수 있는 무언가가 생겼다."},
]

const C4_CASTLE := [
	{"bg": "castle", "who": "", "text": "외나무다리를 건너 대숲을 빠져나오자, 화엄골 골짜기가 한눈에 들어왔다."},
	{"who": "", "text": "다래의 고향, 조용하던 산골 마을 위로—\n붉은 기와를 다섯 겹으로 올린 거대한 성이 우뚝 솟아 있었다."},
	{"who": "서휘", "pic": "seohwi", "text": "…장부에 적힌 은 수천 냥이 다 저기로 들어갔군.\n청심보명단으로 번 돈으로 제 성을 쌓다니."},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "마을 사람들 말로는 오 층 꼭대기에 '백 노인'이 산대요.\n…층마다 지키는 자들이 있다고."},
	{"who": "서휘", "pic": "seohwi", "text": "한 층씩 올라가자. 등은 내가 맡지."},
]

## 성문 앞: 서휘와의 세 번째 대결 (실력 시험)
const C4_GATE_PRE := [
	{"bg": "castle", "who": "", "text": "성문 앞 돌계단. 앞서 걷던 서휘가 갑자기 걸음을 멈추고 돌아섰다."},
	{"who": "서휘", "pic": "seohwi_battle", "text": "의원. 들어가기 전에 하나만 확인하자.\n대대장은 나보다 몇 배는 강하다. 그 밑의 놈들도 만만치 않고."},
	{"who": "서휘", "pic": "seohwi_battle", "text": "날 넘지 못하면 저 성에선 살아 나오지 못한다.\n…그러니 지금, 네 실력을 내 눈으로 보겠다."},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "…좋아요. 이번엔 봐주지 마요.\n나도 이제 다리 밑의 그 애가 아니니까."},
]

const C4_GATE_POST := [
	{"who": "서휘", "pic": "seohwi", "text": "…후. 마지막 한 수, 일부러 늦췄는데도 그걸 다 막아 내는군."},
	{"who": "서휘", "pic": "seohwi", "text": "됐다. 이 정도면 등을 맡길 수 있겠어.\n…아니, 이제는 내가 네 등을 맡기겠다."},
	{"who": "{alias}", "pic": "hero_disguise", "text": "서휘의 애체에 비친 햇빛, 진짜 눈부셨어요.\n…다음엔 그거 안 통할 거예요."},
	{"who": "서휘", "pic": "seohwi", "text": "흥. 기대하지."},
	{"who": "", "text": "【목표】\n백운의 성 다섯 층을 차례로 올라\n꼭대기 천수각에 닿아라."},
]

const C4_F1_PRE := [
	{"bg": "vault", "who": "", "text": "성 1층, 대문 안쪽 창고.\n철퇴를 든 거구가 길을 막아섰다."},
	{"who": "성 문지기", "pic": "gatekeeper", "text": "백 노인 어르신 성에 쥐새끼가 둘 들어왔구나.\n여기서 돌아가면 다리 하나는 남겨 주마."},
]

const C4_F1_POST := [
	{"who": "성 문지기", "pic": "gatekeeper", "text": "크윽… 위층 놈들은… 나보다 훨씬 독하다…"},
]

const C4_F1 := [
	{"bg": "vault", "who": "", "text": "1층 창고엔 은궤와 곡식 섬이 천장까지 쌓여 있었다."},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "이 곡식 자루… 열병 마을에서 빼앗아 간 거예요.\n'구휼미'라고 찍혀 있어요."},
	{"who": "서휘", "pic": "seohwi", "text": "굶는 사람들 입에서 빼앗은 쌀로 성을 쌓았군."},
	{"who": "", "potion": 1, "text": "(창고 구석에서 쓸 만한 약재를 챙겼다: 약병 +1)"},
]

const C4_F2_PRE := [
	{"bg": "corridor", "who": "", "text": "성 2층, 독안개가 깔린 긴 회랑.\n검은 용 문신의 사내가 쇠사슬을 끌며 나타났다."},
	{"who": "흑룡파 두목", "pic": "heukdu", "text": "기다렸다, 청안파. 골목에서 한 번, 소금 창고에서 한 번…\n세 번째는 없다. 백 노인 어르신이 네 목에 은 백 냥을 거셨거든."},
]

const C4_F2_POST := [
	{"who": "흑룡파 두목", "pic": "heukdu", "text": "…크흑. 세 번을 다 지다니…\n노인네 돈을 받은 게 잘못이었나…"},
]

const C4_F2 := [
	{"who": "서휘", "pic": "seohwi", "text": "아이들을 납치해 이 성으로 팔아넘긴 것도…\n다 저 노인의 돈이었단 말이군. 이제야 끝냈다."},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "서휘… 괜찮아요?"},
	{"who": "서휘", "pic": "seohwi", "text": "괜찮다. 오히려 속이 시원해.\n이제 누구를 쳐야 할지 분명해졌으니까."},
]

const C4_F3_PRE := [
	{"bg": "corridor", "who": "", "text": "성 3층, 쓴 약 냄새가 진동하는 공방.\n눈이 풀린 일꾼들이 비틀거리며 다가왔다."},
	{"who": "중독된 일꾼", "pic": "addict", "text": "약… 약을 더… 노인 어르신이… 일하면 약을 준다고…"},
]

const C4_F3_POST := [
	{"who": "", "text": "일꾼들이 하나둘 쓰러지듯 주저앉았다."},
]

const C4_F3 := [
	{"bg": "corridor", "who": "", "text": "공방 안쪽, 쇠사슬에 묶인 마을 사람들이 청심보명단을 빚고 있었다."},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "이 사람들, 다 화엄골 마을 사람들이에요…!\n약을 미끼로 붙잡아 두고 일을 시킨 거야."},
	{"who": "", "text": "{alias}는 사슬을 풀고, 가지고 있던 해독 약재로 사람들의 손목을 짚어 가며 약을 먹였다."},
	{"who": "마을 노인", "text": "고맙소, 젊은 의원…\n백 노인이 저리 변하기 전엔, 이 골짜기 사람들을 공짜로 고쳐 주던 분이었는데…"},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "(…약보다 독을 먼저 알아보라던 할아버지. 그 가르침은 진짜였는데…)"},
	{"who": "", "coin": 6, "potion": 1, "text": "(풀려난 사람들이 엽전과 약병을 건넸다)"},
]

const C4_F5_PRE := [
	{"bg": "cheonsugak", "who": "", "text": "성 5층, 천수각으로 오르는 마지막 계단참.\n삿갓 쓴 노인이 난간에 기대어 기다리고 있었다."},
	{"who": "삿갓 노인", "pic": "baegun_boss", "text": "세 번째로구나, 아이들아.\n허나 천수각 문턱은 한 발짝도 넘지 못한다."},
]

const C4_F5_POST := [
	{"who": "", "text": "노인은 비틀거리며 연막약을 터뜨리고, 천수각 안으로 몸을 숨겼다."},
	{"who": "", "text": "그때, 계단 아래에서 낯익은 발소리가 올라왔다."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "…역시 여기 있었군, {name}.\n화엄골 마을 사람들이 성으로 끌려간다는 소문을 듣고 쫓아왔다."},
	{"who": "{alias}", "pic": "hero_disguise_surprised", "text": "종사관 나리…!"},
	{"who": "윤도결", "pic": "jongsagwan", "text": "방금 그 삿갓 노인이 이 성의 주인인가."},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "네. 청심보명단도, 흑룡파도, 의원님 일도…\n전부 저 노인한테서 시작된 거예요."},
	{"who": "서휘", "pic": "seohwi", "text": "…청심보명단에 들어간 붉은 씨앗. 삿갓 쓴 대대장한테 받아서, 이 아이 손에 쥐여 준 게 나다.\n그 약을 먹은 사람들이 하나둘 이상해졌지."},
	{"who": "서휘", "pic": "seohwi", "text": "나도 한때는 저 노인 밑에 있었다. 그건 부정하지 않겠다.\n…하지만 이대로는 안 된다. 내 손으로 저 노인을 잡으러 가겠다."},
	{"who": "윤도결", "pic": "jongsagwan", "text": "알고 있었다. 네가 청안파 서휘라는 것쯤은.\n포도청 문서에 네 이름이 몇 번이나 올랐는지 아나?"},
	{"who": "서휘", "pic": "seohwi", "text": "…그런데 왜 잡지 않았지?"},
	{"who": "윤도결", "pic": "jongsagwan", "text": "잡을 놈은 따로 있으니까. 지금은 저 위에 있는 노인이다.\n…나도 같이 가겠다. 포졸들은 성 아래에 세워 두었다."},
	{"who": "{alias}", "pic": "hero_disguise", "text": "(서휘와 종사관 나리가… 한편이 되다니.)\n…가요. 셋이서 끝내요."},
]

const C4_F4 := [
	{"bg": "vault", "who": "", "text": "그때, 아래층 계단에서 다급한 발소리가 들렸다."},
	{"who": "다래", "pic": "friend_worried", "text": "{alias}! 여기 있었구나!\n마을 사람들이 그러는데 할아버지가 이 성에 붙잡혀 계신다고…"},
	{"who": "{alias}", "pic": "hero_disguise_surprised", "text": "다, 다래야…! 여긴 위험해. 아래에서 기다려."},
	{"who": "다래", "pic": "friend_worried", "text": "싫어! 할아버지를 구하러 온 거야. 나도 갈 거야!"},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "(…할아버지가 붙잡힌 게 아니라, 이 성의 주인이라고… 어떻게 말하지.)"},
	{"who": "서휘", "pic": "seohwi", "text": "…의원. 말하지 않으면 더 큰 상처가 된다."},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "…위에 올라가면, 다 보게 될 거예요."},
]

const C3_HK1_PRE := [
	{"bg": "alley", "who": "", "text": "골목 끝 우물가.\n흑룡파 왈패들이 우는 아이들을 새끼줄로 엮어 끌고 가고 있었다."},
	{"who": "아이", "text": "놔요! 엄마한테 갈 거야!"},
	{"who": "흑룡파 두목", "pic": "heukdu", "text": "시끄럽다. 너희 같은 다리 밑 떨거지는 일할 데가 따로 있어.\n…어이, 청안파 서휘. 오랜만이군."},
	{"who": "서휘", "pic": "seohwi", "text": "흑룡파 두목… 이번엔 아이들까지 끌고 가나."},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "그 아이들 당장 놔줘요!"},
]

const C3_HK1_POST := [
	{"who": "흑룡파 두목", "pic": "heukdu", "text": "쳇, 의원 나부랭이가 제법이군.\n오늘은 물러나 주지. 하지만 아이들은 또 데려간다. 값을 쳐주는 분이 계시거든."},
	{"who": "", "text": "두목은 쇠사슬을 거두고 골목 너머로 사라졌다.\n풀려난 아이들이 {alias}의 바짓가랑이에 매달려 울었다."},
	{"who": "{alias}", "pic": "hero_disguise_sad", "text": "(값을 쳐주는 분…? 아이들을 대체 어디로 데려가는 거지.)"},
	{"who": "서휘", "pic": "seohwi", "text": "…놓쳤군. 아쉽지만 오늘은 아이들을 지킨 걸로 됐다."},
	{"who": "서휘", "pic": "seohwi", "text": "저놈은 '값을 쳐주는 분'이 있다고 했지. 돈줄이 있는 한 반드시 다시 움직인다.\n서두르지 말자, 의원. 조금 더 기다리면서 놈의 소굴을 찾아보자."},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "…네. 다음엔 꼭 붙잡아요. 아이들이 또 끌려가기 전에."},
]

const C3_HK2_PRE := [
	{"bg": "den", "who": "", "text": "청계천 하류, 흑룡파가 숨어 지내는 낡은 소금 창고.\n안에서 아이들의 흐느낌이 새어 나왔다."},
	{"who": "흑룡파 두목", "pic": "heukdu", "text": "또 왔군, 청안파. 이번엔 놓치지 않는다.\n이 아이들은 오늘 밤 배에 실어 남쪽 골짜기로 보낼 물건이다."},
	{"who": "서휘", "pic": "seohwi", "text": "아이를 물건이라 부르는 놈은 용서 못 한다."},
]

const C3_HK2_POST := [
	{"who": "흑룡파 두목", "pic": "heukdu", "text": "크윽… 이번에도냐…!\n…두고 봐라. 백(白) 어르신 성에서 다시 만나면, 그땐 너희가 끝이다."},
	{"who": "", "text": "두목은 창고 뒷문으로 달아나 강물에 뛰어들었다."},
	{"who": "서휘", "pic": "seohwi", "text": "또 강으로 빠져나갔군. 질긴 놈이다.\n…하지만 이번엔 아이들을 전부 되찾았어. 그거면 충분해."},
	{"who": "서휘", "pic": "seohwi", "text": "'백 어르신의 성'이라… 놈은 결국 거기로 돌아갈 거다.\n지금 쫓아 봐야 놓칠 뿐이야. 때를 기다리며 그 성이 어디인지부터 알아내자."},
	{"who": "{alias}", "pic": "hero_disguise", "text": "…알겠어요. 그때가 오면, 이번엔 끝까지 가요."},
]

const C3_HK2 := [
	{"bg": "den", "who": "", "text": "창고 구석, 열 명 남짓한 아이들이 서로 끌어안고 떨고 있었다."},
	{"who": "", "text": "{alias}는 하나하나 손목을 짚고, 다친 아이에겐 고약을 발라 주었다."},
	{"who": "아이", "text": "형아… 저 아저씨들이 그랬어요. 산골 성에 가면 하루 종일 쓴 약을 빻아야 한다고…"},
	{"who": "서휘", "pic": "seohwi", "text": "…산골 성. 백 어르신. 아이들을 일꾼으로 팔아넘기는 거였군."},
	{"who": "{alias}", "pic": "hero_disguise_angry", "text": "(약을 빻는 성… 청심보명단을 만드는 곳일까?)"},
	{"who": "", "coin": 6, "potion": 1, "text": "(아이들의 부모가 고맙다며 엽전과 약병을 건넸다)"},
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
		{"who": "약재 상인", "pic": "yakjae", "text": "어의 나으리라니, 정말 대단해!\n환심단에 쓸 감초는 내가 제일 좋은 걸로 골라 뒀어.", "potion": 1},
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
	"C3_HK1_PRE": C3_HK1_PRE, "C3_HK1_POST": C3_HK1_POST, "C3_HK2_PRE": C3_HK2_PRE, "C3_HK2_POST": C3_HK2_POST, "C3_HK2": C3_HK2,
	"C4_CASTLE": C4_CASTLE, "C4_F1_PRE": C4_F1_PRE, "C4_F1_POST": C4_F1_POST, "C4_F1": C4_F1, "C4_F2_PRE": C4_F2_PRE, "C4_F2_POST": C4_F2_POST, "C4_F2": C4_F2, "C4_F3_PRE": C4_F3_PRE, "C4_F3_POST": C4_F3_POST, "C4_F3": C4_F3, "C4_F5_PRE": C4_F5_PRE, "C4_F5_POST": C4_F5_POST, "C4_F4": C4_F4,
	"C7_SICK": C7_SICK,
	"C3_HEUK": C3_HEUK,
	"CH1_AFTER_SHADOW": CH1_AFTER_SHADOW, "C2_DG_FIGHT": C2_DG_FIGHT, "C2_DG_FLEE": C2_DG_FLEE, "C3_DG_FIGHT": C3_DG_FIGHT, "C3_DG_AFTER": C3_DG_AFTER, "C3_SHADOW": C3_SHADOW, "C3_SHADOW_FLEE": C3_SHADOW_FLEE, "C4_MASK1": C4_MASK1, "C4_MASK1_FLEE": C4_MASK1_FLEE, "C4_MASK2": C4_MASK2, "C4_MASK2_FLEE": C4_MASK2_FLEE, "C5_SHADOW": C5_SHADOW, "C5_SHADOW_FLEE": C5_SHADOW_FLEE, "CH6F_INTRO": CH6F_INTRO, "C6F_LESSON": C6F_LESSON, "CH6F_END": CH6F_END, "C9_LEAVE": C9_LEAVE, "C9_SHIP": C9_SHIP, "C9_PIRATE_PRE": C9_PIRATE_PRE, "C9_PIRATE_POST": C9_PIRATE_POST, "C9_SPAR_PRE": C9_SPAR_PRE, "C4_GATE_PRE": C4_GATE_PRE, "C4_GATE_POST": C4_GATE_POST, "C9_SPAR_POST": C9_SPAR_POST, "CH9_INTRO": CH9_INTRO, "C9_MEM": C9_MEM, "CH9_END": CH9_END, "C10_CLUE": C10_CLUE, "C10_JEONG_PRE": C10_JEONG_PRE, "C10_JEONG_POST": C10_JEONG_POST,
	"CH2_INTRO": CH2_INTRO, "C2_DOGYEOL": C2_DOGYEOL, "C4_PLAGUE": C4_PLAGUE, "CH2_GOAL": CH2_GOAL, "CH2_END": CH2_END,
	"CH3_INTRO": CH3_INTRO, "C3_DOGYEOL": C3_DOGYEOL, "C3_TRUTH": C3_TRUTH, "C3_BREW": C3_BREW, "C3_BOSS": C3_BOSS, "C3_BOSS_WIN": C3_BOSS_WIN, "CH3_END": CH3_END,
	"CH4_INTRO": CH4_INTRO, "C4_STREAM": C4_STREAM, "C4_CLUE": C4_CLUE, "CH4_GOAL": CH4_GOAL, "CH4_END": CH4_END, "CH4_AFTER_DUEL": CH4_AFTER_DUEL,
	"CH5_INTRO": CH5_INTRO, "C5_HEAL": C5_HEAL, "C5_SEOHWI": C5_SEOHWI,
	"CH6_INTRO": CH6_INTRO, "C6_PORT": C6_PORT, "C6_STORM": C6_STORM, "C7_FERRY": C7_FERRY, "C7_YANJING_PRE": C7_YANJING_PRE, "C7_YANJING_POST": C7_YANJING_POST, "C7_PORT": C7_PORT, "C7_ISLAND": C7_ISLAND, "C7_PIRATE_PRE": C7_PIRATE_PRE, "C7_PIRATE_POST": C7_PIRATE_POST, "CH6_END": CH6_END,
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
## 함께 다니는 동료의 한마디 (전투에는 끼어들지 않고 대화로만 함께한다)
const COMPANION := {
	"seohwi": {"name": "서휘", "pic": "seohwi",
		"start": ["길 잃지 말고 따라와라.", "이 길은 처음이군. …내 옆에서 떨어지지 마라.", "천천히 가도 된다. 대신 두리번거리진 말고."],
		"pre_me": ["이 녀석은 내가 처리할게. 서휘, 뒤에서 다른 패거리가 오는지 봐 줘.", "앞은 내가 맡을게요. 서휘는 뒤를 부탁해요!", "내가 상대할게. 혹시 숨어 있는 놈 있으면 알려 줘요."],
		"pre": ["…알았다. 뒤는 내가 막는다. 등 돌리지 말고 앞만 봐라.", "맡겨라. 한 놈도 네 등 뒤로 못 간다.", "좋다. 뒤쪽 골목은 내가 지킨다."],
		"post": ["뒤쪽에 두 놈이 더 있었는데, 내가 쫓아 보냈다. …잘 싸웠다.", "제법이군. 숨어 있던 놈 하나는 내가 묶어 뒀다.", "다친 데는 없나? …없으면 됐다."],
		"herb": ["좋은 약초군. 잘 챙겨 둬라.", "그건 비싸게 팔리는 거다. …아니, 네 약방에 쓰겠지."],
		"trap": ["조심해라!", "…발밑을 봐라, 의원."]},
	"dogyeol": {"name": "윤도결", "pic": "jongsagwan",
		"start": ["내 곁에서 떨어지지 마라.", "이 근방은 수상한 놈들이 많다. 조심해라."],
		"pre_me": ["나리, 여긴 제가 맡을게요. 나리는 골목 입구를 지켜 주세요.", "제가 상대할게요. 놈들 패거리가 더 숨어 있을지 몰라요, 나리!"],
		"pre": ["…좋다. 한 놈도 네 뒤로 보내지 않겠다.", "알겠다. 입구는 내가 막는다."],
		"post": ["골목 끝에 숨어 있던 놈은 내가 묶어 뒀다. 제법이군.", "…다치진 않았나. 다행이다."],
		"herb": ["약초인가. 넌 그런 걸 잘도 찾는군."],
		"trap": ["조심해라!"]},
	"darae": {"name": "다래", "pic": "friend",
		"start": ["오늘은 어떤 약초 캘까?", "같이 가니까 하나도 안 무섭다!"],
		"pre_me": ["다래야, 저 사람은 내가 상대할게. 넌 바구니 지키면서 주변 좀 살펴 줘.", "내가 막을게! 다래는 뒤에 수상한 사람 없나 봐 줘."],
		"pre": ["응! 수상한 사람 오면 바로 고춧가루 뿌릴게!", "알았어! 바구니는 내가 꼭 지킬게!"],
		"post": ["저쪽에서 누가 엿보길래 내가 소리 질렀더니 도망갔어! 우리 둘 다 잘했지?", "괜찮아? 안 다쳤어? …휴, 다행이다."],
		"herb": ["와, 그거 좋은 거야!", "그 약초, 할아버지가 귀하다고 했던 거다!"],
		"trap": ["조심해!", "어머, 괜찮아?!"]},
}

const ALLIES := {
	"seohwi": {"name": "서휘", "dmg": 7, "line": "서휘의 일격!"},
	"dogyeol": {"name": "윤도결", "dmg": 6, "block": 4, "line": "윤도결이 막아선다!"},
	"darae": {"name": "다래", "dmg": 4, "block": 3, "line": "다래의 고춧가루 공격!"},
}

## 아직 그림이 없어 도트로 대신하는 인물 (진짜 그림이 오면 여기서 지운다)
const PLACEHOLDERS := []

# ── 두 번째 밤: 허 의원의 편지 · 유배 섬 · 대비마마 · 정 의관 ─────────────
const C10_LETTER := [
	{"bg": "yakbang_calm", "music": "lonely_night", "who": "", "text": "며칠 뒤, 문을 닫은 밤의 약방.\n{name|은} 맨 아래 약장 서랍을 닦다가 손을 멈췄다. 서랍 바닥이 이중으로 되어 있었다."},
	{"who": "", "text": "숨은 칸 안에는 누렇게 바랜 편지 한 통과 작은 놋쇠 열쇠가 들어 있었다.\n겉봉에는 낯익은 붓글씨. ― '내 딸에게.'"},
	{"who": "{name}", "pose": "hero_adult", "text": "…의원님 글씨야."},
	{"who": "허 의원", "pose": "heo", "text": "(편지) {name}아. 네가 이 글을 읽는다면, 나는 끝내 너에게 직접 말하지 못한 것이겠지.\n그날 내가 삼킨 말부터 적으마."},
	{"bg": "flash_plague", "who": "", "text": "(편지) 네 부모는 내 동문이었다. 역병이 번진 마을에 누구도 들어가지 않을 때,\n둘은 약 보따리를 지고 제 발로 그 마을에 들어갔다."},
	{"who": "", "text": "(편지) 나도 따라가겠다 해 놓고, 두려워서 하루를 미뤘다.\n그 하루 사이에 두 사람은 쓰러졌고, 나는 마을 어귀에서 약 바구니를 든 너만 찾아냈다."},
	{"bg": "flash_carried", "who": "", "text": "(편지) 눈 오는 길을 너를 업고 걸으며 맹세했다.\n이 아이만큼은 지키겠다고. 그리고 다시는 두려움 따위에 지지 않겠다고."},
	{"who": "", "text": "(편지) 흑심단은 거기서 시작되었다. 친구를 버린 내 안의 두려움과 미움을 떼어 내고 싶었다.\n…떼어 낸 검은 것이 결국 나를 삼킬 줄도 모르고."},
	{"bg": "yakbang_calm", "music": "lonely_night", "who": "", "text": "(편지) 지하 책장에 해독의 실마리를 적어 두었으나, 마지막 한 가지를 끝내 찾지 못했다.\n백운 스승님만이 아실 게다. 이 열쇠는 스승님의 약궤 열쇠다."},
	{"who": "허 의원", "pose": "heo_smile", "text": "(편지) 길에서 거둔 아이라 한 말, 평생 후회했다.\n너는 내 친구의 딸이고… 내 딸이다. 미안하다. 그리고 고맙다."},
	{"who": "{name}", "pose": "hero_adult", "text": "…아버지.\n저도 이제 알아요. 화란에서 아이들을 살린 거… 어머니 아버지가 못다 한 일을 제가 이어 간 거였네요."},
	{"who": "", "text": "그때 약방 문이 벌컥 열렸다. 등불을 든 다래였다."},
	{"music": "darae_cheer", "who": "다래", "pose": "darae_adult", "text": "{name}아, 아직 안 잤…\n…너 울었어? 무슨 일이야?"},
	{"who": "", "text": "{name|은} 편지를 보여 주었다. 다래는 '백운'이라는 이름에서 한참 눈을 떼지 못했다."},
	{"who": "다래", "pose": "darae_adult", "text": "…할아버지, 남쪽 섬에 유배 가신 지 삼 년째야.\n나… 한 번도 못 갔어. 무서워서. 미워서."},
	{"who": "다래", "pose": "darae_adult", "text": "{name}아. …같이 가 줄래?"},
	{"who": "{name}", "pose": "hero_adult", "text": "당연하지. 이번엔 혼자 두지 않는다고 했잖아."},
	{"who": "", "text": "【목표】\n다래, 서휘와 함께 남쪽 바다를 건너\n백운이 유배된 섬의 초가까지 가라."},
]

const C10_EXILE := [
	{"bg": "exile_hut", "music": "lonely_night", "who": "", "text": "바닷가 언덕 위, 낡은 초가 한 채.\n싸리 울타리 안 작은 약초밭에서, 백발의 노인이 허리를 굽히고 있었다."},
	{"who": "백운", "pose": "baegun_exile", "text": "…다래냐.\n허허… 꿈인 줄 알았구나. 이 늙은이를 보러 올 줄은."},
	{"who": "다래", "pose": "darae_adult_cry", "text": "보러 온 거 아니야!\n할아버지 때문에… 할아버지가 판 약 때문에 사람들이 죽었어! 미쳐 갔다고!"},
	{"who": "다래", "pose": "darae_adult_cry", "text": "나는 그 사람들 약을 달이면서 매일 생각했어. 이건 우리 할아버지가 한 짓이다…\n…근데 왜, 왜 아직도 할아버지가 보고 싶은 건데!"},
	{"who": "백운", "pose": "baegun_exile", "text": "……."},
	{"who": "백운", "pose": "baegun_exile", "text": "변명은 않으마. 나는 셈을 했고, 그 셈 끝에 사람이 있다는 걸 잊었다.\n여기서 삼 년, 매일 그 얼굴들을 셌다."},
	{"who": "{name}", "pose": "hero_adult", "text": "선생님. 허 의원님의 편지를 가져왔어요.\n흑심단을 되돌릴 마지막 한 가지를 선생님만 아신다고."},
	{"who": "", "text": "{name|이} 놋쇠 열쇠를 내밀자, 백운의 손이 떨렸다.\n그는 방구석의 낡은 약궤를 열고, 얇은 서책 한 권을 꺼냈다."},
	{"who": "백운", "pose": "baegun_exile_cry", "text": "…허가 놈. 끝까지 나를 스승이라 부르는구나.\n이것이 환심단의 마지막 장이다. 내가 숨긴 채 썩히려 했던 것."},
	{"who": "백운", "pose": "baegun_exile_cry", "text": "다래야. 이것만은 네 손으로 받아 다오.\n내가 망친 것을 되돌리는 일에… 내 손녀의 손이 닿았으면 한다."},
	{"who": "다래", "pose": "darae_adult_cry", "text": "…바보 할아버지.\n이거 받는다고 용서하는 거 아니야. …내년에도, 그다음 해에도 와서 계속 혼낼 거야."},
	{"who": "백운", "pose": "baegun_exile_cry", "text": "허허… 그래. 그래 다오. 매해 혼나러, 이 늙은이가 살아 있으마."},
	{"bg": "island_grave", "music": "sad_farewell", "who": "", "text": "섬을 떠나기 전날. 서휘는 동백이 핀 언덕을 홀로 올랐다.\n이름 없는 돌 비석 하나가 바다를 보고 서 있었다."},
	{"who": "서휘", "pose": "seohwi", "text": "…백운 노인이 알려 주더군. 이 섬에 오래전 푸른 눈의 표류 선원이 살았다고.\n그 선원과 살다 아이를 낳은 섬 여인이, 여기 묻혔다고."},
	{"bg": "flash_seohwi_parents", "who": "", "text": "금발의 선원과 흰 치마저고리의 여인이 갓난아기를 안고 바다를 보던 집.\n아버지는 고향 배가 오자 아이만 데리고 떠났고, 어머니는 끝내 따라가지 못했다."},
	{"bg": "island_grave", "who": "서휘", "pose": "seohwi", "text": "어머니. 평생 이 눈을 원망했습니다. 조선에선 오랑캐, 화란에선 동양 놈.\n…그런데 이 눈 덕에, 이 사람을 만났습니다."},
	{"who": "{name}", "pose": "hero_adult", "text": "어머님, 처음 뵙겠습니다.\n서휘는… 제가 평생 곁에서 지킬게요. 그러니 이제 걱정 마세요."},
	{"who": "서휘", "pose": "seohwi", "text": "…이제야 알겠군. 나는 떠도는 사람이 아니었다.\n돌아올 곳이 처음부터 여기 있었던 거다."},
]

const C10_FALL := [
	{"bg": "daebi_room", "music": "dread_shadow", "who": "", "text": "섬에서 돌아온 이튿날 새벽. 대비전에 곡소리 같은 비명이 울렸다.\n대비마마가 탕약을 드신 뒤 쓰러지셨다는 것이었다."},
	{"who": "대비", "pose": "daebi_ill", "text": "…머리가… 머리 속에서 검은 것이 들끓는구나…"},
	{"who": "", "text": "{name|은} 약사발 바닥에 남은 찌꺼기를 혀끝에 대 보았다.\n달콤한 감초 맛 뒤로… 비린 쇠 냄새. 잊을 수 없는 그 냄새였다."},
	{"who": "{name}", "pose": "hero_adult", "text": "(흑심단…! 아버지와 함께 사라진 줄 알았는데…)"},
	{"who": "정 의관", "pose": "jeong_uigwan", "text": "어의 영감, 송구하오나 이 탕약을 달인 자는 의녀 다래입니다.\n게다가 다래는 바로 어제, 청심보명단을 팔던 역적 백운을 만나고 왔다지요?"},
	{"who": "다래", "pose": "darae_adult_cry", "text": "아니야! 내가 그런 거 아니야!\n대비마마 약은 내가 밤새 지켜보며 달였어! 누가… 누가 넣은 거야!"},
	{"who": "정 의관", "pose": "jeong_uigwan", "text": "역적의 손녀가 역적의 약을 넣었다. 이보다 분명한 일이 어디 있겠습니까.\n의금부는 무엇을 하는가! 당장 끌어내라!"},
	{"who": "", "text": "그때, 문 앞을 막아선 사람이 있었다. 포도대장 윤도결이었다."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "멈춰라. 증거는 약사발 하나와, 할아버지가 누구냐는 것뿐인가."},
	{"bg": "flash_dogyeol", "music": "lonely_night", "who": "", "text": "열 살 무렵, 윤도결은 골목 끝에서 그 광경을 보았다.\n증거라곤 '그 집 사람이니까'뿐이었던 날, 아버지는 포승줄에 묶여 끌려갔고 다시 돌아오지 못했다."},
	{"who": "", "text": "그날 소년은 맹세했다. 다시는 억울한 사람이 없게 하겠다고.\n…그러나 십수 년 뒤, 그는 빈 돈궤와 핏자국만 보고 열다섯 살 소녀를 쫓았다."},
	{"bg": "daebi_room", "music": "dread_shadow", "who": "윤도결", "pose": "jongsagwan", "text": "…{name}. 3년 전, 나는 빈 돈궤와 핏자국만 보고 너를 쫓았다.\n우리 아버지를 끌고 간 그 포졸들과 똑같이."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "네 누명이 벗겨지던 날 알았다. 내가 가장 미워하던 자가 바로 나였다는 걸.\n같은 잘못은 두 번 하지 않는다."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "다래는 의금부에 두되, 아무도 손대지 못하게 하겠다.\n그리고 증거가 말할 때까지, 이 사건은 포도청이 맡는다."},
	{"who": "{name}", "pose": "hero_adult", "text": "…나리."},
	{"bg": "uigeumbu", "music": "lonely_night", "who": "", "text": "그날 밤, 의금부 옥사. 달빛이 창살 사이로 가늘게 떨어졌다."},
	{"who": "다래", "pose": "darae_prison", "text": "{name}아… 나 정말 아니야.\n할아버지 일 때문에 다들 날 그렇게 볼 거라는 거, 알고 있었어. 그래도…"},
	{"who": "{name}", "pose": "hero_adult", "text": "알아. 나도 똑같이 쫓겨 봤잖아.\n그때 네가 고춧가루 한 줌으로 날 구해 줬지. 이번엔 내 차례야."},
	{"who": "다래", "pose": "darae_prison", "text": "…바보. 빨리 와. 여기 밥 진짜 맛없단 말이야."},
	{"bg": "podocheong", "who": "서휘", "pose": "seohwi_podo", "text": "포도청 부장 서휘, 지금부터 수사에 나서겠소.\n대비전 탕약이 지나간 곳은 단 하나, 내의원 약재 창고요."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "밤에 몰래 들어가 뒤져라. 낮엔 누가 지켜볼지 모른다.\n…정 의관, 그자가 오늘 유난히 서둘렀다."},
	{"who": "", "text": "【목표】\n서휘와 함께 밤의 궁궐에 숨어들어\n내의원 약재 창고에서 흑심단의 단서를 찾아라."},
]

const C10_CLUE := [
	{"bg": "naeuiwon", "music": "dread_shadow", "who": "", "text": "내의원 약재 창고. 등잔 하나만 깜박이는 어둠 속, 수백 칸 약장이 벽을 메우고 있었다."},
	{"who": "서휘", "pose": "seohwi_podo", "text": "…여기. 정 의관 이름이 붙은 서랍만 자물쇠가 새것이군."},
	{"who": "", "text": "서랍 안에는 검은 환약이 든 작은 병과, 장부 한 권이 있었다.\n장부 맨 앞장에 붙은 것은… 낯익은 필체의 찢어진 책장들."},
	{"who": "{name}", "pose": "hero_adult", "text": "아버지 책장이야…! 약방 지하에서 통째로 뜯겨 나갔던 흑심단 처방!\n이게 왜 정 의관한테…"},
	{"who": "서휘", "pose": "seohwi_podo", "text": "장부를 보시오. '마포 나루, 청 상인 창고에서 책장 값 은 백 냥'.\n대대장이 몰래 빼돌린 걸 청 상인이 쥐고 있다가, 이자에게 판 거요."},
	{"who": "서휘", "pose": "seohwi_podo", "text": "그리고 마지막 줄… '보름날 밤, 남은 흑심단 전부를 마포에서 받는다.'\n오늘이 보름이오."},
	{"who": "{name}", "pose": "hero_adult", "text": "가요, 마포로. 아버지가 만든 검은 것은… 제 손으로 끝낼 거예요."},
	{"who": "", "text": "【목표】\n마포 나루의 청 상인 창고로 가서\n흑심단 거래를 막아라."},
]

const C10_JEONG_PRE := [
	{"bg": "mapo_warehouse", "music": "dread_shadow", "who": "", "text": "청나라 글씨가 적힌 궤짝이 쌓인 창고 안쪽.\n정 의관이 검은 환약 병을 등불에 비춰 보고 있었다."},
	{"who": "정 의관", "pose": "jeong_uigwan", "text": "…어의 영감께서 이 누추한 곳까지. 역시 눈이 밝으시군요."},
	{"who": "{name}", "pose": "hero_adult", "text": "왜 그랬어요. 대비마마께, 그리고 다래에게."},
	{"who": "정 의관", "pose": "jeong_uigwan_angry", "text": "왜냐고? 나는 서른 해를 내의원에서 약을 달였다! 그런데 어의 자리는\n왈패 소굴에서 굴러먹던 약방 계집아이에게 돌아갔지!"},
	{"who": "정 의관", "pose": "jeong_uigwan_angry", "text": "대비마마가 쓰러지고, 역적의 손녀가 죄를 쓰고, 어의는 그 동무라 함께 물러난다.\n그다음 어의 자리는 누구 것이겠느냐!"},
	{"who": "정 의관", "pose": "jeong_uigwan_angry", "text": "그리고 이 약… 허 의원의 흑심단. 미움을 떼어 내 힘으로 바꾸는 약이라지.\n이제 내게는 미움이 넘쳐흐른다!"},
	{"who": "", "text": "정 의관이 검은 환약을 한 움큼 삼켰다.\n관복이 먹물처럼 검게 물들고, 두 눈이 붉게 번뜩였다."},
	{"who": "정 의관", "pose": "jeong_shadow", "text": "흐흐흐… 냄새가 나는구나. 허가 놈의 딸.\n네 아비가 남긴 밤을, 내가 이어 주마!"},
	{"who": "{name}", "pose": "hero_adult", "text": "(그 웃음… 그날 밤 약방의 검은 사내와 똑같아.)\n서휘, 등을 맡길게요. 이번엔… 사람을 되돌리는 싸움이에요."},
]

const C10_JEONG_POST := [
	{"bg": "mapo_warehouse", "music": "sad_farewell", "who": "정 의관", "pose": "jeong_shadow", "text": "크으윽…! 안 돼… 이 힘이… 빠져나간다…"},
	{"who": "", "text": "{name|은} 품에서 환약 한 알을 꺼냈다.\n허 의원의 마지막 연구와, 백운이 다래에게 건넨 마지막 장을 합쳐 빚은 약 ― 환심단이었다."},
	{"who": "{name}", "pose": "hero_adult", "text": "떼어 낸 검은 것은 사라지지 않아요. 더 큰 미움이 되어 돌아올 뿐.\n그러니까… 돌려놓는 거예요. 원래 있던 자리로."},
	{"who": "", "text": "검은 연기가 걷히자, 바닥에 주저앉은 것은 지친 늙은 의관 하나였다."},
	{"who": "정 의관", "pose": "jeong_uigwan", "text": "…서른 해. 나도 처음엔… 아픈 사람을 살리고 싶어서 의관이 되었는데.\n언제부터 자리만 보였을까."},
	{"who": "윤도결", "pose": "jongsagwan", "text": "장부, 책장, 흑심단 병, 그리고 지금 네 입으로 한 말.\n이제야 증거가 말하는구나. 정 의관, 너를 대비마마 시해 미수로 묶는다."},
]

const C10_CURE := [
	{"bg": "uigeumbu", "music": "darae_cheer", "who": "", "text": "이튿날 아침, 의금부 옥사의 문이 열렸다."},
	{"who": "다래", "pose": "darae_prison", "text": "…{name}아? 끝났어? 진짜?"},
	{"who": "{name}", "pose": "hero_adult", "text": "응. 끝났어. 늦어서 미안해. …밥 진짜 맛없었지?"},
	{"who": "다래", "pose": "darae_adult_cry", "text": "바보야아…! 진짜, 진짜 맛없었단 말이야…!\n…고마워. 와 줘서."},
	{"bg": "daebi_room", "music": "palace", "who": "", "text": "대비전. {name|과} 다래가 함께 달인 환심단 탕약을 드신 지 사흘.\n대비마마의 얼굴에 다시 혈색이 돌았다."},
	{"who": "대비", "pose": "daebi_smile", "text": "어의, 그리고 의녀 다래. 그대들 덕에 이 늙은이가 다시 아침 볕을 보는구나.\n…다래야, 억울했을 터인데 원망 한마디 않았다지. 고맙다."},
	{"who": "다래", "pose": "darae_adult", "text": "화, 황공하옵니다, 마마!\n…원망은 했사옵니다. 밥이 너무 맛없어서요."},
	{"who": "대비", "pose": "daebi_smile", "text": "호호호… 그래, 그래. 오늘 수라는 그대들과 함께 들어야겠구나."},
	{"bg": "palace", "who": "임금", "pose": "king", "text": "어의 {name}, 의녀 다래, 포도대장 윤도결, 그리고 부장 서휘.\n그대들이 아니었으면 과인은 어머니를 잃고, 죄 없는 자를 벌할 뻔하였다."},
	{"who": "임금", "pose": "king", "text": "의녀 다래를 내의원 의관으로 올리노라.\n앞으로 궁 안의 약은 어의와 의관 다래, 두 사람이 함께 맡으라."},
	{"who": "다래", "pose": "darae_adult", "text": "…의, 의관? 제가요?\n{name}아, 들었어? 나 의관이래! 할아버지한테 편지 써야겠다!"},
	{"who": "{name}", "pose": "hero_adult", "text": "(아버지, 어머니, 그리고 의원님.\n떼어 낸 검은 것은 이제 어디로도 가지 않아요. 우리가 되돌렸으니까.)"},
]
