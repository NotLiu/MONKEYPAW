extends Node2D


export var levels = ["Level1", "Level2", "Level3", "Level4", "BossLevel"]
export var num_enemies = [2, 4, 4, 6, 5]

var curr_level = 0
var curr_enemies = num_enemies[curr_level]

var root = get_tree().get_root()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (level_complete()):
		load_next_level()
	pass

func level_complete():
	return curr_enemies == 0

func load_next_level():
	# Remove the current level
	var level = root.get_node(levels[curr_level])
	root.remove_child(level)
	level.call_deferred("free")

	# Add the next level
	curr_level += 1
	curr_enemies = num_enemies[curr_level]
	var next_level_resource = load("res://path/to/" + curr_level + ".tscn")
	var next_level = next_level_resource.instance()
	root.add_child(next_level)