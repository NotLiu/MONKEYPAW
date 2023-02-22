extends TextureRect

var hands = ["res://assets/hand_0.png", "res://assets/hand_1.png", "res://assets/hand_2.png", "res://assets/hand_3.png", "res://assets/hand_4.png"]

var hand = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func nextHand():
	hand += 1
	texture = load(hands[hand])
	
func resetHand():
	hand = 0
	texture = load(hands[hand])
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
