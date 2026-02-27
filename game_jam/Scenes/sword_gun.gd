class_name SwordGun
extends Node2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_box: Area2D = $HitBox # Fixed the casing here

@export var damage: int = 1
@export var offset: Vector2 = Vector2(-30, -30)
@export var lunge_distance: float = 60.0        
@export var attack_speed: float = 0.1           
@export var return_speed: float = 0.2           
@export var idle_rotation: float = 0      

var is_attacking: bool = false

func _ready():
	if hit_box:
		hit_box.monitoring = false
		hit_box.body_entered.connect(_on_hit_box_body_entered)

func _process(delta: float) -> void:
	var idle_target_pos = get_parent().global_position + offset
	
	if not is_attacking:
		global_position = global_position.lerp(idle_target_pos, 15 * delta)
		rotation = lerp_angle(rotation, deg_to_rad(idle_rotation), 10 * delta)
	
	if Input.is_action_just_pressed("left_click"):
		attack(idle_target_pos)
		
func attack(start_pos: Vector2) -> void:
	if is_attacking: 
		return
	is_attacking = true
	animation.play("attack")
	
	if hit_box:
		hit_box.monitoring = true

	var dir_to_mouse = (get_global_mouse_position() - global_position).normalized()
	rotation = dir_to_mouse.angle() 
	
	var tween = create_tween().set_parallel(false)
	
	tween.tween_method(
		func(progress: float): 
			var current_player_back_pos = get_parent().global_position + offset
			global_position = current_player_back_pos + (dir_to_mouse * lunge_distance * progress),
		0.0, 1.0, attack_speed
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	tween.tween_method(
		func(progress: float): 
			var current_player_back_pos = get_parent().global_position + offset
			global_position = current_player_back_pos + (dir_to_mouse * lunge_distance * (1.0 - progress)),
		0.0, 1.0, return_speed
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_callback(func(): 
		is_attacking = false
		if hit_box:
			hit_box.monitoring = false
	)

func _on_hit_box_body_entered(body: Node2D):
	if body.has_method("take_damage") and body != get_parent():
		body.take_damage(damage)
