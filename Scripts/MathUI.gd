extends CanvasLayer

signal question_answered(is_correct: bool)

@onready var blackboard_rect = $BlackboardRect
@onready var question_label = $BlackboardRect/QuestionLabel
@onready var answer_input = $BlackboardRect/AnswerInput
@onready var result_label = $BlackboardRect/ResultLabel

var current_answer: int = 0

func _ready() -> void:
    hide()
    # 입력 시 엔터(Submit) 처리를 위해 시그널 연결
    answer_input.text_submitted.connect(_on_answer_submitted)
    # UI 포커싱 이슈를 피하기 위해 포커스 모드 설정 (선택 사항)
    answer_input.focus_mode = Control.FOCUS_ALL

func show_question() -> void:
    # 시간 정지 (트윈이나 물리 처리 일시정지 효과)
    get_tree().paused = true
    generate_math_problem()
    result_label.text = ""
    answer_input.text = ""
    show()
    answer_input.grab_focus()

func generate_math_problem() -> void:
    # 덧셈/뺄셈/구구단 중 기초 난수 출제 (추후 확장 가능)
    var type = randi() % 3
    var num1 = 0
    var num2 = 0
    
    if type == 0: # 덧셈
        num1 = randi_range(1, 50)
        num2 = randi_range(1, 50)
        current_answer = num1 + num2
        question_label.text = str(num1) + " + " + str(num2) + " = ?"
    elif type == 1: # 뺄셈 (음수 방지를 위해 num1이 더 크게 설정)
        num1 = randi_range(20, 99)
        num2 = randi_range(1, num1)
        current_answer = num1 - num2
        question_label.text = str(num1) + " - " + str(num2) + " = ?"
    else: # 구구단
        num1 = randi_range(2, 9)
        num2 = randi_range(2, 9)
        current_answer = num1 * num2
        question_label.text = str(num1) + " × " + str(num2) + " = ?"

func _on_answer_submitted(new_text: String) -> void:
    var player_answer = new_text.to_int()
    
    if player_answer == current_answer:
        result_label.text = "Q.E.D! (정답)"
        result_label.modulate = Color.GREEN
        await get_tree().create_timer(0.5).timeout
        _close_blackboard(true)
    else:
        result_label.text = "Syntax Error! (오답)"
        result_label.modulate = Color.RED
        await get_tree().create_timer(0.5).timeout
        _close_blackboard(false)

func _close_blackboard(is_correct: bool) -> void:
    hide()
    get_tree().paused = false # 시간 정지 해제
    question_answered.emit(is_correct)
