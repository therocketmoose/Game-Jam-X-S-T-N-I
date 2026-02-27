extends Node2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox 

<<<<<<< Updated upstream
@export var offset: Vector2 = Vector2(-30, -30) # Idle position relative to player
@export var lunge_distance: float = 60.0       # How far it stabs out
@export var attack_speed: float = 0.1          # Fast snap out
@export var return_speed: float = 0.2          # Smooth snap back
@export var idle_rotation: float = 0      # Degrees (e.g., pointing up/diagonal)

var is_attacking: bool = false

func _process(delta: float) -> void:
	# 1. Calculate where the sword SHOULD be (Player position + our desired offset)
	var idle_target_pos = get_parent().global_position + offset
	
	if not is_attacking:
		# 2. Smoothly hover at the idle position
		global_position = global_position.lerp(idle_target_pos, 15 * delta)
		
		# 3. Stay at a fixed rotation (not looking at mouse)
		rotation = lerp_angle(rotation, deg_to_rad(idle_rotation), 10 * delta)
	
	# 4. Handle Input
	if Input.is_action_just_pressed("left_click"):
		attack(idle_target_pos)

func attack(start_pos: Vector2) -> void:
=======
@export var offset: Vector2 = Vector2(-40, -40) 
@export var lunge_distance: float = 60.0      
@export var attack_speed: float = 0.12         
@export var damage_s: int = 20 

var is_attacking: bool = false

func _ready():
	hitbox.monitoring = false

func _process(delta: float) -> void:
	if not is_attacking:
		var target_pos = get_parent().global_position + offset
		global_position = global_position.lerp(target_pos, 15 * delta)
		
		var mouse_pos = get_global_mouse_position()
		rotation = lerp_angle(rotation, (mouse_pos - global_position).angle(), 15 * delta)

	if Input.is_action_just_pressed("left_click"): 
		attack()

func attack() -> void:
>>>>>>> Stashed changes
	if is_attacking: return
	is_attacking = true
	hitbox.monitoring = true
	animation.play("attack")
	
<<<<<<< Updated upstream
	# Calculate direction toward mouse AT THE MOMENT of clicking
	var dir_to_mouse = (get_global_mouse_position() - global_position).normalized()
	rotation = dir_to_mouse.angle() # Snap rotation to the strike direction
	
	var tween = create_tween().set_parallel(false)
	
	# LUNGE: Move relative to the player's current position so it follows them
	# We use a custom step to ensure it doesn't get left behind if the player runs
	tween.tween_method(
		func(progress: float): 
			var current_player_back_pos = get_parent().global_position + offset
			global_position = current_player_back_pos + (dir_to_mouse * lunge_distance * progress),
		0.0, 1.0, attack_speed
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	# RETRACT: Smoothly move back to 0 distance from the idle point
	tween.tween_method(
		func(progress: float): 
			var current_player_back_pos = get_parent().global_position + offset
			global_position = current_player_back_pos + (dir_to_mouse * lunge_distance * (1.0 - progress)),
		0.0, 1.0, return_speed
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_callback(func(): is_attacking = false)
	
=======
	var mouse_dir = (get_global_mouse_position() - global_position).normalized()
	var attack_target = global_position + (mouse_dir * lunge_distance)
	
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", attack_target, attack_speed)
	tween.tween_callback(func(): 
		is_attacking = false
		hitbox.monitoring = false
	)

func _on_hitbox_body_entered(body):
	if is_attacking and body.has_method("take_damage") and not body.name.to_lower() == "player":
		body.take_damage(damage_s)
>>>>>>> Stashed changes
