extends Node2D

const dashDelay = 0.4
const dodgeDelay = 0.2

onready var player = get_owner()
onready var durTimer = $durationTimer
var canDash = true
var canDodge = true
var dodge = true

func startDash(dur, action):
	durTimer.wait_time = dur
	durTimer.start()
	if (action == "dodge"):
		player.modulate.a = 0.1
		player.get_node("Hurtbox").visible = false
		dodge = true
	#player.get_node("AnimationTree").set("parameters/movement/current", 4)
	
func isDashing():
	return !durTimer.is_stopped()
	
func endDash():
	canDash = false
	canDodge = false
	if (dodge):
		yield(get_tree().create_timer(dodgeDelay), "timeout")
	else:
		yield(get_tree().create_timer(dashDelay), "timeout")
	canDash = true
	if (dodge):
		player.modulate.a = 1
		player.get_node("Hurtbox").visible = true
		yield(get_tree().create_timer(2), "timeout")  # wait 2 seconds before you can dodge again
		canDodge = true
	dodge = false


func _on_durationTimer_timeout():
	endDash()
