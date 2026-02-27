extends CharacterBody2D

@export var move_speed: float = 40.0
@export var burst_speed: float = 120.0
@export var health: int = 3

enum State { WALK, BURST, BREATHING, DEAD }
var current_state = State.WALK

var player: Node2D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	$BurstTimer.start() 

func _physics_process(_delta):
	if !player or current_state == State.DEAD: 
		return

	var direction = global_position.direction_to(player.global_position)
	
	match current_state:
		State.WALK:
			velocity = direction * move_speed
		State.BURST:
			velocity = direction * burst_speed
		State.BREATHING:
			velocity = Vector2.ZERO

	if velocity.x != 0:
		$Sprite2D.flip_h = velocity.x < 0
	
	# Visual feedback for states
	if current_state == State.BREATHING:
		$Sprite2D.modulate = Color(1, 0.5, 0.5, 1)
	else:
		$Sprite2D.modulate = Color(1, 1, 1, 1)
		
	move_and_slide()

# --- New Functions ---

func take_damage(amount: int):
	health -= amount
	print("Enemy hit! Health remaining: ", health)
	
	# Flash red when hit
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate", Color.RED, 0.1)
	tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.1)
	
	if health <= 0:
		die()

func die():
	current_state = State.DEAD
	velocity = Vector2.ZERO
	queue_free() # Removes the enemy from the scene

# --- Timer Signals ---

func _on_burst_timer_timeout():
	if current_state == State.WALK:
		current_state = State.BURST
		$BreathTimer.start() 

func _on_breath_timer_timeout():
	if current_state == State.DEAD: return
	
	current_state = State.BREATHING
	
	await get_tree().create_timer(0.8).timeout
	
	if current_state != State.DEAD:
		current_state = State.WALK
		$BurstTimer.start()
