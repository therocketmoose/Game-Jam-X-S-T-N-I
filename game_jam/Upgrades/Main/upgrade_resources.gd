class_name UpgradeResources
extends Resource

@export var sprite: Texture2D
@export_enum("attack_speed", "sword_damage", "gun_damage", "move_speed", "damage_shield") var selected_type: String = "":
	set(value):
		selected_type = value
		type = value
@export var multiplier: float

var type = selected_type
