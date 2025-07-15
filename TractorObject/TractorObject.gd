extends Area2D
class_name TractorObject

@export var parent_rigidbody : PhysicsBody2D

func _ready():
    parent_rigidbody = get_parent()
