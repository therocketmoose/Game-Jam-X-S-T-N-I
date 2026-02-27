class_name Upgrade
extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player = get_tree().get_first_node_in_group("player")
@export var upgrade_resources: UpgradeResources

# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	pass

func _on_interacted_with() -> void:
	if upgrade_resources.type == "attack_speed":
		player.attack_speed *= upgrade_resources.multiplier
	elif upgrade_resources.type == "sword_damage":
		player.sword_damage *= upgrade_resources.multiplier
	elif upgrade_resources.type == "gun_damage":
		player.gun_damage *= upgrade_resources.multiplier
	elif upgrade_resources.type == "move_speed":
		player.move_speed *= upgrade_resources.multiplier
	elif upgrade_resources.type == "damage_shield":
		player.damage_modifier = 0.5
		await get_tree().create_timer(10.0).timeout
		player.damage_modifier = 1.0
	self.queue_free()
	
func return_child_of_type(parent: Node, type_to_find):
	for child in parent.get_children():
		if is_instance_of(child, type_to_find):
			return child
