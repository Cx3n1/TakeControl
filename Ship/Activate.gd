extends TextureRect
class_name WaveCreator
var duration = 1.5
@export var shader_mat : ShaderMaterial

var long_dur = 2

func _ready() -> void:
    hide()

func short_burst():
    duration = 0.5
    self.modulate = Color(1, 1, 1, 1)
    reset()
    show()
    fade()

func activate():
    duration = 1.5
    self.modulate = Color(1, 1, 1, 1)
    reset()
    show()
    fade()

func reset():
    shader_mat.set_shader_parameter("wave_count", 1)
    shader_mat.set_shader_parameter("speed", 10)
    shader_mat.set_shader_parameter("height", 0.001)

var height = 0.001

var _curr = 0

func _process(delta: float) -> void:
    if !waving:
        return
    
    height += 0.05 * delta / long_dur
    shader_mat.set_shader_parameter("height", height)
    
    if height >= 0.05:
        fade()
        reset()
        waving = false
    

var waving : bool = false

func long_wave():
    self.modulate = Color(1, 1, 1, 1)
    show()
    reset()
    waving = true
    shader_mat.set_shader_parameter("wave_count", 1)
    shader_mat.set_shader_parameter("height", 0.001)


func fade():
    var tween = get_tree().create_tween()
    tween.tween_property(self, "modulate", Color(1, 1, 1, 0), duration).set_ease(Tween.EASE_OUT)
    get_tree().create_timer(duration).timeout.connect(end)

func end():
    hide()
