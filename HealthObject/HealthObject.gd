extends Node2D
class_name HealthObject

@export var max_health = 100

var current_health = 100

signal health_run_out
signal health_filled

func _ready() -> void:
    current_health = max_health

func set_health(health_value) -> void:
    max_health = health_value
    current_health = health_value

func hit(value) -> void:
    assert(value > 0)  
    current_health -= value
    if current_health <= 0:
        current_health = 0
        health_run_out.emit()
        
func heal(value) -> void:
    assert(value > 0)
    current_health += value
    if current_health > max_health:
        current_health = max_health
        health_filled.emit()
