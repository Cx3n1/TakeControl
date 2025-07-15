extends Control

class_name CountdownTimer

# Signals
signal timeout
signal time_changed(time_left: float)

# Export variables (editable in inspector)
@export var countdown_time: float = 10.0
@export var auto_start: bool = false
@export var time_format: String = "mm:ss"  # Options: "ss", "mm:ss", "hh:mm:ss"

# Private variables
var time_left: float = 0.0
var is_running: bool = false
var label: Label

func _ready():
    # Find the Label node (assumes it's a child of this node)
    label = get_node("Label") if has_node("Label") else null
    
    if label == null:
        push_error("CountdownTimer: No Label node found as child!")
        return
    
    # Initialize the timer
    time_left = countdown_time
    update_display()
    
    # Auto start if enabled
    if auto_start:
        start_timer()

func _process(delta):
    if is_running and time_left > 0:
        time_left -= delta
        update_display()
        time_changed.emit(time_left)
        
        if time_left <= 0:
            time_left = 0
            is_running = false
            update_display()
            timeout.emit()

func start_timer(duration: float = -1):
    """Start the countdown timer with optional custom duration"""
    if duration > 0:
        countdown_time = duration
        time_left = duration
    else:
        time_left = countdown_time
    
    is_running = true
    update_display()

func stop_timer():
    """Stop the countdown timer"""
    is_running = false

func pause_timer():
    """Pause the countdown timer"""
    is_running = false

func resume_timer():
    """Resume the countdown timer"""
    if time_left > 0:
        is_running = true

func reset_timer():
    """Reset the timer to initial countdown time"""
    time_left = countdown_time
    is_running = false
    update_display()

func add_time(seconds: float):
    """Add time to the current countdown"""
    time_left += seconds
    if time_left < 0:
        time_left = 0
    update_display()

func set_time(seconds: float):
    """Set the countdown time"""
    countdown_time = seconds
    time_left = seconds
    update_display()

func get_time_left() -> float:
    """Get the remaining time"""
    return time_left

func is_timer_running() -> bool:
    """Check if timer is currently running"""
    return is_running

func update_display():
    """Update the label display with formatted time"""
    if label == null:
        return
    
    var formatted_time = format_time(time_left)
    label.text = formatted_time

func format_time(seconds: float) -> String:
    """Format time based on the selected format"""
    var total_seconds = int(seconds)
    var hours = total_seconds / 3600
    var minutes = (total_seconds % 3600) / 60
    var secs = total_seconds % 60
    
    match time_format:
        "ss":
            return "%02d" % secs
        "mm:ss":
            return "%02d:%02d" % [minutes, secs]
        "hh:mm:ss":
            return "%02d:%02d:%02d" % [hours, minutes, secs]
        _:
            return "%02d:%02d" % [minutes, secs]
