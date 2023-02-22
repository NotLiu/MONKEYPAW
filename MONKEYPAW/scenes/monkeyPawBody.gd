extends StaticBody2D

onready var inRange = false

var pawUI
onready var game = get_tree().get_root().get_node("Main")
# Called when the node enters the scene tree for the first time.
func _ready():
	pawUI = MonkeyPawUi


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if inRange and Input.is_action_just_pressed("ui_accept") and pawUI.visible == false and game.wishes <= 5:
		pawUI.generateExchanges()
		pawUI.readExchange()
		pawUI.visible = true

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		inRange = true

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		inRange = false
