extends Node2D

onready var durTimer = $durationTimer

func startDash(dur):
	durTimer.wait_time = dur
	durTimer.start()
	
func isDashing():
	return !durTimer.is_stopped()
