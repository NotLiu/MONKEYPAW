extends KinematicBody2D

var health = 500

export var numMeteors = 5
var meteorOnScreen = 0
var slamStarted = false

export var SHOOTCOOLDOWN = 2.0
var actionBuffer = 2.0

# state
enum states{
	IDLE,
	ATTACK,
	SLAM,
	SWIPE
}

var state = states.IDLE
var transitionTrigger = false

# onready var player = get_tree().get_root().get_node("Main/Player")
onready var PlayerDetectionZone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite

# shoot
var shootTriggered = false
export var EnemyProjectile = preload("res://scenes/EnemyProjectile.tscn")
export var meteor = preload("res://scenes/meteor.tscn")

var player
# knockback
export var KNOCKBACK_FORCE = 200

var linear_velocity = Vector2.ZERO
var pupilStartPos

# Called when the node enters the scene tree for the first time.
func _ready():
	$actionTimer.wait_time = actionBuffer
	pupilStartPos = $pupil.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	if player:
		var vector_to_player = (player.global_position - global_position).normalized()
		$pupil.position = pupilStartPos + vector_to_player * 9.0
	else:
		player = PlayerDetectionZone.player

	match state:
		states.IDLE:
			if sprite.animation != "hit" or sprite.frame == 2:
				sprite.animation = "idle"
			if not transitionTrigger:
				end_state()
		states.ATTACK:	
			# shoot at player
			if (!shootTriggered and not transitionTrigger):
				shootTriggered = true
				shoot()
			else:
				state = states.IDLE
				shootTriggered = false
				#$shootCooldown.stop()
		states.SLAM:
			if sprite.animation != "hit" or sprite.frame == 2:
				sprite.animation = "slam"
			if not transitionTrigger and slamStarted == false:
				slamStarted = true
				slam()
		states.SWIPE:
			if sprite.animation != "hit" or sprite.frame == 2:
				sprite.animation = "swipe"
			if not transitionTrigger:
				swipe()
				
			

func end_state():
	state = states.IDLE
	transitionTrigger = true
	slamStarted = false
	$actionTimer.start()

func switch_state():
	var randState = randi()%states.size()
	var stateEnum = states.keys()[randState]
	state = states[stateEnum]
	
	print(stateEnum)

func take_damage(dmg):
	sprite.animation = "hit"
	health -= dmg
	
	print("enemy hit ", health)
	
	if (health <= 0):
		queue_free()
		
		
func seek_player():
	if PlayerDetectionZone.can_see_player():
		state = states.ATTACK
	else:
		state = states.IDLE
		
func swipe():
	pass
	
func slam():
	meteorOnScreen = get_parent().get_tree().get_nodes_in_group("meteor").size()
	if meteorOnScreen < numMeteors:
		var mtr = meteor.instance()
		mtr.global_position = player.global_position
		mtr.z_index = mtr.position[1]*0.1
		get_parent().add_child(mtr)
		print(mtr)
		meteorOnScreen += 1
		$meteorTimer.start()
	else:
		end_state()
		
func shoot():
	#$shootCooldown.wait_time = SHOOTCOOLDOWN * (1 + rand_range(-0.25, 0.25))
	#$shootCooldown.start()

	
	if player != null:
		var enemy_projectile_instance = EnemyProjectile.instance()
		get_tree().get_root().add_child(enemy_projectile_instance)
		enemy_projectile_instance.global_position = global_position
		
		var direction = (player.global_position - global_position).normalized()
		enemy_projectile_instance.global_rotation = direction.angle() + PI / 2.0
		enemy_projectile_instance.direction = direction
	


func _on_shootCooldown_timeout():
	shoot()


func _on_Hurtbox_area_entered(area):
	print("BOSS DMAGE", area.get_parent().name)
	take_damage(20) # change this number based on player mayhaps


func _on_actionTimer_timeout():
	switch_state()
	$actionTimer.stop()
	$actionTimer.wait_time = actionBuffer
	transitionTrigger = false


func _on_AnimatedSprite_animation_finished():
	if not transitionTrigger and sprite.animation != "hit":
		end_state()


func _on_meteorTimer_timeout():
	slam()
	$meteorTimer.stop()
