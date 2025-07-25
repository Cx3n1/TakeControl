extends Camera2D
class_name Shaker

@export var max_shake: float = 10.0
@export var shake_fade: float = 10.0

var _shake_strength: float = 0.0

func triger_shake() -> void:
    max_shake = 10
    shake_fade = 10
    _shake_strength = max_shake

func triger_long_shake():
    max_shake = 50
    shake_fade = 5
    _shake_strength = 50


func _process(delta: float) -> void:
    if _shake_strength > 0:
        _shake_strength = lerp(_shake_strength, 0.0, shake_fade*delta)
        offset = Vector2(randf_range(-_shake_strength, _shake_strength), randf_range(-_shake_strength, _shake_strength))
