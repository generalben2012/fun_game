extends Area2D

@export var speed: float = 600.0
@export var damage: int = 10
var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    # 2초 후 자동 소멸 (화면 밖으로 나가는 경우 등)
    await get_tree().create_timer(2.0).timeout
    if is_inside_tree(): queue_free()

func _process(delta: float) -> void:
    position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("enemies"):
        if body.has_method("take_damage"):
            body.take_damage(damage, direction)
        queue_free()
