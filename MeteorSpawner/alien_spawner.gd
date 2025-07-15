extends Node2D
class_name AlienShipSpawner

const max_distance : float = 10000
const min_distance : float = 800
@export var meteor : PackedScene
@export var curve : Curve
var game_state
var meteors : int = 0
var max_meteors : int = 10
var player : Ship


func _ready() -> void:
    game_state = get_parent()

func spawn(player_pos):
    if meteors >= max_meteors:
        return
    
    # generate random angle
    var random_angle = randf() * 2 * PI
    
    # generate distance weighted by curve
    var random_distance = sample_weighted_distance()
    
    # calculate spawn position using polar coordinates
    var spawn_offset = Vector2(cos(random_angle)*random_distance, sin(random_angle) * random_distance)
    var spawn_position = player_pos + spawn_offset
    
    # check if position is valid 
    if is_spawn_possible(spawn_position):
        spawn_meteor_at(spawn_position)

func sample_weighted_distance() -> float:
    # Sample using inverse transform sampling with the curve
    var u = randf()  # uniform random [0,1]
    
    # Find the distance that corresponds to this probability
    # We'll use binary search to find where the CDF equals u
    var low = 0.0
    var high = 1.0
    var tolerance = 0.001
    
    while high - low > tolerance:
        var mid = (low + high) / 2.0
        var cdf_value = calculate_cdf(mid)
        
        if cdf_value < u:
            low = mid
        else:
            high = mid
    
    var normalized_distance = (low + high) / 2.0
    return normalized_distance * (max_distance - min_distance) + min_distance

func calculate_cdf(x: float) -> float:
    # Calculate cumulative distribution function at point x
    # This integrates the curve from 0 to x
    var steps = 100
    var sum = 0.0
    var dx = x / steps
    
    for i in range(steps):
        var t = i * dx
        sum += curve.sample(t) * dx
    
    # Normalize by the total area under the curve
    var total_area = calculate_total_area()
    return sum / total_area

func calculate_total_area() -> float:
    # Calculate the total area under the curve from 0 to 1
    var steps = 100
    var sum = 0.0
    var dx = 1.0 / steps
    
    for i in range(steps):
        var t = i * dx
        sum += curve.sample(t) * dx
    
    return sum

func is_spawn_possible(pos : Vector2):
    var players = game_state.get_all_player()
    
    for player in players: 
        if player.global_position.distance_to(pos) < min_distance:
            return false
    
    return true

func spawn_meteor_at(pos: Vector2):
    var mtr : AlienShip = meteor.instantiate()
    
    mtr.global_position = pos
    
    game_state.add_child(mtr, true)
   
    mtr.player = game_state.get_all_player()[0]
    meteors += 1
    #mtr.Destroyed.connect(_on_meteor_destroy)

func spawn_meteors():
    if !multiplayer.is_server():
        return

func _on_meteor_destroy():
    meteors -= 1
    
    while meteors < max_meteors:
        var player = game_state.get_all_player().pick_random()
        var player_pos = player.global_position
        spawn(player_pos)
