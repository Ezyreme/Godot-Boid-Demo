extends Node2D

onready var nav = get_node("Navigation2D")
var boid = preload("res://Agent.tscn")
func _ready():
	pass # Replace with function body.


#give path to requesting boid
func request_path(from, to, who):
	who.path = nav.get_simple_path(from, to, true)
	
	
#adding boid after click
func _input(event):
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT:
		return
	if !event.is_pressed():
		return
	var boid_instance = boid.instance()
	boid_instance.global_position = Vector2.ZERO
	call_deferred("add_child", boid_instance)
	
