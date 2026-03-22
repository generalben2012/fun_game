extends CanvasLayer

signal question_answered(is_correct: bool, power_level: int)

@onready var blackboard_rect = $BlackboardRect
@onready var question_label = $BlackboardRect/QuestionLabel
@onready var answer_input = $BlackboardRect/AnswerInput
@onready var result_label = $BlackboardRect/ResultLabel
@onready var skill_button = $SkillButton
@onready var mana_bar = $ManaBar
@onready var hp_bar = $HpBar

@onready var player = get_node_or_null("/root/MainWorld/Player")

@onready var option_buttons = [
    $BlackboardRect/OptionBox/Option1,
    $BlackboardRect/OptionBox/Option2,
    $BlackboardRect/OptionBox/Option3,
    $BlackboardRect/OptionBox/Option4
]
@onready var option_box = $BlackboardRect/OptionBox

var current_answer: int = 0
var current_is_multiple_choice: bool = false
var blackboard_target_y: float = 0.0

func _ready() -> void:
    # 칠판의 원래 y 위치 저장
    blackboard_target_y = blackboard_rect.position.y
    blackboard_rect.hide()
    # 입력 시 엔터(Submit) 처리를 위해 시그널 연결
    answer_input.text_submitted.connect(_on_answer_submitted)
    skill_button.pressed.connect(_on_skill_button_pressed)
    
    # 객관식 버튼 시그널 연결
    for btn in option_buttons:
        btn.pressed.connect(_on_option_pressed.bind(btn))
    
    # UI 포커싱 이슈를 피하기 위해 포커스 모드 설정 (선택 사항)
    answer_input.focus_mode = Control.FOCUS_ALL
    
    if player:
        player.mana_changed.connect(_on_player_mana_changed)
        mana_bar.max_value = player.max_mana
        mana_bar.value = player.current_mana
        
        player.hp_changed.connect(_on_player_hp_changed)
        hp_bar.max_value = player.max_hp
        hp_bar.value = player.current_hp

func _on_player_mana_changed(current: int, maximum: int) -> void:
    mana_bar.max_value = maximum
    mana_bar.value = current

func _on_player_hp_changed(current: int, maximum: int) -> void:
    hp_bar.max_value = maximum
    hp_bar.value = current

func _on_skill_button_pressed() -> void:
    # 마나 검사 (1 소모)
    if player and player.use_mana(1):
        show_question()
    else:
        # 마나가 부족하면 버튼이 빨갛게 깜빡임
        if skill_button:
            skill_button.modulate = Color.RED
            await get_tree().create_timer(0.2).timeout
            if is_instance_valid(skill_button):
                skill_button.modulate = Color.WHITE

func show_question() -> void:
    # 완전한 시간 정지 대신 초슬로우 모션(5% 속도) 적용
    Engine.time_scale = 0.05
    generate_math_problem()
    result_label.text = ""
    answer_input.text = ""
    
    # 칠판이 위에서 떨어지는 애니메이션 연출
    blackboard_rect.position.y = -blackboard_rect.size.y
    blackboard_rect.show()
    
    var tween = create_tween()
    tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) # 일시정지 상태에서도 애니메이션 동작
    tween.set_trans(Tween.TRANS_BOUNCE)
    tween.set_ease(Tween.EASE_OUT)
    # 실제 지속시간 0.6초가 되도록 time_scale 로 보정
    tween.tween_property(blackboard_rect, "position:y", blackboard_target_y, 0.6 * Engine.time_scale)
    
    if not current_is_multiple_choice:
        answer_input.grab_focus()

func generate_math_problem() -> void:
    # 덧셈/뺄셈 중 기초 난수 출제
    var type = randi() % 2
    var num1 = 0
    var num2 = 0
    
    if type == 0: # 덧셈
        num1 = randi_range(1, 50)
        num2 = randi_range(1, 50)
        current_answer = num1 + num2
        question_label.text = str(num1) + " + " + str(num2) + " = ?"
    else: # 뺄셈 (음수 방지를 위해 num1이 더 크게 설정)
        num1 = randi_range(20, 99)
        num2 = randi_range(1, num1)
        current_answer = num1 - num2
        question_label.text = str(num1) + " - " + str(num2) + " = ?"

    # 주관식/객관식 랜덤 결정
    current_is_multiple_choice = (randi() % 2 == 0)
    
    if current_is_multiple_choice:
        answer_input.hide()
        option_box.show()
        
        # 객관식 선택지 생성
        var answers = []
        answers.append(current_answer)
        while answers.size() < 4:
            var wrong_ans = current_answer + randi_range(-10, 10)
            # 음수 출제 방지 (옵션) 및 중복 방지
            if wrong_ans >= 0 and wrong_ans != current_answer and not answers.has(wrong_ans):
                answers.append(wrong_ans)
        
        answers.shuffle()
        for i in range(4):
            option_buttons[i].text = str(answers[i])
    else:
        option_box.hide()
        answer_input.show()

func _on_answer_submitted(new_text: String) -> void:
    if new_text.strip_edges() == "": return
    _check_answer(new_text.to_int(), true)

func _on_option_pressed(btn: Button) -> void:
    _check_answer(btn.text.to_int(), false)

func _check_answer(player_answer: int, is_typing: bool) -> void:
    # 💥 입력 즉시 일시정지(슬로우)를 푸어 적이 당장 다가오게 함
    Engine.time_scale = 1.0 
    
    var power_level = 2 if is_typing else 1 # 주관식은 데미지 2배, 객관식은 1배
    
    # 중복 입력 방지
    answer_input.editable = false
    for btn in option_buttons:
        btn.disabled = true
        
    if player_answer == current_answer:
        result_label.text = "Q.E.D! (정답)"
        result_label.modulate = Color.GREEN
        await get_tree().create_timer(0.5).timeout
        _close_blackboard(true, power_level)
    else:
        result_label.text = "Syntax Error! (오답)"
        result_label.modulate = Color.RED
        
        # 오답 페널티: 찰진 칠판 쉐이크 효과
        var shake_tween = create_tween()
        shake_tween.set_trans(Tween.TRANS_SINE)
        var original_x = blackboard_rect.position.x
        
        for i in range(5):
            var offset = 20 if i % 2 == 0 else -20
            shake_tween.tween_property(blackboard_rect, "position:x", original_x + offset, 0.05)
        shake_tween.tween_property(blackboard_rect, "position:x", original_x, 0.05)
        print("💡 [효과음 재생 예정]: 딱! 분필 부러지는 소리 재생 (ChalkBreakSound.play())")
        
        await shake_tween.finished
        await get_tree().create_timer(0.3).timeout
        _close_blackboard(false, power_level)

func _close_blackboard(is_correct: bool, power_level: int) -> void:
    blackboard_rect.hide()
    # 입력 컴포넌트 복원
    answer_input.editable = true
    for btn in option_buttons:
        btn.disabled = false
        
    question_answered.emit(is_correct, power_level)
