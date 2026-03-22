extends CharacterBody2D

signal mana_changed(current, maximum)
signal hp_changed(current, maximum)

# 플레이어 이동 속도 및 마나, 체력 설정
@export var speed: float = 300.0
@export var max_mana: int = 100
var current_mana: int = 100

@export var max_hp: int = 100
var current_hp: int = 100
var mana_regen_timer: float = 0.0

# MathUI 참조 (MainWorld에 추가될 노드 경로)
@onready var math_ui = get_node_or_null("/root/MainWorld/MathUI")
@onready var projectile_scene = preload("res://Scenes/Projectile.tscn")

func _ready() -> void:
	current_mana = max_mana
	current_hp = max_hp
	if math_ui:
		math_ui.question_answered.connect(_on_math_question_answered)

func _physics_process(delta: float) -> void:
	# 마나 실시간 자동 회복 (0.5초마다 1 회복)
	mana_regen_timer += delta
	if mana_regen_timer >= 0.5:
		mana_regen_timer -= 0.5
		restore_mana(1)

	if Engine.time_scale < 1.0:
		return
		
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

func _on_math_question_answered(is_correct: bool, power_level: int) -> void:
	if is_correct:
		spawn_projectile(power_level)

func use_mana(amount: int) -> bool:
	if current_mana >= amount:
		current_mana -= amount
		mana_changed.emit(current_mana, max_mana)
		return true
	return false

func restore_mana(amount: int) -> void:
	current_mana = min(current_mana + amount, max_mana)
	mana_changed.emit(current_mana, max_mana)

func take_damage(amount: int) -> void:
	current_hp -= amount
	hp_changed.emit(current_hp, max_hp)
	
	modulate = Color(5, 0.2, 0.2)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	
	if current_hp <= 0:
		get_tree().reload_current_scene() # 사망 시 씬 재시작 (임시)

func spawn_projectile(power: int) -> void:
	var proj = projectile_scene.instantiate()
	get_parent().add_child(proj)
	proj.global_position = global_position
	proj.damage = 10 * power
	
	# 파워에 따른 크기 증가
	proj.scale = Vector2(1,1) * (1.0 + (power - 1) * 0.5)
	
	# 가장 가까운 적 찾기
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest_dist = 99999.0
	var target = null
	for e in enemies:
		var d = global_position.distance_to(e.global_position)
		if d < closest_dist:
			closest_dist = d
			target = e
			
	if target:
		proj.direction = global_position.direction_to(target.global_position)
	else:
		# 적이 없으면 우측으로 발사
		proj.direction = Vector2.RIGHT
