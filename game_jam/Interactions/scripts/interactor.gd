class_name Interactor
extends Area2D

var interactableFound = null

func _process(_delta: float) -> void:
	if interactableFound and Input.is_action_just_pressed("interact"):
		interactableFound.interactedWith.emit()

func _on_body_entered(body: Node2D) -> void:
	if has_child_of_type(body, Interactable):
		interactableFound.detected_by_player()

func _on_body_exited(body: Node2D) -> void:
	if has_child_of_type(body, Interactable):
		interactableFound.undetected_by_player()
		interactableFound = null

func has_child_of_type(parent: Node, type_to_find):
	for child in parent.get_children():
		if is_instance_of(child, type_to_find):
			interactableFound = child
			return true
	return false
