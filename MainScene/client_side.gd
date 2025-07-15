extends Node

class_name ClientTimerDisplay

# Export variables
@export var time_format: String = "mm:ss"  # Options: "ss", "mm:ss", "hh:mm:ss"

# Private variables
var time_left: float = 0.0
var is_running: bool = false
@export var label: Label


func _process(delta):
    # Update display continuously for smooth countdown
    if is_running and time_left > 0:
        time_left -= delta
        if time_left < 0:
            time_left = 0
            is_running = false
        
        update_display()

func connect_to_server_timer(time_left):
    """Setup connection to server timer"""
    self.time_left = time_left
    is_running = true
    update_display()

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
    var ms = int((seconds - total_seconds) * 1000)
    
    var time_str = ""
    match time_format:
        "ss":
            time_str = "%02d" % secs
        "mm:ss":
            time_str = "%02d:%02d" % [minutes, secs]
        "hh:mm:ss":
            time_str = "%02d:%02d:%02d" % [hours, minutes, secs]
        _:
            time_str = "%02d:%02d" % [minutes, secs]
    
    return time_str
