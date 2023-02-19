extends RigidBody2D

var health = 100

export var FRICTION = 200
export var MAX_SPEED = 150
export var MAX_THRUST = 150

# state
enum {
	IDLE,
	ATTACK
}

var state = IDLE

# onready var player = get_tree().get_root().get_node("Main/Player")
onready var PlayerDetectionZone = $PlayerDetectionZone

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
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
					linear_velocity += normal * MAX_THRUST * 2 * delta
					linear_velocity += normal.rotated(PI/2 * dodge_direction) * MAX_THRUST * delta
					
				
				# Steer towards player
				var distance_to_player = global_position.distance_to(player.global_position)
				var vector_to_player = (player.global_position - global_position).normalized()
				
				if distance_to_player > 200:
					# Move towards player
					linear_velocity += vector_to_player * MAX_THRUST * delta
				else:
					# Move away from player
					linear_velocity += -vector_to_player * MAX_THRUST * delta
					
				# Clamp max speed
				if linear_velocity.length() > MAX_SPEED:
					linear_velocity = linear_velocity.normalized() * MAX_SPEED
			else:
				state = IDLE


func take_damage(dmg):
	health -= dmg
	
	if (health <= 0):
		queue_free()
		
		
func seek_player():
	if PlayerDetectionZone.can_see_player():
		state = ATTACK
