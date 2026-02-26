class_name HitBox
extends Area2D

@export var damage: int
@export var group: String

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(group):
		print(group)
		var health_comp = body.get_node("HealthComponent")
		health_comp.take_damage(damage)
