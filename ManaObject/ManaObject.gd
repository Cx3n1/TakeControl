extends Node2D
class_name ManaObject

@export var max_mana = 100

var current_mana = 0

signal mana_filled
signal mana_run_out

func _ready() -> void:
    current_mana = 0

func set_mana(mana_value):
    assert(mana_value >= 0)
    max_mana = mana_value

func remove(value):
    assert(value >= 0)
    current_mana -= value
    if current_mana < 0:
        current_mana += value
        mana_run_out.emit()

func add(value):
    assert(value >= 0)
    current_mana += value
    if current_mana > max_mana:
        current_mana -= value
        mana_filled.emit()
