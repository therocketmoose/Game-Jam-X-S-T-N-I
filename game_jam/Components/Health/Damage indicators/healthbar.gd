extends ProgressBar

@onready var timer: Timer = $Timer
@onready var damage_bar: ProgressBar = $"Damage Bar"

signal die

var health: float = 0 : set = _set_health

func _set_health(new_health: float):
	var prev_health = health
	health = clamp(new_health, 0, max_value)
	value = health
	
	if health <= 0:
		die.emit()
	
	# Damage bar catch-up animation logic
	if health < prev_health:
		timer.start()
	else: 
		damage_bar.value = health

func init_health(_health: float):
	max_value = _health
	health = _health
	value = _health
	if damage_bar:
		damage_bar.max_value = _health	
		damage_bar.value = _health

func _on_timer_timeout():
	if damage_bar:
		damage_bar.value = health
