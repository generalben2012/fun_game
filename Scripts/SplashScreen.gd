extends CanvasLayer

@onready var splash_label = $CenterContainer/SplashLabel

var math_strings = [
    "∫e^x dx", "E=mc²", "lim(x→0)", "∑n=1", "∇×B", "F=ma", "V=IR",
    "a²+b²=c²", "e^(iπ)+1=0", "ΔxΔp≥ℏ/2", "PV=nRT", "f'(x)",
    "G_μν", "i²=-1", "F=G(m₁m₂)/r²", "∇·E=ρ/ε₀", "sin²θ+cos²θ=1",
    "P(A|B)", "√x", "∞", "π", "θ", "Δ", "α", "β", "γ", "μ", "λ",
    "dy/dx", "log_e(x)", "d²y/dx²", "C_n^k", "x=y", "(a+b)ⁿ"
]

func _ready() -> void:
    var math_canvas = Control.new()
    math_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
    math_canvas.draw.connect(_on_math_canvas_draw.bind(math_canvas))
    add_child(math_canvas)
    move_child(math_canvas, 1)
    
    for i in range(400):
        var l = Label.new()
        l.text = math_strings.pick_random()
        l.position = Vector2(randf_range(-50, 1300), randf_range(-50, 750))
        l.rotation = randf_range(-0.1, 0.1)
        l.add_theme_font_size_override("font_size", randi_range(12, 28))
        l.add_theme_color_override("font_color", Color(0.1, randf_range(0.4, 0.8), randf_range(0.2, 0.4), randf_range(0.1, 0.6)))
        add_child(l)
        move_child(l, 1)

    var tween = create_tween()
    tween.tween_property(splash_label, "modulate:a", 1.0, 0.5)
    tween.tween_interval(1.5)
    tween.tween_property(splash_label, "modulate:a", 0.0, 0.5)
    
    await tween.finished
    get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

func _on_math_canvas_draw(canvas: Control) -> void:
    for i in range(30):
        var c = Vector2(randf_range(-100, 1380), randf_range(-100, 820))
        var r = randf_range(20, 90)
        var col = Color(0.1, randf_range(0.5, 0.9), randf_range(0.3, 0.6), randf_range(0.1, 0.4))
        canvas.draw_arc(c, r, 0, TAU, 32, col, 2.0)
        canvas.draw_line(c - Vector2(r+20, 0), c + Vector2(r+20, 0), col, 2.0)
        canvas.draw_line(c - Vector2(0, r+20), c + Vector2(0, r+20), col, 2.0)

func _input(event: InputEvent) -> void:
    if event is InputEventKey or event is InputEventMouseButton:
        if event.is_pressed():
            get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")
