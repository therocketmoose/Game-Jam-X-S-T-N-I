extends CharacterBody2D

const speed = 200.0
const jump_force = -400.0
const roll_speed = 500.0  # Reduced from 9000 (which is teleport-speed)
const roll_decel = 500.0 # How fast the roll slows down

@onready var animation: AnimatedSprite2D = $animation
@onready var healthbar = $Healthbar


var is_rolling := false

func _ready():
	var health = 100

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := Input.get_axis("move_left", "move_right")

	if Input.is_action_just_pressed("dodge") and is_on_floor() and not is_rolling:
		if direction != 0:
			is_rolling = true
			velocity.x = direction * roll_speed
			animation.play("roll") # Make sure you have a "roll" animation!

	# 3. Movement Logic
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
