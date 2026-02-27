class_name Upgrade
extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player = get_tree().get_first_node_in_group("player")
@export var upgrade_resources: UpgradeResources

# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	pass

func _on_interacted_with() -> void:
	self.queue_free()
	
func return_child_of_type(parent: Node, type_to_find):
	for child in parent.get_children():
		if is_instance_of(child, type_to_find):
			return child
