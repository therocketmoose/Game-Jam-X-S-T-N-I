class_name HealthComponent
extends Node2D

@export var main: Node2D
@export var max_health: int
var health = 0
signal died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	print(health)

func _process(_delta: float) -> void:
	if health <= 0:
		die()

func take_damage(damage: int):
	print(damage)
	health -= damage
	print(health)

func die():
	emit_signal("died")
