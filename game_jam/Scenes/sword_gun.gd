class_name SwordGun
extends Node2D

@onready var hit_box: HitBox = $HitBox
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

@export var offset: Vector2 = Vector2(-30, -30) 
@export var lunge_distance: float = 60.0        
@export var attack_speed: float = 0.7           
@export var return_speed: float = 0.2           
@export var idle_rotation: float = 0      

var is_attacking: bool = false

func _ready() -> void:
	# Ensure the hitbox starts disabled and is aligned to the parent
	toggle_hitbox(false)
	hit_box.position = Vector2.ZERO # Keep it centered on the sword handle

func _process(delta: float) -> void:
	var idle_target_pos = get_parent().global_position + offset
	
	if not is_attacking:
		# Smoothly move AND rotate at the same time
		global_position = global_position.lerp(idle_target_pos, 15 * delta)
		rotation = lerp_angle(rotation, deg_to_rad(idle_rotation), 10 * delta)

	if Input.is_action_just_pressed("left_click"):
		attack()
		
func attack() -> void:
	if is_attacking: 
		return
	is_attacking = true
	
	toggle_hitbox(true)
	animation.play("attack")

	# Target direction at the start of the swing
	var dir_to_mouse = (get_global_mouse_position() - global_position).normalized()
	var attack_angle = dir_to_mouse.angle()
	
	var tween = create_tween().set_parallel(true) # Set to TRUE so position and rotation happen together

	# LUNGE: Both position and rotation move toward the target
	tween.tween_method(
		func(progress: float): 
			var current_player_back_pos = get_parent().global_position + offset)
			global_position = current_player_back_pos + (dir_to_mouse * lunge_distance * progress)
		, 0.0, 1.0, attack_speed
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	# Force rotation to stay locked to the strike direction during lunge
	tween.tween_property(self, "rotation", attack_angle, attack_speed)

	# RETRACT: Move back while slowly starting to look at the idle rotation again
	var retract_tween = create_tween().set_parallel(true)
	retract_tween.tween_method(
		func(progress: float): 
			var current_player_back_pos = get_parent().global_position + offset
			global_position = current_player_back_pos + (dir_to_mouse * lunge_distance * (1.0 - progress))
		, 0.0, 1.0, return_speed
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Cleanup
	retract_tween.chain().tween_callback(func(): 
		is_attacking = false
		toggle_hitbox(false)
	)

func toggle_hitbox(active: bool) -> void:
	# set_deferred is essential for collision to prevent "Flush Queries" errors
	hit_box.set_deferred("monitoring", active)
	hit_box.set_deferred("monitorable", active)
	# Also disable the shape specifically if you have multiple shapes
	for child in hit_box.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", !active)
