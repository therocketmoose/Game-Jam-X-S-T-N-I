extends CharacterBody2D

@export var move_speed: float = 40.0
@export var burst_speed: float = 120.0
@export var max_health: int = 80 
@export var damage_amount: int = 10 
@export var jump_force: float = -300.0
@export var safe_drop_distance: float = 150.0 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var knockback_velocity := Vector2.ZERO

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var burst_timer: Timer = $"Burst Timer"
@onready var breath_timer: Timer = $"Breath Timer"
@onready var wall_check: RayCast2D = $WallCheck
@onready var ledge_check: RayCast2D = $LedgeCheck
@onready var health_bar: ProgressBar = $Healthbar 

enum State { WALK, BURST, BREATHING, DEAD }
var current_state = State.WALK
var player: CharacterBody2D 
var facing_direction: int = 1 

func _ready():
	# Bulletproof search: finds a CharacterBody2D named "player"
	var root = get_tree().get_root()
	var potential_players = root.find_children("player", "CharacterBody2D", true, false)
	if potential_players.size() > 0:
		player = potential_players[0]
			
	if health_bar and health_bar.has_method("init_health"):
		health_bar.init_health(max_health)
	
	burst_timer.start() 
	ledge_check.target_position.y = safe_drop_distance

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if !player or current_state == State.DEAD: 
		move_and_slide()
		return

	var dir_to_player = sign(player.global_position.x - global_position.x)
	if dir_to_player == 0: dir_to_player = facing_direction 
	
	var move_dir = dir_to_player
	
	if is_on_floor():
		if not ledge_check.is_colliding():
			move_dir = 0 
		elif wall_check.is_colliding():
			velocity.y = jump_force

	match current_state:
		State.WALK: velocity.x = move_dir * move_speed
		State.BURST: velocity.x = move_dir * burst_speed
		State.BREATHING: velocity.x = move_toward(velocity.x, 0, move_speed) 

	if velocity.x != 0:
		facing_direction = -1 if velocity.x < 0 else 1
		sprite_2d.flip_h = velocity.x < 0
		wall_check.target_position.x = abs(wall_check.target_position.x) * facing_direction
		ledge_check.position.x = abs(ledge_check.position.x) * facing_direction
	
	# Color feedback
	if current_state == State.BURST:
		sprite_2d.modulate = Color.RED
	elif current_state == State.BREATHING:
		sprite_2d.modulate = Color(0.7, 0.7, 1.0)
	else:
		sprite_2d.modulate = Color.WHITE
		
	velocity += knockback_velocity
	move_and_slide()
	knockback_velocity = lerp(knockback_velocity, Vector2.ZERO, 0.1)
	
	# Damage player on contact
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.has_method("take_damage") and collider == player:
			collider.take_damage(damage_amount)

func take_damage(amount: int):
	if health_bar:
		if "health" in health_bar:
			health_bar.health -= amount
		else:
			health_bar.value -= amount
		
		# Apply Knockback
		if player:
			var knock_dir = sign(global_position.x - player.global_position.x)
			knockback_velocity = Vector2(knock_dir * 400, -120)
		
		var current_hp = health_bar.health if "health" in health_bar else health_bar.value
		if current_hp <= 0: die()

func die():
	current_state = State.DEAD
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
