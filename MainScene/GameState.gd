extends Node2D
class_name GameState

@export var player_container : Node
@export var meteor_container : Node
@export var spawner : MultiplayerSpawner
@export var player_id : int
@export var meteor_spawner : MeteorSpawner
@export var alien_spawner : AlienShipSpawner
@export var timer : ServerMasterTimer
var server_started : bool = false

## returns all players
func get_all_player():
    return get_tree().get_nodes_in_group("Player")

@export var video : VideoStreamPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    video.autoplay
    #video.finished.connect(fade_video)
    get_tree().create_timer(30).timeout.connect(fade_video)

func fade_video():
    video.hide()

var player : Ship

func start_server():
    player = get_all_player()[0]
    alien_spawner.player = player
    meteor_spawner.player = player
    spawn_meteors()
    spawn_aliens()
    timer.start_timer()
    

func spawn_meteors():
    if !multiplayer.is_server():
        return
    while meteor_spawner.meteors < meteor_spawner.max_meteors:
        var player = get_all_player().pick_random()
        var player_pos = player.global_position
        meteor_spawner.spawn(player_pos)

func spawn_aliens():
    if !multiplayer.is_server():
        return
    while alien_spawner.meteors < alien_spawner.max_meteors:
        var player = get_all_player().pick_random()
        var player_pos = player.global_position
        alien_spawner.spawn(player_pos)
         

func _process(delta: float) -> void:
    #if !server_started:
        #return
    #spawn_meteors()
    pass
