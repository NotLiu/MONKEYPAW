extends KinematicBody2D
signal shake

onready var healthBar = $CanvasLayer/healthBar/ProgressBar

var velocity = Vector2.ZERO
export(int) var speed = 400.0
const origSpeed = 200.0
const dashSpeed = 1200.0
const dashDur = .1
const dodgeDur = .1
onready var dash = $Dash
onready var jump = $Jump
onready var BWshader= get_tree().get_root().get_node("Main/Player/BlackAndWhite")

export var maxHealth:float = 150
var health = maxHealth
var revive = false

var knockbackModifier: float = 5
var blockKnockBackModifier: float = 2
var blockDmgModifier = 0.3

var isAttacking = false
var isBlocking = false

#wishes
var reflectDmg = false
var timeSword = false
var achillesHeel = false

onready var timeSwordProj = preload("res://scenes/playerProjectile.tscn")


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
	modulate = Color(1,1,1,1)
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
		if Input.is_action_pressed("attack"):
			if timeSword:
				print("TIMESWORD")
				var projInstance = timeSwordProj.instance()
				projInstance.global_position = self.global_position
				get_tree().get_root().add_child(projInstance)
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
			isBlocking = true
			$AnimationTree.set("parameters/movement/current", 3)
			$BlockPivot/Area2D/CollisionShape2D.disabled = false
		else:
			isBlocking = false
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

func takeDamage(dmg, dmgSource):
	var tw = create_tween()
	tw.tween_property(self, "modulate", Color(1,0,0,1), 0.2)
	tw.tween_property(self, "modulate", Color(1,1,1,1), 0.2)
	if dmgSource.has_method("take_damage") and reflectDmg:
		dmgSource.take_damage(dmg)
	if isBlocking:
		health -= int(dmg * blockDmgModifier) 
	else:
		health -= dmg
	healthBar.value -= dmg/maxHealth*100
	if health <= 0 and revive:
		revive = false
		health = maxHealth/2
	if (health <= 0):
		LevelManager.restart()
		health = 100
		healthBar.value = maxHealth

func receiveKnockback(sourcePos, dmg, modifier):
	var knockbackDir = sourcePos.direction_to(self.global_position)
	var knockbackStr = dmg * modifier
	var knockback = knockbackDir * knockbackStr
	global_position += knockback
	
func _on_Hurtbox_area_entered(area):
	print("player getting attacked")
	if achillesHeel == true and area.get_parent().dmgType == "env":
		takeDamage(30,area.get_parent())
	elif achillesHeel != true:
		takeDamage(10,area.get_parent())
		
	print(isBlocking)
	if isBlocking:
		receiveKnockback(area.global_position, 10, blockKnockBackModifier)
	else:
		receiveKnockback(area.global_position, 10, knockbackModifier)
	emit_signal("shake")

func _on_Area2D_body_entered(body):
	print("ATTACK BLOCKED")
	takeDamage(10, body)
	receiveKnockback(body.global_position, 10 * blockDmgModifier, blockKnockBackModifier)

