extends Node2D

const jumpDelay = 0.4

onready var player = get_owner()
onready var durTimer = $durationTimer
var canJump = true

func startJump(dur):
	durTimer.wait_time = dur
	durTimer.start()
	player.velocity.y -= 50
	
func isJumping():
	return !durTimer.is_stopped()
	
func endJump():
	canJump = false
	yield(get_tree().create_timer(jumpDelay), "timeout")
	canJump = true
	player.velocity.y += 50


func _on_durationTimer_timeout():
	endJump()
