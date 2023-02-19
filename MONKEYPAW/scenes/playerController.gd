extends KinematicBody2D

export(int) var speed = 200.0
var dir

onready var swordHitBox = $HitboxPivot/Area2D

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		dir = "right"
		velocity.x += 1.0
	if Input.is_action_pressed("ui_left"):
		dir = "left"
		velocity.x -= 1.0
	if Input.is_action_pressed("ui_up"):
		dir = "up"
		velocity.y -= 1.0
	if Input.is_action_pressed("ui_down"):
		dir = "down"
		velocity.y += 1.0
		
	if dir == "right":
		$Sprite.scale.x = 1
		$Sprite.scale.y = 1
		$HitboxPivot.rotation_degrees = 0

	if dir == "left":
		$Sprite.scale.x = -1
		$Sprite.scale.y = 1
		$HitboxPivot.rotation_degrees = 180

	if dir == "up":
		$Sprite.scale.y = -1
		$HitboxPivot.rotation_degrees = 270

	if dir == "down":
		$Sprite.scale.y = 1
		$HitboxPivot.rotation_degrees = 90


	# press A to attack
	if Input.is_action_pressed("attack"):
		$HitboxPivot/Area2D/CollisionShape2D.disabled = false
	else:
		$HitboxPivot/Area2D/CollisionShape2D.disabled = true
	
	
	
	velocity = velocity.normalized()
	move_and_slide(velocity * speed)

	if velocity != Vector2.ZERO:
		# set sword hitbox knockback vector
		swordHitBox.knockback_vector = velocity



func _on_Hurtbox_area_entered(area):
	print("player getting attacked")
