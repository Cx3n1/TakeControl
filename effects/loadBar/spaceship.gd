extends Node2D

@onready var jump_bar = $JumpProgressBar
@onready var jump_button = $JumpButton

const JUMP_TIME := 1.0
var elapsed_time := 0.0
var is_charging := false

func _ready():
    jump_bar.min_value = 0
    jump_bar.max_value = JUMP_TIME
    jump_bar.value = 0
    jump_bar.visible = false
    jump_button.pressed.connect(on_jump_button_pressed)

func _process(delta):
    if is_charging:
        elapsed_time += delta
        jump_bar.value = elapsed_time
        if elapsed_time >= JUMP_TIME:
            execute_jump()

func on_jump_button_pressed():
    if not is_charging:
        is_charging = true
        elapsed_time = 0
        jump_bar.value = 0
        jump_bar.visible = true

func execute_jump():
    is_charging = false
    jump_bar.visible = false
    # 🛸 Trigger your light-speed jump logic here:
    print("🚀 Light-speed jump executed!")
    # Example: play animation, change scene, teleport, etc.
