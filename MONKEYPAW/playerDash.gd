extends Node2D

const dashDelay = 0.4

onready var durTimer = $durationTimer
var canDash = true

func startDash(dur):
	durTimer.wait_time = dur
	durTimer.start()
	
func isDashing():
	return !durTimer.is_stopped()
	
func endDash():
	canDash = false
	yield(get_tree().create_timer(dashDelay), "timeout")
	canDash = true


func _on_durationTimer_timeout():
	endDash()
