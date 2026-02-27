class_name SwordGun
extends Node2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

@export var offset: Vector2 = Vector2(-40, -40) # Position relative to player
@export var lunge_distance: float = 50.0      # How far it stabs
@export var attack_speed: float = 0.15         # Time to reach target
@export var return_speed: float = 0.3          # Time to return to player
@export var damage_s: int = 10

var is_attacking: bool = false
var base_rotation: float = 0.0

func _process(delta: float) -> void:
	if not is_attacking:
		# 1. Smoothly follow the player with the offset
		var target_pos = get_parent().global_position + offset
		global_position = global_position.lerp(target_pos, 10 * delta)
		
		# 2. Look at the mouse smoothly
		var mouse_pos = get_global_mouse_position()
		var target_angle = (mouse_pos - global_position).angle()
		rotation = lerp_angle(rotation, target_angle, 10 * delta)

	# 3. Handle Input
	if Input.is_action_just_pressed("left_click"): # Replace with your M1 action
		attack()

func attack() -> void:
	if is_attacking: return
	
	is_attacking = true
	
	animation.play("attack")
	
	var mouse_direction = (get_global_mouse_position() - global_position).normalized()
	var attack_target = global_position + (mouse_direction * lunge_distance)
	
	# Create a tween for the "Stab" motion
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	# Lunge Forward
	tween.tween_property(self, "global_position", attack_target, attack_speed)
	
	# Return to Player
	tween.tween_callback(func(): is_attacking = false)
