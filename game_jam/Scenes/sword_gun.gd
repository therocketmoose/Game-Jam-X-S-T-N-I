class_name SwordGun
extends Node2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

@export var offset: Vector2 = Vector2(-30, -30) # Default (Right-facing) offset
@export var lunge_distance: float = 60.0
@export var attack_speed: float = 0.1
@export var return_speed: float = 0.2
@export var idle_rotation: float = 0 # Base degrees

var is_attacking: bool = false
var current_offset: Vector2
var current_idle_rot: float

func _ready() -> void:
	current_offset = offset
	current_idle_rot = deg_to_rad(idle_rotation)

func _process(delta: float) -> void:
	var player = get_parent()
	
	# 1. Handle Flipping logic
	if player.velocity.x < 0:
		current_offset = Vector2(-offset.x, offset.y)
		current_idle_rot = deg_to_rad(-idle_rotation + 180) 
		animation.flip_h = true
	elif player.velocity.x > 0:
		current_offset = offset
		current_idle_rot = deg_to_rad(idle_rotation)
		animation.flip_h = false

	var idle_target_pos = player.global_position + current_offset
	
	if not is_attacking:
		global_position = global_position.lerp(idle_target_pos, 15 * delta)
		rotation = lerp_angle(rotation, 20, 1)
	
	if Input.is_action_just_pressed("left_click"):
		attack()

func attack() -> void:
	if is_attacking: return
	is_attacking = true
	
	animation.play("attack")
	
	# Lock in the direction from the current offset point to the mouse
	var anchor_start = get_parent().global_position + current_offset
	var attack_direction = (get_global_mouse_position() - anchor_start).normalized()
	var strike_angle = attack_direction.angle()
	
	var tween = create_tween().set_parallel(true)
	
	# --- LUNGE OUT ---
	tween.tween_method(
		func(progress: float): 
			var anchor = get_parent().global_position + current_offset
			global_position = anchor + (attack_direction * lunge_distance * progress),
		0.0, 1.0, attack_speed
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "rotation", strike_angle, attack_speed)
	
	# --- RETURN ---
	tween.chain().set_parallel(true)
	
	tween.tween_method(
		func(progress: float): 
			var anchor = get_parent().global_position + current_offset
			global_position = anchor + (attack_direction * lunge_distance * (1.0 - progress)),
		0.0, 1.0, return_speed
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "rotation", current_idle_rot, return_speed)
	
	tween.chain().tween_callback(func(): is_attacking = false)
