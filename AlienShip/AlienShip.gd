extends RigidBody2D
class_name AlienShip


enum STATE {Hidden, Idle, Chasing, Hovering, Dead, Shooting}

var current_state : STATE = STATE.Hidden

var player : Ship

@export var animation_player : AnimationPlayer

# thing that rotates around, which would point towards player usually
@export var rotator : Node2D

@export var rotation_speed : float = 10

@export var max_speed : int = 800
@export var acceleration : int = 3000
@export var breaking_accel : int = 2000
@export var hover_distance : int = 500
@export var hover_threshold : int = 200

## if player crerates this much distance, ship will stop chasing
@export var getaway_distance : int = 3000

## if player get's into this distance, ship will start chasing
@export var catch_on_distance : int = 1800


@export var knockback : float = 500
@export var shooting_interval : float = 1.5
@export var interval_rand_range : float = 0.5
var _shoot_curr_timer : float

@export var explosion : GPUParticles2D


var knockback_on : bool

## random number generated from time to time, used in calculatinon, to not recalculate it too often
var _rand_number : float = 1
## time rand is recalculated
var _rand_recalculation_time : float = 1
var _rand_curr_time : float = 0

## vector to player from current position
var _to_player : Vector2

var _initial_velocity : Vector2

func _ready() -> void:
    current_state = STATE.Idle


func initialize(postion : Vector2) -> void:
    self.global_position = postion
    show()
    animation_player.play("RESET")
    current_state = STATE.Idle



func _process(delta: float) -> void:
    _update_to_player()
    
    if current_state == STATE.Chasing || current_state == STATE.Hovering:
        _look_towards_player(delta)
    elif current_state != STATE.Shooting:
        _look_towards_movement_direction(delta)
        

func _physics_process(delta: float) -> void:
    if current_state == STATE.Idle:
        #print("idle")
        transition_to(STATE.Chasing)
    elif current_state == STATE.Chasing:
        #print("chasing")
        chasing_logic(delta)
    elif current_state == STATE.Hovering:
        #print("hovering")
        hovering_logic(delta)
    elif current_state == STATE.Shooting:
        shooting_logic(delta)

    _recalculate_rand(delta)



func _draw() -> void:
    #print(self.global_position)
    draw_line(Vector2.ZERO, self.constant_force, Color.CHARTREUSE)
    draw_line(Vector2.ZERO, self.linear_velocity, Color.BLUE)
    var to_hover = (_to_player.length() - hover_distance)/hover_threshold*_to_player.normalized()
    
    draw_line(Vector2.ZERO, to_hover*acceleration, Color.ORANGE)

func shooting_logic(delta: float) -> void:
    if linear_velocity.length() <= 0.01 || knockback_on: return
    
    _look_towards_player(delta)
    #apply_impulse(-linear_velocity)
    
    var thrust = -linear_velocity.normalized() * breaking_accel * linear_velocity/_initial_velocity*delta

    accelerate(thrust)
    

func chasing_logic(delta: float) -> void:
    var thrust = _to_player.normalized()*acceleration
    
    accelerate(thrust, true)
    
    if _to_player.length() < hover_distance + hover_threshold:
        self.constant_force = Vector2.ZERO
        transition_to(STATE.Hovering)
    elif _to_player.length() > getaway_distance:
        self.constant_force = Vector2.ZERO
        transition_to(STATE.Idle)
    elif check_shoot_transition(delta):
        self.constant_force = Vector2.ZERO
        transition_to(STATE.Shooting)

func hovering_logic(delta: float) -> void:
    var rand_hover_distance = (self.hover_distance + (hover_threshold)*(_rand_number-0.5))
    var to_hover = (_to_player.length() - rand_hover_distance)/hover_threshold*_to_player.normalized()

    accelerate(to_hover*acceleration)
    
    if _to_player.length() > rand_hover_distance + hover_threshold:
        linear_damp = 0
        transition_to(STATE.Chasing)
    elif check_shoot_transition(delta):
        self.constant_force = Vector2.ZERO
        transition_to(STATE.Shooting)

    check_shoot_transition(delta)

func transition_to(state : STATE) -> void:
    self.current_state = state
    
    if self.current_state == STATE.Hovering:
        linear_damp = 0.8
    
    if self.current_state == STATE.Shooting:
        knockback_on = false
        linear_damp = 1
        _initial_velocity = linear_velocity
        _shoot()
        

func get_side_contributions() -> Vector4:
    var contrib : Vector4 = Vector4.ZERO
    var thrust = self.constant_force
    
    #TODO: get constant force, and calculate which direcion matches it most
    #TODO: contrib is for left, up, right, down, with values of 0-1
    #TODO: if direction is outside of 80 degree sector of the direction then we don't consider that direction
    #TODO: the alignment to the direction is what determines the thrust
    #TODO: of course directions are relative to Rotator  
    
    return contrib


func accelerate(thrust: Vector2, counteract_other: bool = false) -> void:
    if counteract_other:
        thrust += -linear_velocity.normalized()*(abs(1- linear_velocity.normalized().dot(thrust.normalized()))*breaking_accel)

    self.constant_force = thrust*(1 - linear_velocity.length()/max_speed)


func _update_to_player() -> void:
    _to_player = get_viewport().get_mouse_position() - self.global_position
    queue_redraw()
    return
    if !player:
        return
    
    _to_player = player.global_position - self.global_position


func _look_towards_player(delta: float) -> void:
    _look_towards(_to_player, delta)

func _look_towards_movement_direction(delta: float) -> void:
    _look_towards(linear_velocity, delta)

func _look_towards(direction: Vector2, delta: float) -> void:
    rotator.rotation = lerp_angle(rotator.rotation, direction.angle() + deg_to_rad(-90), rotation_speed * delta)


func _die() -> void:
    transition_to(STATE.Dead)


func check_shoot_transition(delta: float) -> bool:
    if current_state == STATE.Shooting || _to_player.length() > hover_distance + hover_threshold:
        if _shoot_curr_timer >= shooting_interval:
            _shoot_curr_timer = shooting_interval - _rand_number
        return false
   
    _shoot_curr_timer += delta
    
    if _shoot_curr_timer < shooting_interval: return false
    
    _shoot_curr_timer = 0
    
    return true


func _shoot() -> void:
    animation_player.play("shoot")
    animation_player.animation_finished.connect(_finish_shooting)


func activate_knockback():
    knockback_on = true
    call_deferred("apply_impulse", -rotator.transform.y*knockback)
    

func _finish_shooting(anim_name : StringName):
    if anim_name != "shoot": return
    
    animation_player.animation_finished.disconnect(_finish_shooting)
    linear_damp = 0
    transition_to(STATE.Idle)

func _get_hit():
    animation_player.play("hit")


func _recalculate_rand(delta: float) -> void:
    _rand_curr_time += delta
    
    if _rand_curr_time < _rand_recalculation_time:
        return
    
    _rand_number = randf()
