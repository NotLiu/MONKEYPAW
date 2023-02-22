extends Node2D


export var levels = ["Level1", "Level2", "Level3", "Level4", "BossLevel"]
export var num_enemies = [2, 4, 4, 5, 5]

var curr_level = 0
var curr_enemies = num_enemies[curr_level]

onready var root = get_tree().get_root()
onready var NextLevelTriggerSprite = get_tree().get_root().get_node("Main/NextLevelTrigger/Sprite")
onready var NextLevelTriggerCollision = get_tree().get_root().get_node("Main/NextLevelTrigger/Area2D/CollisionShape2D")

signal zero_enemies


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("CURRLEVEL",curr_level)
	#if (level_complete()):
		#toggleTrigger(true)
	#else:
		#toggleTrigger(false)
	if (level_complete()):
		emit_signal("zero_enemies")
	
	pass

func level_complete():
	return curr_enemies == 0

func toggleTrigger(val):
	NextLevelTriggerSprite.visible = val
	NextLevelTriggerCollision.set_deferred("disabled", !val)
	
func restart():
	print(curr_level)
	var level = root.get_node("Main/" + levels[curr_level])
	root.get_node("Main").remove_child(level)
	#level.call_deferred("free")
	
	toggleTrigger(false)
	curr_level = 0

	curr_enemies = num_enemies[0]
	var restart_level_resource = load("res://scenes/Level1.tscn")
	var restart_level = restart_level_resource.instance()
	root.get_node("Main").add_child(restart_level)

func load_next_level():
	# Remove the current level
	var level = root.get_node("Main/" + levels[curr_level])
	root.get_node("Main").remove_child(level)
	level.call_deferred("free")

	toggleTrigger(false)

	# Add the next level
	if (curr_level <= (len(levels) - 2)):
		curr_level += 1
		curr_enemies = num_enemies[curr_level]
		var next_level_resource = load("res://scenes/" + levels[curr_level] + ".tscn")
		var next_level = next_level_resource.instance()
		root.get_node("Main").add_child(next_level)

func skipToEnd():
	var enemies = get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		e.queue_free()
	var level = root.get_node("Main/" + levels[curr_level])
	print(root.get_node("Main/" + levels[curr_level]))
	root.get_node("Main").remove_child(level)
	level.call_deferred("free")
	
	toggleTrigger(false)
	var lastLevel = load("res://scenes/BossLevel.tscn")
	root.get_node('Main').add_child(lastLevel.instance())
	curr_level = 4
	
func skipNextLevel():
	var enemies = get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		e.queue_free()
	load_next_level()
	
func _on_LevelManager_zero_enemies():
	toggleTrigger(true)
