class_name SwordGun
extends Node2D

@onready var hit_box: Area2D = $HitBox
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

@export var offset: Vector2 = Vector2(-30, -30) 
@export var lunge_distance: float = 60.0        
@export var attack_speed: float = 0.7           
@export var return_speed: float = 0.2           
@export var idle_rotation: float = 0      

var is_attacking: bool = false

func _ready() -> void:
	toggle_hitbox(false)
	if hit_box:
		hit_box.position = Vector2.ZERO
		# Ensure the signal is connected so it can damage the Suffocator
		if not hit_box.body_entered.is_connected(_on_hit_box_body_entered):
			hit_box.body_entered.connect(_on_hit_box_body_entered)

func _process(delta: float) -> void:
	var idle_target_pos = get_parent().global_position + offset
	
	if not is_attacking:
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

	var dir_to_mouse = (get_global_mouse_position() - global_position).normalized()
	var attack_angle = dir_to_mouse.angle()
	
	var tween = create_tween().set_parallel(true)

	# LUNGE
	tween.tween_method(func(prog): move_sword(prog, dir_to_mouse), 0.0, 1.0, attack_speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", attack_angle, attack_speed)

	# RETRACT
	var retract_tween = tween.chain().set_parallel(true)
	retract_tween.tween_method(func(prog): move_sword(1.0 - prog, dir_to_mouse), 0.0, 1.0, return_speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	retract_tween.chain().tween_callback(func(): 
		is_attacking = false
		toggle_hitbox(false)
	)

# Helper function to prevent indentation errors inside Tweens
func move_sword(progress: float, direction: Vector2):
	var current_player_back_pos = get_parent().global_position + offset
	global_position = current_player_back_pos + (direction * lunge_distance * progress)

func toggle_hitbox(active: bool) -> void:
	if not hit_box: return
	hit_box.set_deferred("monitoring", active)
	hit_box.set_deferred("monitorable", active)
	for child in hit_box.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", !active)

func _on_hit_box_body_entered(body: Node2D):
	if body.has_method("take_damage") and body != get_parent():
		body.take_damage(1) # Deals 1 damage to the Suffocator
