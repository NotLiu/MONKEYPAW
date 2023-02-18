extends KinematicBody2D


# health
var health = 100

# movement
var speed = 30
var velocity = Vector2.ZERO

# state
enum {
	Surround,
	Attack,
	Hit
}

var state = Surround

onready var player = get_tree().get_root().get_node("Main/Player")

var randomnum

# knockback
var knockback = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	randomnum = rng.randf()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	match state:
		Surround:
			move(get_circle_position(randomnum), delta)
		Attack:
			move(player.global_position, delta)
		Hit:
			move(player.global_position, delta)
			# Attack
	
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)
			

func take_damage(dmg):
	health -= dmg
	print("enemy hit! ", health)
	
	if (health <= 0):
		queue_free()

func move(target, delta):
	var direction = (target - global_position).normalized()
	var desired_velocity = direction * speed
	var steering = (desired_velocity - velocity) * delta * 2.5
	
	velocity += steering
	velocity = move_and_slide(velocity)
	
func get_circle_position(random):
	var kill_circle_centre = player.global_position
	var radius = 40
	var angle = random * PI * 2
	var x = kill_circle_centre.x + cos(angle) * radius
	var y = kill_circle_centre.y + sin(angle) * radius
	
	return Vector2(x, y)


func _on_Hurtbox_area_entered(area):
	# take_damage(20)
	knockback = area.knockback_vector * 120 # need to create knockback_vector as variable in player hitbox
