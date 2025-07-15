extends Node2D
class_name Link

@export var LinkShape : RigidBody2D
@export var Spring : DampedSpringJoint2D
@export var line : Line2D

var _other : PhysicsBody2D

func _process(delta: float) -> void:
    line.points[0] = LinkShape.position
    if _other == null:
        line.points[1] = LinkShape.position
        return
    #TODO: make line connect to _other's position
    line.points[1] = to_local(_other.global_position)
    

func link_to(rigidbody : PhysicsBody2D):
    Spring.node_b = rigidbody.get_path()
    _other = rigidbody

func set_length(length : int):
    Spring.length = length

func set_rest_length(length : int):
    Spring.rest_length = length

func set_stiffness(stiffness : float):
    Spring.stiffness = stiffness

func set_damping(damping : float):
    Spring.damping = damping
