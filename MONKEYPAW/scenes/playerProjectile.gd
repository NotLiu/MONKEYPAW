extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var lifetime = 3.0

onready var timer = $Timer
# Called when the node enters the scene tree for the first time.
func _ready():
	timer.connect("timeout", self, "queue_free")
	timer.start(lifetime)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Hitbox_area_entered(area):
	queue_free()
