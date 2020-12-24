extends KinematicBody2D


onready var world = get_parent()

var neighbors = []
var path = [] setget path_acquired
var velocity = Vector2.ZERO
export var speed = 300
export var mass = 5
var rotation_speed = 0.2
export var neighbor_limit : = 5

var final_destination_range = 50 #the radius of the mouse
var initial_destination_range = 40

export var alignment_weight : float = .3
export var separation_weight : float = 1
export var cohesion_weight : float = .5
func _ready():
	set_physics_process(false)

#starting click activates the boids
func _input(event):
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT:
		return
	if !event.is_pressed():
		return
	#request path from the parent scene
	world.request_path(global_position, get_global_mouse_position(), self)

func path_acquired(new_value):
	path = new_value
	set_physics_process(true)


func _physics_process(delta):
	#constant change of path is required for smooth pathfinding
	world.request_path(global_position, get_global_mouse_position(), self)
	#check if the boid reached the point, if so, proceed to the next point
	# the final point has a bigger radius since the boids will start to fill in the center
	if path.size() == 1 and global_position.distance_to(path[0]) <= final_destination_range:
		path.remove(0)
	elif global_position.distance_to(path[0]) <= initial_destination_range:
		path.remove(0)
	if path.size() == 0:
		set_physics_process(false)
		return
	#decimal points represents each bahavior's priority
	#desired_velocity is the exact direction to the target
	#velocity is the previous direction of the void
	#steering is to interpolate the previous velocity to the desired_velocity
	#mass represents how fast it will steer, the bigger the mass, the longer it turns
	#to it's desired_velocity
	var desired_velocity = ((path[0] - global_position).normalized() + (separation() * separation_weight) + (alignment() * alignment_weight) + (cohesion() * cohesion_weight)).normalized()
	var steering = desired_velocity - velocity.normalized()
	velocity = ((velocity.normalized()) + ((steering/mass))).normalized()
	#rotate boid to it's velocity's direction
	global_rotation = lerp_angle(rotation,global_position.direction_to(velocity + global_position).angle(),rotation_speed)
	velocity = move_and_slide(velocity * speed)

func separation(): #steer away to other boids to avoid collision
	var Vseparation = Vector2.ZERO
	for i in range(neighbors.size()-1):
			Vseparation += neighbors[i].global_position - global_position	
	Vseparation *= -1
	return Vseparation.normalized()
	
func alignment(): #steer parallel to neigbor's velocity
	var Valignment = Vector2.ZERO
	for i in range(neighbors.size()-1):
		Valignment += (neighbors[i].velocity - neighbors[i].global_position).normalized()
	Valignment.x /= neighbors.size()
	Valignment.y /= neighbors.size()
	return Valignment.normalized()

func cohesion(): #steer to reach the center or sorrounding boids
	var Vcohesion = Vector2.ZERO
	for i in range(neighbors.size()-1):
		Vcohesion += neighbors[i].global_position
	Vcohesion /= neighbors.size()
	return (Vcohesion - global_position).normalized()

func _on_Area2D_body_entered(body):
	if body.is_in_group("Agent") and neighbors.size() <= neighbor_limit:
		neighbors.append(body)


func _on_Area2D_body_exited(body):
	if body.is_in_group("Agent"):
		neighbors.erase(body)
