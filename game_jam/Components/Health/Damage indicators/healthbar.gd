class_name HealthBar
extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $"Damage Bar"

@export var player: Player

signal die

var health = 0 : set = _set_health

func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	
	if health <= 0:
		die.emit()
	
	# Color changing logic based on health percentage
	if health <= 80:
		if health <= 20:
			player.animation.modulate = Color(1, 0, 0, 1.0) # Dark Red
		elif health <= 40:
			player.animation.modulate = Color(1, 0.3, 0.3, 1)
		elif health <= 60:
			player.animation.modulate = Color(1, 0.6, 0.6, 1)
		else: # 80 to 61
			player.animation.modulate = Color(1, 1, 1, 0.8) # Faded
	else:
		player.animation.modulate = Color(1, 1, 1, 1)
	
	# Damage bar catch-up animation logic
	if health < prev_health:
		timer.start()
	else: 
		damage_bar.value = health
			
func init_health(_health):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health	
	damage_bar.value = health

func _on_timer_timeout():
	damage_bar.value = health
