extends Node2D
class_name TractorBeam

@export var parent_collider : PhysicsBody2D
@export var pin : PinJoint2D
@export var link : PackedScene
@export var links : Node2D
@export var timer : Timer

var is_connected : bool = false
var tracked_object : TractorObject

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

    timer.timeout.connect(break_links)

func _input(event: InputEvent) -> void:
    pass

func _process(delta: float) -> void:
    if tracked_object != null:
        return
    
    
    
    if !is_connected:
        return
    

    
    break_links()
    is_connected = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:

    pass

func break_links():
    for child in links.get_children():
        child.queue_free()
    
    pin.node_b = ""
    is_connected = false
    tracked_object = null
    timer.stop()

func _initalize_link():
    pin.node_a = parent_collider.get_path()

var link_count = 20

func link_to(tractor_object : TractorObject):
    if is_connected:
        return
    var direction = tractor_object.global_position - self.global_position
    var angle = direction.angle()
    var position = self.position
    
    var link_len = direction.length()/link_count
    
    var link : Link = _create_link(position, angle)
    link.set_length(link_len)
    # connected to pin
    pin.node_b = link.LinkShape.get_path()
    var increment = link_len*(direction.normalized())
    position += increment
    
    var prev_link = link
    
    for i in range(link_count):
        link = _create_link(position, angle)
        link.set_length(link_len)
        prev_link.link_to(link.LinkShape)
        prev_link = link
        position += increment
    
    
    tracked_object = tractor_object
    is_connected = true
    prev_link.link_to(tractor_object.parent_rigidbody)
    
    timer.start(30)


func _create_link(position, angle) -> Link:
    var lnk : Link = link.instantiate()
    lnk.global_position = position
    lnk.rotation = angle + deg_to_rad(-90)
    lnk.set_stiffness(1000)
    lnk.set_damping(20)
    lnk.set_rest_length(10)
    links.add_child(lnk)
    return lnk
