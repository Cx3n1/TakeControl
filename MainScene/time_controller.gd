extends Node

class_name ServerMasterTimer

# Signals
signal timer_updated(time_left: float)
signal timer_finished()
signal timer_started(duration: float)
signal timer_stopped()

# Export variables
@export var initial_time: float = 300.0  # 5 minutes default
@export var auto_start: bool = false
@export var sync_interval: float = 0.1  # How often to sync with clients

# Private variables
var time_left: float = 0.0
var is_running: bool = false
var timer_id: String = ""
var sync_timer: Timer

func _ready():
    # Only run on server
    if not multiplayer.is_server():
        return
    
    # Create sync timer
    sync_timer = Timer.new()
    sync_timer.wait_time = sync_interval
    add_child(sync_timer)
    
    # Initialize timer
    time_left = initial_time
    
    if auto_start:
        start_timer()

func _process(delta):
    # Only process on server
    if not multiplayer.is_server() or not is_running:
        return
    
    if time_left > 0:
        time_left -= delta
        timer_updated.emit(time_left)
        
        if time_left <= 0:
            time_left = 0
            is_running = false
            timer_finished.emit()
            sync_timer.stop()

func start_timer(duration: float = -1):
    """Start the master timer"""
    if not multiplayer.is_server():
        return
    
    if duration > 0:
        initial_time = duration
        time_left = duration
    else:
        time_left = initial_time
    
    is_running = true
    timer_started.emit(time_left)
    
    # Start syncing with clients
    sync_timer.start()

func stop_timer():
    """Stop the master timer"""
    if not multiplayer.is_server():
        return
    
    is_running = false
    sync_timer.stop()
    timer_stopped.emit()

func pause_timer():
    """Pause the master timer"""
    if not multiplayer.is_server():
        return
    
    is_running = false
    sync_timer.stop()

func reset_timer():
    """Reset the master timer"""
    if not multiplayer.is_server():
        return
    
    time_left = initial_time
    is_running = false
    sync_timer.stop()
