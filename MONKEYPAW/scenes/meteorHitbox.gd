extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var knockback_vector


# Called when the node enters the scene tree for the first time.
func _ready():
	if name == "Hitbox":
		knockback_vector = Vector2(5.0, 5.0)
	else:
		knockback_vector = Vector2.ZERO



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
