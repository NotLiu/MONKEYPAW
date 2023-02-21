extends Node2D
signal shake_request

onready var player = get_node("Player")

var meteors = []
var bossConnected = false
var playerConnected = false
# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/MonkeyPawUi").connect("wish", self, "checkWish")
	meteors = get_tree().get_nodes_in_group("meteor")
	for mtr in meteors:
		mtr.connect("shake", self, "requestShake")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if meteors != get_tree().get_nodes_in_group("meteor"):
		for mtr in get_tree().get_nodes_in_group("meteor"):
			mtr.connect("shake", self, "requestShake")
	if $boss != null and bossConnected == false:
		$boss.connect("shake", self, "requestShake")
	if $player!= null and bossConnected == false:
		$boss.connect("shake", self, "requestShake")
func checkWish(data):
	print("WISH: ",data)
	player.abilities[data[1]] = false
	print(player)
	if player.abilities["sight"]:
		$Player/Light2D.visible = false
	else:
		$Player/Light2D.visible = true

func requestShake():
	emit_signal("shake_request")
