class_name HurtBox
extends Area2D

@export var health_component: HealthComponent
@export var main: Node2D
@export var group: String

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(group):
		print(group)
		health_component.take_damage(body.damage)
