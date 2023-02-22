extends KinematicBody2D


var health = 100

# movement
var velocity = Vector2.ZERO
export var FRICTION = 200
export var ACCELERATION = 100
export var MAX_SPEED = 250

# state
enum {
	IDLE,
	ATTACK_IDLE,
	ATTACK
}

var state = IDLE

# knockback
var knockback = Vector2.ZERO
export var KNOCKBACK_FORCE = 200

# player detection zone
onready var PlayerDetectionZone = $PlayerDetectionZone

# transition to attack state
onready var AttackTimer = $AttackTimer
var attackTriggered = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			$AnimationTree.set("parameters/movement/current", 0)
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
			velocity = move_and_slide(velocity)
		ATTACK_IDLE:
			$AnimationTree.set("parameters/movement/current", 1)
			var player = PlayerDetectionZone.player
			if (player != null):
				if (!attackTriggered):
					AttackTimer.connect("timeout", self, "target_player", [delta])
					AttackTimer.start()
					attackTriggered = true
			else:
				AttackTimer.stop()
				attackTriggered = false
				state = IDLE
					
			velocity = move_and_slide(velocity)
		ATTACK:
			$AnimationTree.set("parameters/movement/current", 1)
			var player = PlayerDetectionZone.player
			if (player != null):
				var collision_info = move_and_collide(velocity * delta)
				if (collision_info):
					velocity = velocity.bounce(collision_info.normal)
			else:
				state = ATTACK_IDLE
				attackTriggered = false
			
			
	# velocity = move_and_slide(velocity)

func seek_player():
	if PlayerDetectionZone.can_see_player():
		state = ATTACK_IDLE

func target_player(delta):
	print("targetting player")
	var player = PlayerDetectionZone.player 
	if player != null:
		var direction = (player.global_position - global_position).normalized()
		velocity = move_and_slide(direction * MAX_SPEED * ACCELERATION * delta)
		state = ATTACK
		AttackTimer.stop()
		
func take_damage(dmg):
	$AnimationTree.set("parameters/movement/current", 2)
	health -= dmg
	
	if (health <= 0):
		queue_free()

func _on_ChargeArea_body_exited(body):
	state = ATTACK_IDLE
	attackTriggered = false
	velocity = Vector2.ZERO


func _on_Hurtbox_area_entered(area):
	take_damage(20) # replace this based on player atk
	knockback = area.knockback_vector * KNOCKBACK_FORCE


func _on_BlockDetector_area_entered(area):
	"""
	var player = PlayerDetectionZone.player
	if player != null:
		state = ATTACK_IDLE
		attackTriggered = false
		velocity = Vector2.ZERO
	"""
	pass
