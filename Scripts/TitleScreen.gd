extends CanvasLayer

@onready var start_button = $VBoxContainer/StartButton
@onready var quit_button = $VBoxContainer/QuitButton

var math_strings = [
    "∫e^x dx", "E=mc²", "lim(x→0)", "∑n=1", "∇×B", "F=ma", "V=IR",
    "a²+b²=c²", "e^(iπ)+1=0", "ΔxΔp≥ℏ/2", "PV=nRT", "f'(x)",
    "G_μν", "i²=-1", "F=G(m₁m₂)/r²", "∇·E=ρ/ε₀", "sin²θ+cos²θ=1",
    "P(A|B)", "√x", "∞", "π", "θ", "Δ", "α", "β", "γ", "μ", "λ",
    "dy/dx", "log_e(x)", "d²y/dx²", "C_n^k", "x=y", "(a+b)ⁿ",
    "x² + y² = r²", "(x-a)² + (y-b)² = R²", "y = sin(x)", "y = a(x-p)² + q"
]

var time_passed: float = 0.0
var labels: Array[Label] = []
var math_canvas: Control

func _ready() -> void:
    start_button.pressed.connect(_on_start_pressed)
    quit_button.pressed.connect(_on_quit_pressed)
    start_button.grab_focus()
    
    math_canvas = Control.new()
    math_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
    math_canvas.draw.connect(_on_math_canvas_draw)
    add_child(math_canvas)
    move_child(math_canvas, 1)
    
    for i in range(250):
        var l = Label.new()
        l.text = math_strings.pick_random()
        l.position = Vector2(randf_range(-50, 1300), randf_range(-50, 750))
        l.rotation = randf_range(-0.1, 0.1)
        l.add_theme_font_size_override("font_size", randi_range(12, 28))
        l.add_theme_color_override("font_color", Color(0.1, randf_range(0.4, 0.8), randf_range(0.2, 0.5), randf_range(0.1, 0.5)))
        math_canvas.add_child(l)
        labels.append(l)

func _process(delta: float) -> void:
    time_passed += delta
    for i in range(3):
        labels.pick_random().text = math_strings.pick_random()
    math_canvas.queue_redraw()

func _on_math_canvas_draw() -> void:
    for i in range(20):
        var px = fmod((i * 173.5), 1380) - 50
        var py = fmod((i * 121.3), 820) - 50
        var base_r = 30 + (i * 2.1)
        
        var bounce_r = base_r + sin(time_passed * 2.5 + i) * 15.0
        var col = Color(0.1, 0.5 + 0.3 * sin(time_passed+i), 0.3, 0.25)
        
        math_canvas.draw_arc(Vector2(px, py), max(1.0, bounce_r), 0, TAU, 32, col, 2.0)
        math_canvas.draw_line(Vector2(px, py) - Vector2(bounce_r+20, 0), Vector2(px, py) + Vector2(bounce_r+20, 0), col, 2.0)
        math_canvas.draw_line(Vector2(px, py) - Vector2(0, bounce_r+20), Vector2(px, py) + Vector2(0, bounce_r+20), col, 2.0)

func _on_start_pressed() -> void:
    get_tree().change_scene_to_file("res://Scenes/MainWorld.tscn")

func _on_quit_pressed() -> void:
    get_tree().quit()
