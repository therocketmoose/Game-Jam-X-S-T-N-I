class_name Interactable
extends Node2D

@export var interaction_resources: Interaction_Resources
@export_enum("txt", "img") var selected_mode: String = "text":
	set(value):
		selected_mode = value
		mode = value

@onready var texture_rect: TextureRect = $Texture/TextureRect
@onready var label: Label = $Text/Label
@onready var texture: BoxContainer = $Texture
@onready var text: BoxContainer = $Text

var mode = selected_mode
signal interactedWith

func _ready() -> void:
	label.text = interaction_resources.text
	text.global_position.y -= interaction_resources.offset
	texture_rect.texture = interaction_resources.texture
	texture.global_position.y -= interaction_resources.offset

func detected_by_player():
	if mode == "txt":
		label.show()
	if mode == "img":
		texture_rect.show()

func undetected_by_player():
	if mode == "txt":
		label.hide()
	if mode == "img":
		texture_rect.hide()
