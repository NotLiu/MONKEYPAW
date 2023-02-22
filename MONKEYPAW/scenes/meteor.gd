extends Node2D
signal shake

onready var meteor = get_node("meteor")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var hitbox = get_node("Hitbox/CollisionShape2D")
onready var collision = get_node("CollisionShape2D")
onready var hurtbox = get_node("Hurtbox/CollisionShape2D")

var knockback_vector = Vector2(0.0, 0.0)


var fallTime = 0.8
var knockback = 500.0

var hitTimes = 0
var health = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = fallTime
	$Timer.start()
	
	var tw = Tween.new()
	add_child(tw)
	tw.interpolate_property(meteor, "position", Vector2(0.0, -600.0), Vector2(0.0, -5.0), fallTime+0.05)
	tw.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$indicator.scale.x = ($Timer.wait_time - $Timer.time_left) / fallTime
	$indicator.scale.y = ($Timer.wait_time - $Timer.time_left) / fallTime /2.0
	
	if hitbox.disabled == false:
		hitbox.disabled = true
	if hitTimes >= health:
		queue_free()
	

func _on_Timer_timeout():
	hitbox.disabled = false
	hurtbox.disabled = false
	collision.disabled = false
	$indicator.visible = false
	emit_signal("shake")
	#print("meteorPOS: ", position)


func _on_Hitbox_area_entered(area):
	print(area.name)
		


func _on_Hurtbox_area_entered(area):
	var tw = create_tween()
	tw.tween_property(self, "modulate", Color(1,0,0,1), 0.2)
	tw.tween_property(self, "modulate", Color(1,1,1,1), 0.2)
	hitTimes += 1
	print(hitTimes)
	
