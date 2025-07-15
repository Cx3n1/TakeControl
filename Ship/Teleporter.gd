extends Node
class_name Teleporter

var teleport_cost = 10_000

var ship : Ship
var space_pressed_time: float = 0.0
var is_space_pressed: bool = false

signal fire_teleport

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Reset variables when ready
    space_pressed_time = 0.0
    is_space_pressed = false
    ship = get_parent()


@export var jump_bar : ProgressBar

const JUMP_TIME := 2.0
var elapsed_time := 0.0
var is_charging := false


#func _ready():
    #jump_bar.min_value = 0
    #jump_bar.max_value = JUMP_TIME
    #jump_bar.value = 0
    #jump_bar.visible = false
    #jump_button.pressed.connect(on_jump_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    # Check if space key is currently pressed
    if Input.is_action_pressed("Break") or Input.is_key_pressed(KEY_SPACE):
        if not is_space_pressed:
            # Space just started being pressed
            is_space_pressed = true
            space_pressed_time = 0.0
        
        if _check_condition():
            elapsed_time += delta
            jump_bar.value = 100*(elapsed_time/JUMP_TIME)
            if !jump_bar.visible:
                jump_bar.show()
        else:
            if jump_bar.visible:
                jump_bar.hide()
            jump_bar.value = 0
            elapsed_time = 0

        
        # Accumulate time while space is pressed
        space_pressed_time += delta
        
        # Check if space has been pressed for 5 seconds and condition is met
        if space_pressed_time >= JUMP_TIME:
            if _check_condition():
                fire_teleport.emit()
                
            is_space_pressed = false
            space_pressed_time = 0.0
    else:
        # Space key is not pressed, reset
        if !is_space_pressed:
            is_space_pressed = false
            if jump_bar.visible:
                jump_bar.hide()
            space_pressed_time = 0.0
            jump_bar.value = 0

# Helper function to check the condition
func _check_condition() -> bool:
    assert(ship != null)
    
    return (ship.scores   > teleport_cost and ship.linear_velocity.length() < 10)

# Optional: Method to get current space press duration (for debugging)
func get_space_press_duration() -> float:
    return space_pressed_time if is_space_pressed else 0.0
