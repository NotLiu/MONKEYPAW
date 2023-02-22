extends KinematicBody2D
signal shake

var health = 100
onready var healthBar = $CanvasLayer/healthBar/ProgressBar

var velocity = Vector2.ZERO
export(int) var speed = 200.0
const origSpeed = 200.0
const dashSpeed = 1200.0
const dashDur = .1
const dodgeDur = .1
onready var dash = $Dash
onready var jump = $Jump
onready var BWshader= get_tree().get_root().get_node("Main/Player/BlackAndWhite")

var isAttacking = false

var dir

var abilities = {
				"block": true,
				"attack": true,
				"dash": true,
				"jump": true,
				"dodge": true,
				"color": true,
				"sight": true
				}

onready var swordHitBox = $HitboxPivot/Area2D

func _ready():
	$AnimationTree.active = true
	#pass # Replace with function body.

func _physics_process(delta):
	velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		if (!isAttacking):
			$AnimationTree.set("parameters/movement/current", 1)
		dir = "right"
		velocity.x += 1.0
	if Input.is_action_pressed("ui_left"):
		if (!isAttacking):
			$AnimationTree.set("parameters/movement/current", 1)
		dir = "left"
		velocity.x -= 1.0
	if Input.is_action_pressed("ui_up"):
		if (!isAttacking):
			$AnimationTree.set("parameters/movement/current", 1)
		dir = "up"
		velocity.y -= 1.0
	if Input.is_action_pressed("ui_down"):
		if (!isAttacking):
			$AnimationTree.set("parameters/movement/current", 1)
		dir = "down"
		velocity.y += 1.0
	
	if (velocity == Vector2.ZERO and !isAttacking):
		$AnimationTree.set("parameters/movement/current", 0)
		
	if dir == "right":
		$Sprite.scale.x = 1
		$Sprite.scale.y = 1
		$HitboxPivot.rotation_degrees = 0
		$BlockPivot.rotation_degrees = 0
	if dir == "left":
		$Sprite.scale.x = -1
		$Sprite.scale.y = 1
		$HitboxPivot.rotation_degrees = 180
		$BlockPivot.rotation_degrees = 180
	if dir == "up":
		#$Sprite.scale.y = -1
		$HitboxPivot.rotation_degrees = 270
		$BlockPivot.rotation_degrees = 270
	if dir == "down":
		#$Sprite.scale.y = 1
		$HitboxPivot.rotation_degrees = 90
		$BlockPivot.rotation_degrees = 90		


	# press A to attack
	if (abilities["attack"]):
		if Input.is_action_just_pressed("attack"):
			$AnimationTree.set("parameters/movement/current", 2)
			#$HitboxPivot/Area2D/CollisionShape2D.disabled = false
			isAttacking = true
			yield(get_tree().create_timer(0.6), "timeout")
			isAttacking = false
		#else:
			#$HitboxPivot/Area2D/CollisionShape2D.disabled = true
	if (isAttacking):
		$HitboxPivot/Area2D/CollisionShape2D.disabled = false
	else:
		$HitboxPivot/Area2D/CollisionShape2D.disabled = true
	# press S to block
	if (abilities["block"]):
		if Input.is_action_pressed("block"):
			$AnimationTree.set("parameters/movement/current", 3)
			$BlockPivot/Area2D/CollisionShape2D.disabled = false
		else:
			$BlockPivot/Area2D/CollisionShape2D.disabled = true	
	# press L_SHIFT to dash
	if (abilities["dash"]):
		if Input.is_action_pressed("dash") && dash.canDash && !dash.isDashing():
			dash.startDash(dashDur, "dash")
	var speed = dashSpeed if dash.isDashing() else origSpeed
	
	# press D to dodge
	if (abilities["dodge"]):
		if Input.is_action_pressed("dodge") && dash.canDodge && !dash.isDashing():
			dash.startDash(dodgeDur, "dodge")
	speed = dashSpeed if dash.isDashing() else origSpeed
		
	#abilities["canColor"] = false
	if (abilities["color"]):
		BWshader.turnOnColor()
	else:
		BWshader.turnOffColor()
		
#	if (abilities["jump"]):
#		if Input.is_action_pressed("jump") && jump.canJump && !jump.isJumping():
#			jump.startJump(0.5)
#	set_collision_mask_bit(2, false) if jump.isJumping() else set_collision_mask_bit(2, true)
	
	#abilities["canSight"] = false
	#if (abilities["canSight"]):
	#	get_child(1).visible = false
	#else:
	#	get_child(1).visible = true
			
	
	velocity = velocity.normalized()
	move_and_slide(velocity * speed)

	if velocity != Vector2.ZERO:
		# set sword hitbox knockback vector
		swordHitBox.knockback_vector = velocity



func _on_Hurtbox_area_entered(area):
	print("player getting attacked")
	emit_signal("shake")
	health -= 10
	healthBar.value -= 10
	pass
