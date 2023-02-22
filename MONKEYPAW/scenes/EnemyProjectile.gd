extends KinematicBody2D


# Declare member variables here. Examples:
var direction : Vector2 = Vector2.LEFT
var speed : float = 250
var lifetime : float = 20
var dmgType = "projectile"

onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.connect("timeout", self, "queue_free")
	timer.start(lifetime)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(direction * speed * delta)


func _on_Hitbox_area_entered(area):
	if area.get_parent().get_parent().name == "Player":
		area.get_parent().get_parent().takeDamage(10, self)
	queue_free()
