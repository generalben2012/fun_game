extends Node2D

@onready var enemy_scene = preload("res://Scenes/Enemy.tscn")
@onready var player = get_node_or_null("Player")

func _ready() -> void:
    var timer = Timer.new()
    timer.wait_time = 3.0
    timer.autostart = true
    timer.timeout.connect(_on_spawn_timer_timeout)
    add_child(timer)

func _on_spawn_timer_timeout() -> void:
    if not enemy_scene or not player: return
    
    var enemy = enemy_scene.instantiate()
    add_child(enemy)
    
    # 플레이어 위치 기준으로 무작위 방향 800px 밖에서 생성 (플레이어를 포위하듯 등장)
    var random_angle = randf() * PI * 2
    var spawn_offset = Vector2(cos(random_angle), sin(random_angle)) * 800.0
    enemy.global_position = player.global_position + spawn_offset
