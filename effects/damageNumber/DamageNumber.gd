extends Node2D
class_name DamageShow

func add_num(number):
    get_parent().get_parent().add_child(number)

func display_number(value: int, is_critical: bool = false):
    var number = Label.new()
    number.global_position = global_position
    number.text = str(value)
    number.z_index = 5
    number.label_settings = LabelSettings.new()
    
    var color = "#FFF"

    
    # Random color between red and orange
    var red_component = randf_range(0.7, 1.0)  # Keep red high
    var green_component = randf_range(0.0, 0.5)  # Vary green for red-orange spectrum
    var blue_component = 0.0  # Keep blue at 0 for red-orange
    
    color = Color(red_component, green_component, blue_component)
    
    if is_critical:
        color = Color.GREEN_YELLOW
    
    number.label_settings.font_color = color
    number.label_settings.font_size = 50
    number.label_settings.outline_color = "#000"
    number.label_settings.outline_size = 1
    
    
    call_deferred("add_num", number)
    
    number.rotation = 0
    await number.resized
    number.pivot_offset = Vector2(number.size / 2)
    
    var tween = get_tree().create_tween()
    tween.set_parallel(true)
    tween.tween_property(
        number, "position:y", number.position.y - 24, 0.25
    ).set_ease(Tween.EASE_OUT)
    tween.tween_property(
        number, "scale", Vector2.ZERO, 0.25
    ).set_ease(Tween.EASE_IN).set_delay(0.5)
    
    await tween.finished
    number.queue_free()
