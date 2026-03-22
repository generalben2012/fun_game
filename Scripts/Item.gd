extends Area2D

@export var magnet_radius: float = 180.0
@export var base_speed: float = 0.0
@export var accel: float = 1200.0

@onready var player = get_node_or_null("/root/MainWorld/Player")
var is_magnetized: bool = false
var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
    if not player or not is_instance_valid(player):
        return
        
    var dist = global_position.distance_to(player.global_position)
    
    if dist < magnet_radius:
        is_magnetized = true
        
    if is_magnetized:
        var dir = global_position.direction_to(player.global_position)
        base_speed += accel * delta
        velocity = dir * base_speed
        position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
    if body == player:
        if player.has_method("restore_mana"):
            player.restore_mana(10)
        queue_free()
