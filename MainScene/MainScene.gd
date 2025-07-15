extends Node

const PORT = 5040

@export var player_container : Node
@export var player_scene : PackedScene
@export var menu : Control
@export var game_state : GameState
@export var timer : ServerMasterTimer

var multiplayer_peer = ENetMultiplayerPeer.new()


func _ready() -> void:
    #multiplayer.server_relay = false

    # Automatically start the server in headless mode.
    if DisplayServer.get_name() == "headless":
        print("Automatically starting dedicated server.")
        _on_host_pressed.call_deferred()

func _on_host_pressed() -> void:
    multiplayer_peer.create_server(PORT)
    multiplayer.multiplayer_peer = multiplayer_peer
    multiplayer_peer.peer_connected.connect(add_player_character)
    add_player_character()
    game_state.server_started = true
    game_state.start_server()
    menu.hide()


func add_player_character(id = 1):
    var player = preload("res://Ship/GenericShip.tscn").instantiate()
    player.name = str(id)
    player.timer.connect_to_server_timer(timer.time_left)

    # IMPORTANT: Add the player using multiplayer spawn
    get_parent().add_child(player, true)
        
    # Set the multiplayer authority for this player
    if player.has_method("set_multiplayer_authority"):
        player.setup_multiplayer_authority(id)
    
    print("Added player with ID: ", id)


#func add_player_character(id = 1):
    #var player = preload("res://Ship/GenericShip.tscn").instantiate()
    #player.name = str(id)
    #player_container.add_child(player)

func _on_join_pressed() -> void: #100.66.48.22
    multiplayer_peer.create_client("localhost", PORT)
    multiplayer.multiplayer_peer = multiplayer_peer
    menu.hide()
