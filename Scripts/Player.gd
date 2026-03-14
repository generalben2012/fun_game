extends CharacterBody2D

# 플레이어 이동 속도 설정
@export var speed: float = 300.0
# MathUI 참조 (MainWorld에 추가될 노드 경로)
@onready var math_ui = get_node("/root/MainWorld/MathUI")

func _physics_process(delta: float) -> void:
	# WASD 키 입력을 받아 이동 벡터(direction) 계산
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * speed
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()

func _input(event: InputEvent) -> void:
    # 스페이스바(ui_accept) 버튼 처리: 시간 정지(캐스팅) 및 영창 UI 호출
	if event.is_action_pressed("ui_accept"):
		if math_ui and not get_tree().paused:
			math_ui.show_question()
