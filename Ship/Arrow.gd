extends Control

# Arrow properties
@export var arrow_color: Color = Color.WHITE
@export var x_arrow_color: Color = Color.RED
@export var y_arrow_color: Color = Color.GREEN
@export var arrow_width: float = 3.0
@export var head_size: float = 15.0
@export var head_angle: float = 30.0  # degrees
@export var synchron : MultiplayerSynchronizer

@export var label : Label

@export var monitorable : RigidBody2D

# The vectors to draw
var arrow_vector: Vector2 = Vector2.ZERO
var x_vector: Vector2 = Vector2.ZERO
var y_vector: Vector2 = Vector2.ZERO

func _ready():
    # Example usage - remove this in your actual implementation
    pass

func _process(delta: float) -> void:
    if !synchron.is_multiplayer_authority():
        return
    var velocity = monitorable.linear_velocity / 20
    
    # Calculate X and Y components
    x_vector = Vector2(velocity.x, 0)
    y_vector = Vector2(0, velocity.y)
    
    # Set the main arrow vector
    set_arrow_vector(velocity)
    
    label.text = "%s m/s" % [velocity.length()]
    

func set_arrow_vector(vector: Vector2):
    """Set the vector for the arrow and trigger a redraw"""
    arrow_vector = vector
    queue_redraw()

func _draw():
    if !synchron.is_multiplayer_authority():
        return
    # Draw main velocity arrow (white)
    if arrow_vector.length() > 0:
        draw_arrow_with_color(Vector2.ZERO, arrow_vector, arrow_color)
    
    # Draw X component arrow (red)
    if x_vector.length() > 0:
        draw_arrow_with_color(Vector2.ZERO, x_vector, x_arrow_color)
    
    # Draw Y component arrow (green)  
    if y_vector.length() > 0:
        draw_arrow_with_color(Vector2.ZERO, y_vector, y_arrow_color)

func draw_arrow_with_color(start_pos: Vector2, vector: Vector2, color: Color):
    """Draw an arrow from start_pos with the given vector and color"""
    var end_pos = start_pos + vector
    
    # Draw the main line
    draw_line(start_pos, end_pos, color, arrow_width)
    
    # Calculate arrow head
    if vector.length() > head_size:
        var angle = vector.angle()
        var head_angle_rad = deg_to_rad(head_angle)
        
        # Calculate the two points of the arrow head
        var head_length = head_size
        var left_point = end_pos + Vector2(
            -head_length * cos(angle - head_angle_rad),
            -head_length * sin(angle - head_angle_rad)
        )
        var right_point = end_pos + Vector2(
            -head_length * cos(angle + head_angle_rad),
            -head_length * sin(angle + head_angle_rad)
        )
        
        # Draw arrow head lines
        draw_line(end_pos, left_point, color, arrow_width)
        draw_line(end_pos, right_point, color, arrow_width)
        
        # Optional: fill the arrow head triangle
        var points = PackedVector2Array([end_pos, left_point, right_point])
        draw_colored_polygon(points, color)

# Utility function to draw arrow at any position
func draw_arrow_at_position(start_pos: Vector2, vector: Vector2, color: Color = arrow_color):
    """Draw an arrow at a specific position with a specific vector"""
    var end_pos = start_pos + vector
    
    # Draw the main line
    draw_line(start_pos, end_pos, color, arrow_width)
    
    # Calculate and draw arrow head
    if vector.length() > head_size:
        var angle = vector.angle()
        var head_angle_rad = deg_to_rad(head_angle)
        
        var head_length = head_size
        var left_point = end_pos + Vector2(
            -head_length * cos(angle - head_angle_rad),
            -head_length * sin(angle - head_angle_rad)
        )
        var right_point = end_pos + Vector2(
            -head_length * cos(angle + head_angle_rad),
            -head_length * sin(angle + head_angle_rad)
        )
        
        draw_line(end_pos, left_point, color, arrow_width)
        draw_line(end_pos, right_point, color, arrow_width)
        
        var points = PackedVector2Array([end_pos, left_point, right_point])
        draw_colored_polygon(points, color)

# Example usage functions
#func _input(event):
    #if event is InputEventMouseMotion:
        ## Example: Make arrow point towards mouse
        #var mouse_pos = get_global_mouse_position()
        #var local_mouse = to_local(mouse_pos)
        #set_arrow_vector(local_mouse)
    #elif event is InputEventMouseButton and event.pressed:
        ## Example: Set arrow to a random vector
        #var random_vector = Vector2(
            #randf_range(-200, 200),
            #randf_range(-200, 200)
        #)
        #set_arrow_vector(random_vector)
