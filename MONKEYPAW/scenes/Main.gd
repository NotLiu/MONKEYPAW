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
		meteors = get_tree().get_nodes_in_group("meteor")
		for mtr in meteors:
			mtr.connect("shake", self, "requestShake")
	if $boss != null and bossConnected == false:
		$boss.connect("shake", self, "requestShake")
		bossConnected = true
	if player != null and playerConnected == false:
		player.connect("shake", self, "requestShake")
		playerConnected = true
		
func checkWish(data):
	print("WISH: ",data)
	player.abilities[data[1]] = false
	print(player)
	if player.abilities["sight"]:
		$Player/Light2D.visible = false
	else:
		$Player/Light2D.visible = true
		
	if data[0] == "guardianAngel": #if choose wish guardian angel enable revive
		print("REVIVE ENABLED")
		player.revive = true
	elif data[0] == "aegis":
		print("AEGIS EQUIPPED")
		player.blockKnockBackModifier = 0.0
		player.blockDmgModifier = 0.0
		
func requestShake():
	print("shake request")
	emit_signal("shake_request")
