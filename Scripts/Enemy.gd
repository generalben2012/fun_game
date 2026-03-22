extends CharacterBody2D

@export var speed: float = 150.0
@export var max_health: int = 20

var health: int = 20
var knockback: Vector2 = Vector2.ZERO
@onready var player = get_node_or_null("/root/MainWorld/Player")
var item_scene = preload("res://Scenes/Item.tscn")

func _ready() -> void:
    health = max_health

func _physics_process(delta: float) -> void:
    if player and is_instance_valid(player):
        var direction = global_position.direction_to(player.global_position)
        
        # 넉백이 남아있으면 넉백 속도를 우선 적용 (점점 감속)
        if knockback.length() > 20:
            velocity = knockback
            knockback = knockback.lerp(Vector2.ZERO, 15 * delta)
        else:
            velocity = direction * speed
            
        move_and_slide()
        
        # 플레이어와 직접 부딪히면 쾅!
        for i in get_slide_collision_count():
            var collision = get_slide_collision(i)
            if collision.get_collider() == player:
                if player.has_method("take_damage"):
                    player.take_damage(10)
                queue_free() # 충돌 후 자폭

func take_damage(amount: int, knockback_dir: Vector2) -> void:
    health -= amount
    
    # 넉백 벡터 저장
    knockback = knockback_dir * 600.0
    
    # 피격 연출 (색상 변경)
    modulate = Color(3, 3, 3)
    await get_tree().create_timer(0.1).timeout
    modulate = Color(1, 1, 1)
    
    if health <= 0:
        die()

func die() -> void:
    if item_scene:
        var item = item_scene.instantiate()
        get_parent().add_child(item)
        item.global_position = global_position
        
    queue_free()
