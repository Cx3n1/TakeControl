extends RigidBody2D
class_name Orb

@export var player_detector : Area2D
@export var move_speed : float = 100.0
@export var min_distance : float = 10.0  # Stop moving when this close to target
@export var timer : Timer

var value = 10
var move_towards
var locked = false


func _ready() -> void:
    timer.timeout.connect(queue_free)
    timer.start(50)
    move_speed = move_speed*(randf()*0.2 + 0.8)
    # Connect the area_entered signal to our function

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if move_towards and locked:
        # Calculate direction to target
        var target_position = move_towards.global_position
        var direction = (target_position - global_position).normalized()
        var distance = global_position.distance_to(target_position)
        
        # Only move if we're not too close
        if distance > min_distance:
            # Move towards the target
            global_position += direction * move_speed * delta
        else:
            # Optional: Stop moving when close enough
            move_towards = null
            locked = false

@export var coin_sfx : AudioStreamPlayer2D
@export var sprite : AnimatedSprite2D
@export var damage : DamageShow

func request_destroy():
    damage.display_number(value, true)
    sprite.modulate = Color(1, 1, 1, 0)
    coin_sfx.play()
    timer.start(1)

func _on_body_entered(body: Node2D) -> void:
    if Utils.check_if_on_layer(body, "Player"):
        locked = true
        move_towards = body
