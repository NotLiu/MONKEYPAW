extends KinematicBody2D

var health = 100

export var FRICTION = 200
export var MAX_SPEED = 250
export var MAX_THRUST = 150
export var ACCELERATION = 150

export var SHOOTCOOLDOWN = 2.0

# state
enum {
	IDLE,
	ATTACK
}

var state = IDLE

# onready var player = get_tree().get_root().get_node("Main/Player")
onready var PlayerDetectionZone = $PlayerDetectionZone

# shoot
var shootTriggered = false
export var EnemyProjectile = preload("res://scenes/EnemyProjectile.tscn")


# knockback
var knockback = Vector2.ZERO
export var KNOCKBACK_FORCE = 200

var linear_velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			linear_velocity = linear_velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
		ATTACK:
			var player = PlayerDetectionZone.player
			if player != null:
				# check nearby objects with raycast
				var closest_collision = null
				$rays.rotation += delta + 11 + PI
				for ray in $rays.get_children():
					if ray.is_colliding():
						var collision_point = ray.get_collision_point() - global_position
						if closest_collision == null:
							closest_collision = collision_point
						if collision_point.length() < closest_collision.length():
							closest_collision = collision_point
							
				# dodge
				if closest_collision:
					var normal = -closest_collision.normalized()
					var dodge_direction = 1
					if randf() < 0.5:
						dodge_direction = -1
					linear_velocity = linear_velocity.move_toward(linear_velocity + (normal * MAX_THRUST ), 2 * ACCELERATION * delta)
					linear_velocity = linear_velocity.move_toward(normal.rotated(PI/2 * dodge_direction) * MAX_THRUST, ACCELERATION * delta)
					linear_velocity = move_and_slide(linear_velocity)
					
				
				# Steer towards player
				var distance_to_player = global_position.distance_to(player.global_position)
				var vector_to_player = (player.global_position - global_position).normalized()
				
				if distance_to_player > 200:
					# Move towards player
					linear_velocity = linear_velocity.move_toward(vector_to_player * MAX_THRUST, ACCELERATION * delta)
					linear_velocity = move_and_slide(linear_velocity)
				else:
					# Move away from player
					linear_velocity = linear_velocity.move_toward(-vector_to_player * MAX_THRUST, ACCELERATION * delta)
					linear_velocity = move_and_slide(linear_velocity)
					
				# Clamp max speed
				if linear_velocity.length() > MAX_SPEED:
					linear_velocity = linear_velocity.normalized() * MAX_SPEED
					linear_velocity = move_and_slide(linear_velocity)
					
				# shoot at player
				if (!shootTriggered):
					shootTriggered = true
					shoot()
			else:
				state = IDLE
				shootTriggered = false
				$shootCooldown.stop()


func take_damage(dmg):
	health -= dmg
	
	print("enemy hit ", health)
	
	if (health <= 0):
		queue_free()
		
		
func seek_player():
	if PlayerDetectionZone.can_see_player():
		state = ATTACK
		
func shoot():
	$shootCooldown.wait_time = SHOOTCOOLDOWN * (1 + rand_range(-0.25, 0.25))
	$shootCooldown.start()
	
	#print("shooting")
	var player = PlayerDetectionZone.player
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
	take_damage(20) # change this number based on player mayhaps
	knockback = area.knockback_vector * KNOCKBACK_FORCE
