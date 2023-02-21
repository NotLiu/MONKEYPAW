extends Camera2D

var timer = Timer.new()

export var amplitude = 2.0
export var duration = 0.45
export var damp_easing = 1.0
export var shake = false

var game

func _ready():
	timer.connect("timeout", self, "_on_Timer_timeout")
	add_child(timer)
	randomize()
	set_process(false)
	game = get_tree().get_root().get_node("Main")
	game.connect("shake_request", self, "_on_shake_request")


func _process(delta):
	if shake:
		damp_easing = ease(timer.time_left / timer.wait_time, 1.0)
		offset = Vector2(rand_range(amplitude, -amplitude) * damp_easing, rand_range(amplitude, -amplitude) * damp_easing)
		zoom = Vector2(1.0 - damp_easing/(100.0/amplitude), 1.0 - damp_easing/(100.0/amplitude))
	
func _on_Timer_timeout():
	shake = false
	zoom = Vector2(1.0, 1.0)
	set_process(false)
	timer.stop()
	
func _on_shake_request():
	print("SHAKECAMERA")
	shake = true
	set_duration(duration)
	set_process(true)
	
func set_duration(value):
	timer.wait_time = value
	timer.start()

