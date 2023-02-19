extends Control
signal cardChosen

export var icons = {"aegis": null,}

onready var textBut = get_node("TextureButton")
onready var wish = get_node("TextureButton/CenterContainer/VBoxContainer/wish")
onready var desc = get_node("TextureButton/CenterContainer/VBoxContainer/description")
onready var icon = get_node("TextureButton/CenterContainer/VBoxContainer/icon")

var cost = ""
var wishCode = ""
var id = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func changeWish(text):
	wish.bbcode_text = "[center]"+text+"[/center]"

func changeDesc(text):
	desc.bbcode_text = "[center]"+text+"[/center]"

func changeIcon(iconName):
	icon.texture = load(icons[iconName])

func setCost(text):
	cost = text

func setWish(text):
	wishCode = text
	
func setID(cardID):
	id = cardID

func _on_TextureButton_pressed():
	emit_signal("cardChosen", [wishCode, cost, id])
