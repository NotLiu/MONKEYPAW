extends Node2D


onready var player = get_node("Player")


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/MonkeyPawUi").connect("wish", self, "checkWish")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func checkWish(data):
	print("WISH: ",data)
	player.abilities[data[1]] = false
	print(player)
	if player.abilities["sight"]:
		$Player/Light2D.visible = true
	else:
		$Player/Light2D.visible = false
