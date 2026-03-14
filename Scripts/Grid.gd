extends ColorRect

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var step = 100
	for x in range(0, int(size.x), step):
		draw_line(Vector2(x, 0), Vector2(x, size.y), Color(0.3, 0.3, 0.3, 1), 2.0)
	for y in range(0, int(size.y), step):
		draw_line(Vector2(0, y), Vector2(size.x, y), Color(0.3, 0.3, 0.3, 1), 2.0)
