extends CharacterBody2D
class_name Player

@export var speed: float = 150.0
@export var jump_force: float = -350.0
@export var health: int = 100

<<<<<<< Updated upstream
# Movement Constants
var speed = 200
var jump_force = -300 # Slightly buffed for better feel
var gravity = 980     # Standard Godot gravity
var roll_speed = 600
var roll_decel = 800
=======
# Gravity from project settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animation: AnimatedSprite2D = $animation
@onready var healthbar: ProgressBar = $CanvasLayer/Healthbar

var is_dead := false
var is_invincible := false
var is_rolling := false # Assuming you have a roll mechanic
>>>>>>> Stashed changes

func _ready():
	# Group the player so enemies can find you
	add_to_group("player")
	
	# Initialize the UI Healthbar
	if healthbar and healthbar.has_method("init_health"):
		healthbar.init_health(health)

func _physics_process(delta):
	if is_dead: return

	# Apply Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force

	# Get movement input (Left/Right)
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = direction * speed
		animation.flip_h = direction < 0
		animation.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		animation.play("idle")

	move_and_slide()

func take_damage(amount: int):
	# Don't take damage if already dead, rolling, or invincible
	if is_dead or is_invincible or is_rolling:
		return
		
	# Apply damage to the custom HealthBar script
	if healthbar:
		if "health" in healthbar:
			healthbar.health -= amount
		else:
			healthbar.value -= amount
	
	# Start Invincibility Frames (I-Frames)
	is_invincible = true
	
	# Visual feedback: Flash the player to show they were hit
	var tween = create_tween()
	tween.tween_property(animation, "modulate:a", 0.5, 0.1)
	tween.tween_property(animation, "modulate:a", 1.0, 0.1)
	tween.set_loops(4) # Flash 4 times
	
	# Check for death
	var current_hp = healthbar.health if "health" in healthbar else healthbar.value
	if current_hp <= 0:
		die()
	
	# Wait 1 second before being able to take damage again
	await get_tree().create_timer(1.0).timeout
	is_invincible = false

func die():
	if is_dead: return
	is_dead = true
	print("Player has died!")
	animation.play("death") # Assuming you have a death animation
	
	# Reload the level after a short delay
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
