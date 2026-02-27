class_name Player
extends CharacterBody2D

const speed = 100.0
const jump_force = -250.0
const roll_speed = 300.0  # Reduced from 9000 (which is teleport-speed)
const roll_decel = 300.0 # How fast the roll slows down

@onready var animation: AnimatedSprite2D = $animation
@onready var healthbar: HealthBar = $CanvasLayer/Healthbar

@export var health: int

var is_rolling := false

var gravity = 800

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

func _on_healthbar_die() -> void:
	self.queue_free()
