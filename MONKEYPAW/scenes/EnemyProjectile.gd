extends KinematicBody2D


# Declare member variables here. Examples:
var direction : Vector2 = Vector2.LEFT
var speed : float = 250

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(direction * speed * delta)
