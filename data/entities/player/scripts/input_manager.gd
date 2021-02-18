extends Node

onready var parent = get_node("../")
master var movement = Vector3()
var old_movement = Vector3()
var movement_counter = 0
var movement_list = []
var time = 0

func _physics_process(delta):
		send_inputs(delta)
		check_ackowledged_inputs()

func _unhandled_input(event):
	print(event)
	# Client code
	if is_network_master():
		if(event.is_action_pressed("move_left")):
			movement.x = -1
		if(event.is_action_pressed("move_right")):
			movement.x = 1
		if(event.is_action_pressed("move_up")):
			movement.z = -1
		if(event.is_action_pressed("move_down")):
			movement.z = 1
		if(event.is_action_released("move_left")):
			if(movement.x == -1):
				movement.x = 0
		if(event.is_action_released("move_right")):
			if(movement.x == 1):
				movement.x = 0
		if(event.is_action_released("move_up")):
			if(movement.z == -1):
				movement.z = 0
		if(event.is_action_released("move_down")):
			if(movement.z == 1):
				movement.z = 0
		
		if movement != old_movement:
			old_movement = movement

puppet func update_input_on_server(id, movement):
	# Check if the input was processed 
	if movement_counter != id:
		movement_counter = id
		self.movement = movement

# remove last input acknowledged and every older input
func check_ackowledged_inputs():
	while movement_list.size() > 0 && movement_list[0][0] <= parent.ack:
		movement_list.pop_front()
		
func send_inputs(delta):
	movement_counter += 1
	movement_list.push_back([movement_counter, delta, movement])
	if is_network_master():
		update_input_on_server(movement_counter, movement)
	else:
		rpc_unreliable_id(1, "update_input_on_server", movement_counter, movement)

