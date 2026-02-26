extends CharacterBody2D

@export var move_speed: float = 40.0
@export var burst_speed: float = 120.0
@export var health: int = 3

var player: Node2D
var is_bursting: bool = false
var is_breathing: bool = false

func _ready():
	player = get_tree().get_first_node_in_group("player")
	
func _physics_process(delta):
	if player == null:
		return

	if is_breathing:
		velocity = Vector2.ZERO
	else:
		var direction = (player.global_position - global_position).normalized()
		
		if is_bursting:
			velocity = direction * burst_speed
		else:
			velocity = direction * move_speed
	
	if velocity.x < 0:
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false	
	move_and_slide()
	
func _on_burst_timer_timeout():
	if is_breathing:
		return

	is_bursting = true
	$BreathTimer.start()

func _on_breath_timer_timeout():
	is_bursting = false
	is_breathing = true
	await get_tree().create_timer(0.6).timeout
	is_breathing = false

func take_damage(amount: int):
	health -= amount
	
	if health <= 0:
		die()

func die():
	queue_free()
