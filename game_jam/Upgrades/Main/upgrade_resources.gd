class_name UpgradeResources
extends Resource

@export var sprite: Texture2D
@export_enum("speed", "health") var selected_type: String = "":
	set(value):
		selected_type = value
		type = value
@export var multiplier: float

var type = selected_type
