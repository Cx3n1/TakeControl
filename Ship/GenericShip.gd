extends RigidBody2D
class_name Ship

@export var synchronizer : MultiplayerSynchronizer
@export var mana_object : ManaObject
@export var health_object : HealthObject

@export var camera_shake : Camera2D

@export var rotator : Node2D
@export var TractorTargeter : Area2D

@export var tractor_beam : TractorBeam

@export var mizani : AnimatedSprite2D
@export var sprite : AnimatedSprite2D

@export var timer : ClientTimerDisplay

@export var wave : WaveCreator

var scores : int = 0

@export var score_label : Label


const SPEED = 5000
const MAX_LINEAR_VELOCITY = 2000
const ROTATION_SPEED = 5.0  # How fast the sprite rotates towards input direction
var target_rotation = 0.0  # Target rotation angle

func _input(event: InputEvent) -> void:  
    if !synchronizer.is_multiplayer_authority():
        return
    
    if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
        pass


func _ready() -> void:
    #setup_multiplayer_authority(str(name).to_int())
    tractor_beam._initalize_link()
    
    $CanvasLayer/Control2.hide()
    
    score_label.text = "0"
       
    if synchronizer.is_multiplayer_authority():
        #camera_shake.make_current()
        get_parent().player_id = str(self.name).to_int()
        
        teleporter.fire_teleport.connect(_fire_teleport)
      
    
func setup_cam():
    if synchronizer.is_multiplayer_authority():
        camera_shake = $"CameraShake"  
        camera_shake.make_current()

func setup_multiplayer_authority(id) -> void:
    if not synchronizer:
        print("Error: MultiplayerSynchronizer is not assigned!")
        return
    
    # Set the authority
    #synchronizer.set_multiplayer_authority(id)

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta: float) -> void:
    if !synchronizer.is_multiplayer_authority():
        return
    
    shake(delta)
    
    point_rotator_towards_mouse()
    ease_sprite_towards_input_direction(delta)
    
    if TractorTargeter.monitoring && tractor_beam.is_connected:
        TractorTargeter.monitoring = false
    
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) && tractor_beam.is_connected:
        tractor_beam.break_links()
    
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && !tractor_beam.is_connected:
        TractorTargeter.monitoring = true
        TractorTargeter.show()
    elif !tractor_beam.is_connected:
        TractorTargeter.monitoring = false
        TractorTargeter.hide()
        
   

func point_rotator_towards_mouse() -> void:
    # Get the mouse position in global coordinates
    var mouse_pos = get_global_mouse_position()
    
    # Calculate the direction from player to mouse
    var direction = mouse_pos - global_position
    
    # Calculate the angle and apply it to the rotator's rotation
    var angle = direction.angle()
    rotator.rotation = angle + deg_to_rad(-90)

func ease_sprite_towards_input_direction(delta: float) -> void:
    var x_direction := Input.get_axis("left", "right")
    var y_direction := Input.get_axis("up", "down")
    var input_vector = Vector2(x_direction, y_direction)
    
    # Only update target rotation if there's input
    if input_vector.length() > 0.1:
        target_rotation = input_vector.angle() + deg_to_rad(-90)
    
    # Smoothly rotate sprite towards target
    sprite.rotation = lerp_angle(sprite.rotation, target_rotation, ROTATION_SPEED * delta)

var weight : float = 0
var stopping_force = 50

func _draw() -> void:
    pass

func _enter_tree() -> void:
    synchronizer.set_multiplayer_authority(str(name).to_int())
    #set_multiplayer_authority(name.to_int())
    pass

var wave_activate :bool = false

func _physics_process(delta: float) -> void:
    if !synchronizer.is_multiplayer_authority():
        return
    
    if !getting_input:
        return
    
    var x_direction := Input.get_axis("left", "right")
    var y_direction := Input.get_axis("up", "down")

    var dir = Vector2(x_direction, y_direction)*SPEED

    constant_force = dir
    
    #if dir.length() > 0 && !wave_activate:
        #wave.activate()
        #wave_activate = true
    
    
    # Limit maximum linear velocity
    if linear_velocity.length() > MAX_LINEAR_VELOCITY:
        linear_velocity = linear_velocity.normalized() * MAX_LINEAR_VELOCITY
    
    if dir.length() > 10:
        sprite.play("Going")
        if !wave_activate:
            wave.activate()
            wave_activate = true
    else:
        sprite.play("Stopped")
        wave_activate = false
        
    
    if Input.is_action_pressed("Break"):
        if linear_velocity.length() < 5:
            linear_velocity = Vector2.ZERO
            wave_activate = false
            return
        weight += delta*stopping_force*2
        if weight >= 50:
            weight = 50
        linear_velocity = linear_velocity.lerp(Vector2.ZERO, weight/50)
        return
    
    
    if dir.length() != 0:
        weight = 0
    else:
        if linear_velocity.length() < 5:
            linear_velocity = Vector2.ZERO
            wave_activate = false
            return
        weight += delta*stopping_force
        if weight >= 50:
            weight = 50
        linear_velocity = linear_velocity.lerp(Vector2.ZERO, weight/50)


func _on_body_entered(body: Node) -> void:
    var collision : CollisionObject2D = (body as CollisionObject2D)
    
    if Utils.check_if_on_layer(body, "Damage"):
        #TODO collision with damage layer
        pass
        
        
    if Utils.check_if_on_layer(body, "Planet"):
        Engine.time_scale = 0.01
        show_game_over()
        pass
        
        
func show_game_over():
    $CanvasLayer/Control2.show()
    $CanvasLayer/Control2/Score.text = "Final Score: %s" % scores
    pass
        
func explode():
    pass

func respawn():
    pass


func _on_tractor_targeter_area_entered(area: Area2D) -> void:
    if !Utils.check_if_on_layer(area, "Tractable"):
        return
    print(area.name)
    
    TractorTargeter.monitoring = false
    tractor_beam.link_to(area as TractorObject)
    TractorTargeter.hide()


func _on_coin_entered(area: Node2D) -> void:
    var orb = area as Orb
    scores += orb.value
    orb.request_destroy()
    update_score()
    
func update_score():
    score_label.text = Utils.format_shorthand(scores)



@export var teleporter : Teleporter
@export var cutscene : AnimatedSprite2D

var getting_input : bool = true
var damager : bool = false
@export var hyper : AudioStreamPlayer2D

func _fire_teleport():
    getting_input = false
    scores -= teleporter.teleport_cost
    update_score()
    triger_long_shake()
    wave.long_wave()
    hyper.play()
    await get_tree().create_timer(0.5)
    cutscene.play("cut")
    await get_tree().create_timer(2).timeout
    self.set_collision_layer_value(5, true)
    var forward_direction = sprite.transform.y*100000
    apply_impulse(forward_direction)
    sprite.play("Hyper")
    
    await get_tree().create_timer(3).timeout
    
    sprite.play("Going")
    getting_input = true
    self.set_collision_layer_value(5, false)
    wave.activate()



var max_shake : float
var shake_fade : float
var _shake_strength : float

func triger_long_shake():
    max_shake = 50
    shake_fade = 5
    _shake_strength = 50


func shake(delta) -> void:
    if _shake_strength > 0:
        _shake_strength = lerp(_shake_strength, 0.0, shake_fade*delta)
        camera_shake.offset = Vector2(randf_range(-_shake_strength, _shake_strength), randf_range(-_shake_strength, _shake_strength))


func _on_button_pressed() -> void:
    get_tree().quit()
