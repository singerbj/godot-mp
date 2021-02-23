extends Node

onready var player = get_node("../")
onready var debug_info = get_node("../CanvasLayer/DebugInfo")
master var look_direction = Vector3()
var old_look_direction = Vector3()
master var movement = Vector3()
var old_movement = Vector3()
var movement_counter = 0
var movement_list = []
var time = 0
var rot_x = 0
var y_delta
var current_delta

func _physics_process(delta):
		current_delta = delta
		check_ackowledged_inputs()
		if player.control:
			debug_info.text = str(player.ack) + " - " + str(movement_list.size())

func _unhandled_input(event):
	if player.control:
		if event is InputEventMouseMotion:
			# reset rotation
			player.transform.basis = Basis()
			# calculate y delta
			y_delta = event.relative.x * player.mouse_sensitivity
			# rotate in Y
			rot_x += y_delta
			player.rotate_object_local(Vector3(0, -1, 0), rot_x)
			
#			send_look_direction()			
		
		else:
			old_movement = movement
			
			var head_basis = player.get_global_transform().basis
			var dir = Vector3()
			var control_dir = Vector2()
			
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
				send_inputs()		

# remove last input acknowledged and every older input
func check_ackowledged_inputs():
	while movement_list.size() > 0 && movement_list[0][0] <= player.ack:
		movement_list.pop_front()

master func update_input_on_server(incoming_movement_counter, movement):
	# Check if the input was processed 
	if movement_counter != incoming_movement_counter:
		movement_counter = incoming_movement_counter
		self.movement = movement

#master func update_look_direction_on_server(player_transform_basis):
#	player.transform.basis = player_transform_basis
		
func send_inputs():
	print("sending inputs from peer " + str(get_tree().get_network_unique_id()) + ": " + str(movement)) 
	movement_counter += 1
	movement_list.push_back([movement_counter, current_delta, movement])
	yield(get_tree().create_timer(testutils.get_fake_latency() / 1000), "timeout")
	rpc_unreliable_id(1, "update_input_on_server", movement_counter, movement)
	
#func send_look_direction():
#	yield(get_tree().create_timer(testutils.get_fake_latency() / 1000), "timeout")
#	rpc_unreliable_id(1, "update_look_direction_on_server", player.transform.basis)

