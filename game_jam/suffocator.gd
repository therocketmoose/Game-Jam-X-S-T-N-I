extends CharacterBody2D

@export var move_speed: float = 40.0
@export var burst_speed: float = 120.0
@export var health: int = 3
@export var damage_amount: int = 5  # Lowered from 10 to 5
@export var jump_force: float = -300.0
@export var safe_drop_distance: float = 150.0 
@export var attack_rate = 1

var is_attacking = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var burst_timer: Timer = $"Burst Timer"
@onready var breath_timer: Timer = $"Breath Timer"
@onready var wall_check: RayCast2D = $WallCheck
@onready var ledge_check: RayCast2D = $LedgeCheck
@onready var s_health_bar: ProgressBar = $SHealthBar

enum State { WALK, BURST, BREATHING, DEAD }
var current_state = State.WALK

var player: Player
var facing_direction: int = 1 

func _ready():
	player = get_tree().get_first_node_in_group("player") as Player
	burst_timer.start() 
	
	if s_health_bar:
		s_health_bar.max_value = health
		s_health_bar.value = health
	
	if ledge_check:
		ledge_check.target_position.y = safe_drop_distance

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if !player or current_state == State.DEAD: 
		move_and_slide()
		return

	var dir_to_player = sign(player.global_position.x - global_position.x)
	if dir_to_player == 0:
		dir_to_player = facing_direction 
	
	var move_dir = dir_to_player
	
	if is_on_floor():
		if not ledge_check.is_colliding():
			move_dir = 0 
		elif wall_check.is_colliding():
			velocity.y = jump_force

	match current_state:
		State.WALK:
			velocity.x = move_dir * move_speed
		State.BURST:
			velocity.x = move_dir * burst_speed
		State.BREATHING:
			velocity.x = move_toward(velocity.x, 0, move_speed) 

	if velocity.x != 0:
		facing_direction = -1 if velocity.x < 0 else 1
		sprite_2d.flip_h = velocity.x < 0
		wall_check.target_position.x = abs(wall_check.target_position.x) * facing_direction
		ledge_check.position.x = abs(ledge_check.position.x) * facing_direction
		
		# Keep HealthBar from flipping
		if s_health_bar:
			s_health_bar.scale.x = abs(s_health_bar.scale.x) * (1 if not sprite_2d.flip_h else -1)
	
	if current_state == State.BURST:
		sprite_2d.modulate = Color.RED 
	elif current_state == State.BREATHING:
		sprite_2d.modulate = Color(0.7, 0.7, 1.0, 1) 
	else:
		sprite_2d.modulate = Color.WHITE
		
	move_and_slide()
	
	# COLLISION WITH PLAYER
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is Player and not is_attacking:
			is_attacking = true
			var healthbar: HealthBar = collider.get_node("CanvasLayer/Healthbar")
			healthbar.take_damage(damage_amount)
			
			await get_tree().create_timer(attack_rate).timeout
			is_attacking = false

func take_damage(amount: int):
	health -= amount
	if s_health_bar:
		s_health_bar.value = health
		
	var tween = create_tween()
	tween.tween_property(sprite_2d, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite_2d, "modulate", Color.WHITE, 0.1)
	
	if health <= 0:
		die()

func die():
	current_state = State.DEAD
	velocity = Vector2.ZERO
	if s_health_bar:
		s_health_bar.hide()
	queue_free() 

func _on_burst_timer_timeout():
	if current_state == State.WALK:
		current_state = State.BURST
		breath_timer.start() 

func _on_breath_timer_timeout():
	if current_state == State.DEAD: return
	current_state = State.BREATHING
	await get_tree().create_timer(0.8).timeout
	if current_state != State.DEAD:
		current_state = State.WALK
		burst_timer.start()
