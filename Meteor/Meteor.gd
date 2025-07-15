extends RigidBody2D
class_name Meteor

var radius : float = 1
@export var health_object : HealthObject
@export var collision_shape : CollisionShape2D
@export var visibility_notifier : VisibleOnScreenNotifier2D
@export var timer : Timer
@export var anim_player : AnimationPlayer
@export var animated_sprite : AnimatedSprite2D
@export var damage : DamageShow

@export var orb : PackedScene

signal destroyed

@export var explosion : AudioStreamPlayer2D

func _ready() -> void:
    visibility_notifier.is_on_screen()
    timer.timeout.connect(shatter)
    call_deferred("setup_health")
    #anim_player = AnimationPlayer.new()
    #add_child(anim_player)
    # Load and assign animations
    
    #var animation_library = load("res://Meteor/MeteorAnims.tres").duplicate(true)
    #anim_player.add_animation_library("", animation_library)
    

func setup_health():
    health_object.health_run_out.connect(_on_health_run_out)

var large_mass = 100

func setup_small():
    self.mass = 2
    self.radius = 64
    (self.collision_shape.shape as CircleShape2D).radius = radius
    self.animated_sprite.play("small")
    animated_sprite.scale = Vector2(0.7, 0.7)
    

func setup_medium():
    self.mass = 3
    self.radius = 90
    (self.collision_shape.shape as CircleShape2D).radius = radius
    self.animated_sprite.play("medium")
    animated_sprite.scale = Vector2(0.3, 0.3)
    

func setup_big():
    self.mass = 4
    self.radius = 120
    (self.collision_shape.shape as CircleShape2D).radius = radius
    self.animated_sprite.play("big")
    animated_sprite.scale = Vector2(0.4, 0.4)

var type : int

func set_defaults(variant : int):
    contact_monitor = true
    sleeping = false
    freeze = false
    show()
    variant = variant % 3
        
    match variant:
        0: setup_small()
        1: setup_medium()
        2: setup_big()
    type = variant
    # Apply impulse to give initial movement
    # Vector2 for the impulse direction and magnitude
    if randf() < 0.5:
        return
    
    var impulse_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
    var impulse_strength = 100.0*(randf()*0.5 + 0.5)  # Adjust this 
    
    apply_impulse(impulse_direction * impulse_strength * (variant + 1))


func _on_body_entered(body: Node) -> void:
    var collision : RigidBody2D = (body as RigidBody2D)
    
    assert(collision)
    if Utils.check_if_on_layer(body, "Damage"):
        var damage_amount = calculate_damage_taken(collision)
        
        assert(health_object)
       
        health_object.hit(damage_amount)
        damage.display_number(damage_amount)
        anim_player.play("hit")
        
        
    if Utils.check_if_on_layer(body, "Planet"):
        # TODO: hit effect
        # meteor smashes to plnet meteor dies
        shatter()
        

func _on_health_run_out() -> void:
    shatter()

@export var anim2 : AnimatedSprite2D
@export var explo : GPUParticles2D

func shatter() -> void:
    destroyed.emit()
    explosion.play()
    if anim2:
        anim2.animation_finished.connect(destroy_final)
        anim2.play("Explode")
    else:
        # If no explosion animation, destroy immediately
        destroy_final()
    
    # Disable collision
    if collision_shape:
        collision_shape.disabled = true
    
    explo.restart()
    anim_player.play("Destroy")
    
    # Fade out the main sprite
    if animated_sprite:
        var tween = get_tree().create_tween()
        tween.tween_property(animated_sprite, "modulate", Color(1, 1, 1, 0), 0.25).set_ease(Tween.EASE_OUT)

func destroy_final():
    var count = randi() % (type + 2)
    
    for i in count:
        var inst : Orb = orb.instantiate()
        inst.value = (randi()%(type + 1) + mass)*1000
        inst.global_position = self.global_position
        get_parent().get_parent().add_child(inst, true)
        var impulse_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
        inst.apply_impulse(impulse_direction*100)
        
    queue_free()

func _on_screen_exited() -> void:
    if visibility_notifier.is_on_screen():
        return
    timer.start(5)
    

func _on_screen_entered() -> void:
    timer.stop()
    
    
func calculate_damage_taken(collision: RigidBody2D) -> float:
    
    # calculate kinetic energy of the collision object (KE = 0.5 * m * vÂ²)
    var velocity_magnitude = collision.linear_velocity.length()
    var kinetic_energy = 0.5 * collision.mass * velocity_magnitude * velocity_magnitude
    
    # scale damage based on kinetic energy
    var kinetic_damage = kinetic_energy * 0.01  # Adjust multiplier as needed
    
    # consider meteor's resistance based on size
    var size_resistance = radius * 0.5  # Bigger meteors are harder to damage
    var final_damage = max(1.0, kinetic_damage - size_resistance)
    
    return final_damage
