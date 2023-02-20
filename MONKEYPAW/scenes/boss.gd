extends KinematicBody2D

var health = 100

export var FRICTION = 200
export var MAX_SPEED = 250
export var MAX_THRUST = 150
export var ACCELERATION = 150

export var SHOOTCOOLDOWN = 2.0
var actionBuffer = 1.0

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

# shoot
var shootTriggered = false
export var EnemyProjectile = preload("res://scenes/EnemyProjectile.tscn")


# knockback
export var KNOCKBACK_FORCE = 200

var linear_velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	$actionTimer.wait_time = actionBuffer


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	match state:
		states.IDLE:
			linear_velocity = linear_velocity.move_toward(Vector2.ZERO, FRICTION * delta)
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
			if not transitionTrigger:
				print("SLAM")
				slam()
		states.SWIPE:
			if not transitionTrigger:
				print("SWIPE")
				swipe()
				
			

func end_state():
	state = states.IDLE
	transitionTrigger = true
	$actionTimer.start()

func switch_state():
	var randState = randi()%states.size()
	state = states[states.keys()[randState]]
	print(state)

func take_damage(dmg):
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
	end_state()
	
func slam():
	end_state()
		
func shoot():
	#$shootCooldown.wait_time = SHOOTCOOLDOWN * (1 + rand_range(-0.25, 0.25))
	#$shootCooldown.start()

	var player = PlayerDetectionZone.player
	if player != null:
		var enemy_projectile_instance = EnemyProjectile.instance()
		get_tree().get_root().add_child(enemy_projectile_instance)
		enemy_projectile_instance.global_position = global_position
		
		var direction = (player.global_position - global_position).normalized()
		enemy_projectile_instance.global_rotation = direction.angle() + PI / 2.0
		enemy_projectile_instance.direction = direction
	if not transitionTrigger:
		end_state()
	


func _on_shootCooldown_timeout():
	shoot()


func _on_Hurtbox_area_entered(area):
	take_damage(20) # change this number based on player mayhaps


func _on_actionTimer_timeout():
	switch_state()
	$actionTimer.stop()
	$actionTimer.wait_time = actionBuffer
