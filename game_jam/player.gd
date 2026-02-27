class_name Player
extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $animation
@onready var healthbar: HealthBar = $CanvasLayer/Healthbar

var is_rolling := false
var is_dead := false
var is_invincible := false # Protects player from instant multi-hits

@export var health: int

var speed = 200
var jump_force = -300
var gravity = 800
var roll_speed = 300
var roll_decel = 300

func _ready():
	healthbar.init_health(health)
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction := Input.get_axis("move_left", "move_right")

	if Input.is_action_just_pressed("dodge") and is_on_floor() and not is_rolling:
		if direction != 0:
			is_rolling = true
			velocity.x = direction * roll_speed
			animation.play("roll")

	# Movement Logic
	if not is_dead:
		if is_rolling:
			# Decelerate the roll until it hits normal speed
			velocity.x = move_toward(velocity.x, 0, roll_decel * delta)
			
			# End roll when slow enough
			if abs(velocity.x) <= speed:
				is_rolling = false
		else:
			# Standard Movement
			if direction:
				velocity.x = direction * speed
				animation.flip_h = direction < 0
				animation.play("walk")
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				animation.play("idle")
	
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_rolling:
		velocity.y = jump_force

	move_and_slide()

# --- Combat Logic ---

func take_damage(amount: int):
	# Ignore damage if dead, dodging, or currently in i-frames
	if is_dead or is_rolling or is_invincible:
		return
		
	# Trigger i-frames and apply damage
	is_invincible = true
	healthbar.health -= amount
	
	# Visual feedback: Flash the player sprite to show invincibility
	var tween = create_tween()
	tween.tween_property(animation, "modulate:a", 0.3, 0.1) # Fade out slightly
	tween.tween_property(animation, "modulate:a", 1.0, 0.1) # Fade back in
	tween.set_loops(5) # Repeat the flash 5 times (takes 1 second total)
	
	# Wait for 1 second, then remove invincibility
	await get_tree().create_timer(1.0).timeout
	is_invincible = false
	animation.modulate.a = 1.0 # Ensure opacity is fully reset

func _on_healthbar_die() -> void:
	is_dead = true
	animation.play("die")
	await animation.animation_finished
	self.queue_free()
