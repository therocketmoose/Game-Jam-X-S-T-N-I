extends Area2D

@export var speed: float = 300.0
@export var damage: int = 10

var direction: int = 1 # 1 for right, -1 for left

func _physics_process(delta):
	# Move the fireball horizontally every frame
	position.x += direction * speed * delta

# Connect the "body_entered" signal of the Area2D to this function
func _on_body_entered(body):
	# If it hits the player, deal damage and disappear
	if body is Player:
		body.take_damage(damage)
		queue_free()
	
	# If it hits a wall/floor (often a TileMap or StaticBody2D), destroy it
	elif not body.is_in_group("enemy"): # Ignores the enemy that threw it
		queue_free()
