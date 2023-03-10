extends Node2D
signal shake_request

onready var player = get_node("Player")

var wishes = 0

var meteors = []
var boss = []
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
	if get_tree().get_nodes_in_group("boss") != boss and bossConnected == false:
		boss = get_tree().get_nodes_in_group("boss")
		boss[0].connect("shake", self, "requestShake")
		bossConnected = true
	if player != null and playerConnected == false:
		player.connect("shake", self, "requestShake")
		playerConnected = true
		
	if Input.is_action_just_pressed("debug1") and get_node("/root/LevelManager").curr_level != 4:
		get_node("/root/LevelManager").skipToEnd()
	if Input.is_action_just_pressed("debug2") and get_node("/root/LevelManager").curr_level != 4:
		get_node("/root/LevelManager").skipNextLevel()	
	
func checkWish(data):
	wishes += 1
	
	if wishes < 5:
		$Player/CanvasLayer/monkeyIndicator.nextHand()
		print("WISH: ",data)
		player.abilities[data[1]] = false
		print(player)
			
		if data[0] == "guardianAngel": #if choose wish guardian angel enable revive
			print("REVIVE ENABLED")
			player.revive = true
		elif data[0] == "aegis":
			print("AEGIS EQUIPPED")
			player.blockKnockBackModifier = 0.0
			player.blockDmgModifier = 0.0
		elif data[0] == "blessingOfPerseus":
			print("REFLECTING")
			player.reflectDmg = true
		elif data[0] == "timeSword":
			print("TIMESWORDING")
			player.timeSword = true
		elif data[0] == "deathWish":
			print("SKIPBOSS")
			get_node("/root/LevelManager").skipToEnd()
		elif data[0] == "homeBound":
			print("HOMEBOUND")
			get_tree().change_scene("res://scenes/home.tscn")
		elif data[0] == "blessingOfEir":
			print("GET MECHANIC BACK")
			player.abilities[data[-1]] = true #restore mechanic
		elif data[0] == "achillesHeel":
			print("HEEL IS ACHILLES'D")
			player.achillesHeel = true
			player.knockbackModifier = 10
		
		if player.abilities["sight"]:
			$Player/Light2D.visible = false
		else:
			$Player/Light2D.visible = true
			
func requestShake():
	print("shake request")
	emit_signal("shake_request")
