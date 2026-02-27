class_name Player
extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $animation
@onready var healthbar: HealthBar = $CanvasLayer/Healthbar

# State Booleans
var is_rolling := false
var is_dead := false

@export var health: int = 100

# Movement Constants
var speed = 200
var jump_force = -350 # Slightly buffed for better feel
var gravity = 980     # Standard Godot gravity
var roll_speed = 600
var roll_decel = 800

func _ready():
	healthbar.init_health(health)
	
func _physics_process(delta: float) -> void:
	if is_dead: return # Stop processing if dead

	# 1. Gravity Logic
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 2. Input Handling
	var direction := Input.get_axis("move_left", "move_right")

	# 3. Dodge Roll Logic (Floor only)
	if Input.is_action_just_pressed("dodge") and is_on_floor() and not is_rolling:
		if direction != 0:
			perform_roll(direction)

	# 4. Jump Logic
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_rolling:
		velocity.y = jump_force

	# 5. Horizontal Movement (Air and Ground)
	if not is_rolling:
		if direction != 0:
			velocity.x = direction * speed
			animation.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
		
		# Animation Controller
		update_animations(direction)
	else:
		# Rolling friction
		velocity.x = move_toward(velocity.x, 0, roll_decel * delta)

	move_and_slide()

## Helper function to handle the roll "Wait"
func perform_roll(dir):
	is_rolling = true
	velocity.x = dir * roll_speed
	animation.play("roll")
	
	await animation.animation_finished
	is_rolling = false

## Helper function to organize animations
func update_animations(direction):
	if not is_on_floor():
		if velocity.y < 0:
			animation.play("jump")
		else:
			animation.play("fall") # Make sure you have a "fall" anim!
	else:
		if direction != 0:
			animation.play("walk")
		else:
			animation.play("idle")

func _on_healthbar_die() -> void:
	is_dead = true
	velocity = Vector2.ZERO # Stop movement on death
	animation.play("die")
	await animation.animation_finished
	get_tree().queue_delete(self) # Better than queue_free for testing
