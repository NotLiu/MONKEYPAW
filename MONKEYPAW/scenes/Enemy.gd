extends KinematicBody2D


# health
var health = 100

# movement
var velocity = Vector2.ZERO

export var FRICTION = 200
export var ACCELERATION = 300
export var MAX_SPEED = 75

export var SURROUND_RADIUS = 175

# state
enum {
	IDLE,
	SURROUND,
	ATTACK
}

var state = IDLE

# onready var player = get_tree().get_root().get_node("Main/Player")

var randomnum

# knockback
var knockback = Vector2.ZERO
export var KNOCKBACK_FORCE = 250

onready var PlayerDetectionZone = $PlayerDetectionZone
onready var AttackTimer = $AttackTimer
var attackTimerTriggered = false
export var attackTimerInterval = 1.5 # time before it transitions from surround to attack
export var ATTACK_INTERVAL = 1
var isAttacking = false
var dmgType = "melee"

# Called when the node enters the scene tree for the first time.
func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	randomnum = rng.randf()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta * 1000)
	
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
		SURROUND:
			var player = PlayerDetectionZone.player
			if (player != null):
				move(get_circle_position(player, randomnum), delta)
				
				if (!attackTimerTriggered):
					var distance_to_player = global_position.distance_to(player.global_position)
					if (distance_to_player <= SURROUND_RADIUS):
						triggerAttackTimer()
					else:
						AttackTimer.stop()
						# print("stopping")
			else:
				state = IDLE
		ATTACK:
			var player = PlayerDetectionZone.player
			if (player != null):
				move(player.global_position, delta)
				# var direction = (player.global_position - global_position).normalized()
				# velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
				
				# Attack
				var distance_to_player = global_position.distance_to(player.global_position)
				var vector_to_player = (player.global_position - global_position).normalized()
				if (distance_to_player <= 75):
					if (!isAttacking):
						attack()
						isAttacking = true
				else:
					isAttacking = false
					$AttackInterval.stop()
					$Hitbox/CollisionShape2D.disabled = true
				
			else:
				state = SURROUND
				
	velocity = move_and_slide(velocity + knockback)
			
func seek_player():
	if PlayerDetectionZone.can_see_player():
		state = SURROUND

func triggerAttackTimer():
	attackTimerTriggered = true
	AttackTimer.start(attackTimerInterval)
	

func take_damage(dmg):
	health -= dmg
	var tw = create_tween()
	tw.tween_property(self, "modulate", Color(1,0,0,1), 0.2)
	tw.tween_property(self, "modulate", Color(1,1,1,1), 0.2)
	print("enemy hit! ", health)
	
	if (health <= 0):
		LevelManager.curr_enemies -= 1
		print(LevelManager.curr_enemies)
		queue_free()

func attack():
	$AttackInterval.start()
	
	$Hitbox/CollisionShape2D.disabled = false
	#print("enemy attacking")
	
	# simulate enemy retreat/dodge after attacking
	knockback = -velocity * 4.5
	

	

func move(target, delta):
	var direction = (target - global_position).normalized()
	var desired_velocity = direction * MAX_SPEED
	var steering = (desired_velocity - velocity) * delta * 2.5
	
	velocity += steering
	velocity = move_and_slide(velocity)
	
func get_circle_position(target, random):
	var kill_circle_centre = target.global_position
	var angle = random * PI * 2
	var x = kill_circle_centre.x + cos(angle) * SURROUND_RADIUS
	var y = kill_circle_centre.y + sin(angle) * SURROUND_RADIUS
	
	return Vector2(x, y)


func _on_Hurtbox_area_entered(area):
	take_damage(20) # change this number based on player mayhaps
	knockback = area.knockback_vector * KNOCKBACK_FORCE
	


func _on_AttackTimer_timeout():
	state = ATTACK
	attackTimerTriggered = false


func _on_AttackInterval_timeout():
	$Hitbox/CollisionShape2D.disabled = true
	attack()


func _on_BlockDetector_area_entered(area):
	# simulate enemy retreat/dodge after attacking
	var player = PlayerDetectionZone.player
	if player != null:
		var distance_to_player = global_position.distance_to(player.global_position)
		if (distance_to_player <= 75):
			knockback = -velocity * 5
			
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	randomnum = rng.randf()
	state = SURROUND
	
