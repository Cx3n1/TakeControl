extends Node

@export var combat : AudioStreamPlayer
@export var quiet : AudioStreamPlayer
@export var fade_duration : float = 2.0

var tween : Tween
var current_state : String = ""


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):
        fade_to_combat()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    tween = create_tween()
    tween.kill() # Stop the tween initially
    
    # Start with quiet music if available
    if quiet:
        quiet.volume_db = 0
        quiet.play()
        current_state = "quiet"
    
    # Combat starts silent
    if combat:
        combat.volume_db = -80
        combat.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func fade_to_combat():
    if current_state == "combat":
        return
    
    current_state = "combat"
    
    # Kill existing tween
    if tween:
        tween.kill()
    
    # Create new tween
    tween = create_tween()
    tween.set_parallel(true)
    
    # Start combat music if not playing
    if combat and not combat.playing:
        combat.play()
    
    # Fade combat in and quiet out
    if combat:
        tween.tween_property(combat, "volume_db", 0, fade_duration)
    if quiet:
        tween.tween_property(quiet, "volume_db", -80, fade_duration)

func fade_to_quiet():
    if current_state == "quiet":
        return
    
    current_state = "quiet"
    
    # Kill existing tween
    if tween:
        tween.kill()
    
    # Create new tween
    tween = create_tween()
    tween.set_parallel(true)
    
    # Start quiet music if not playing
    if quiet and not quiet.playing:
        quiet.play()
    
    # Fade quiet in and combat out
    if quiet:
        tween.tween_property(quiet, "volume_db", 0, fade_duration)
    if combat:
        tween.tween_property(combat, "volume_db", -80, fade_duration)
