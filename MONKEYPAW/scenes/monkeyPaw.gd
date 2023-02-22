extends CanvasLayer
signal wish

var wishes = ["guardianAngel", "aegis", "blessingOfPerseus", "timeSword", "deathWish", "homeBound", "blessingOfEir", "achillesHeel"]
var costs = ["block", "attack", "dash", "jump", "dodge", "color", "sight"]

export var wishIcon = []
var removedCosts = []

#key (wishCode) : [0: card title, 1: description, 2:icon]
var monkeyPawTable = {
					"guardianAngel" : ["Guardian Angel", "Revive once with half health", null],
					"aegis": ["Aegis", "The legendary invincible shield, don't take damage upon successful blocking", null],
					"blessingOfPerseus": ["Blessing Of Perseus", "reflect damage to enemies upon being hit", null],
					"timeSword": ["Timeless Sword", "A mythical sword that can cut through time. Attacks linger for several seconds", null],
					"deathWish": ["Death Wish", "A swift and lonely fate", null],
					"homeBound": ["Home Bound", "I just wanna go home..", null],
					"blessingOfEir": ["Blessing of Eir", "Recover a lost skill", null],
					"achillesHeel": ["Achilles Heel", "Become Invincible! Greatly increased player knockback, and environmental damage"]
					}

var pawCostTable = {
					"block" : "YOU MEET A TERRIBLE FATE",
					"attack" : "YOU MEET A TERRIBLE FATE",
					"dash" : "YOU MEET A TERRIBLE FATE",
					"jump" : "YOU MEET A TERRIBLE FATE",
					"dodge" : "YOU MEET A TERRIBLE FATE",
					"color" : "YOU MEET A TERRIBLE FATE",
					"sight" : "YOU MEET A TERRIBLE FATE"
}
var exchanges = {}

onready var card1 = get_node("CenterContainer/HBoxContainer/Card")
onready var card2 = get_node("CenterContainer/HBoxContainer/Card2")
onready var card3 = get_node("CenterContainer/HBoxContainer/Card3")

var cards
var selected = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	cards = get_tree().get_nodes_in_group("card")
	for i in cards:
		i.connect("cardChosen", self, "makeWish")

func generateExchanges():
	#use duplicate temp arrays so that same cards cannot be drawn at the same time
	exchanges.clear()
	var wishTemp = wishes.duplicate()
	var costTemp = costs.duplicate()
	for i in range(3):
		var wishIndex = randi()%wishTemp.size()
		var wish = wishTemp[wishIndex]
		wishTemp.remove(wishIndex)
		var costIndex = randi()%costTemp.size()
		var cost = costTemp[costIndex]
		costTemp.remove(costIndex)
		exchanges[wish] = cost
	print(exchanges)
	
func readExchange():
	#create cards for the exchanges
	var cardNum = 0
	var cards = [card1, card2, card3]
	for i in exchanges:
		cards[cardNum].changeWish(monkeyPawTable[i][0])
		cards[cardNum].changeDesc(monkeyPawTable[i][1])
		cards[cardNum].setCost(exchanges[i])
		cards[cardNum].setWish(i)
		cards[cardNum].setID(cardNum)
		cardNum += 1
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func removeTable(value, array): #remove wishes/ costs from the pool
	var index = array.find(value)
	array.remove(index)

func makeWish(data):
	print("WISH AND COST BEING MADE: ", data)
	var tw = create_tween()
	selected = data[2]
	
	#set animations and data display
	$costCard/RichTextLabel.bbcode_text = "[center]"+data[1]+"[/center]"
	$costCard/RichTextLabel2.bbcode_text = "[center]"+pawCostTable[data[1]]+"[/center]"
	print(selected)
	tw.tween_property($CenterContainer/HBoxContainer, "margin_top", 310.0, 0.10)
	tw.tween_property($CenterContainer/HBoxContainer, "margin_top", 120.0, 0.6)
	tw.set_parallel(true)
	tw.tween_property(cards[(data[2]+1)%3], "modulate", Color(1,1,1,0), 0.9)
	tw.tween_property(cards[(data[2]+2)%3], "modulate", Color(1,1,1,0), 0.9)
	tw.set_parallel(false)
	tw.tween_property($costCard, "modulate", Color(224.0/255.0, 60.0/255.0, 60.0/255.0, 1), 0.1)
	tw.tween_property(cards[(data[2])%3], "modulate", Color(1,1,1,0), 0.1)

	$Timer.start()
	removeTable(data[0], wishes)
	removedCosts.append(data[1])
	removeTable(data[1], costs)
	
	if data[0] == "blessingOfEir":
		var randDict = pawCostTable.keys()
		var healedItem = removedCosts[randi()%removedCosts.size()]
		print(healedItem)
		data.append(healedItem)
		costs.append(healedItem)
		
	emit_signal("wish", data) #emit signal to player to apply wish and costs
	

func resetState():
	$CenterContainer/HBoxContainer.margin_top = 300.0
	for i in cards:
		i.modulate.a = 1.0
	$costCard.modulate.a = 0.0
	selected = 0
	
func _on_CLOSEUI_pressed():
	print("CLOSE")
	visible = false
	resetState()



func _on_Timer_timeout():
	$Timer.stop()
	$Timer.wait_time = 1.5
	
