class_name Manager
extends Node2D

# Called when the node enters the scene tree for the first time.
var music_player: AudioStreamPlayer

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

	music_player.stream = load("res://music_player.tres")

	# Enable autoplay BEFORE entering tree (optional but correct)
	music_player.autoplay = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	# If autoplay does not trigger (depending on version), force play:
	music_player.play()
	music_player.volume_db = 10
