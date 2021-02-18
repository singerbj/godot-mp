extends KinematicBody

export var is_sprinting = false
export var player_id = 0
export var control = false

export var speed = 10
export var sprint_speed = 15
export var acceleration = 10
export var gravity = 0.98
export var jump_y_power = 50
export var mouse_sensitivity = 0.00075

master var remote_movement = Vector3()
puppet var remote_transform = Transform()
puppet var remote_vel = Vector3()
puppet var ack = 0
var time = 0

var velocity = Vector3()
var rot_x = 0
var y_delta

func _ready():
	set_network_master(1)

func _input(event):
	if control == true and event is InputEventMouseMotion:
		# reset rotation
		self.transform.basis = Basis()
		# calculate y delta
		y_delta = event.relative.x * mouse_sensitivity
		# rotate in Y
		rot_x += y_delta
		rotate_object_local(Vector3(0, -1, 0), rot_x)
				
func _physics_process(delta):
	if is_network_master():
			move_and_slide(velocity + ($InputManager.movement.normalized() * speed))
			rpc_unreliable("update_state",transform, get_floor_velocity(), $InputManager.movement_counter)
	else:
		# Client code
		time += delta
		move_with_reconciliation(delta)

func move_with_reconciliation(delta):
	var old_transform = transform
	transform = remote_transform
	var vel = remote_vel
	var movement_list = $InputManager.movement_list
	if movement_list.size() > 0:
		for i in range(movement_list.size()):
			var mov = movement_list[i]
			vel = move_and_slide(mov[2].normalized()* speed * mov[1] / delta)
	
	interpolate(old_transform)

func interpolate(old_transform):
	var scale_factor = 0.1
	var dist = transform.origin.distance_to(old_transform.origin)
	var weight = clamp(pow(2, dist / 4) * scale_factor, 0.0, 1.0)
	transform.origin = old_transform.origin.linear_interpolate(transform.origin,weight)

puppet func update_state(t, velocity, ack):
	self.remote_transform = t
	self.remote_vel = velocity
	self.ack = ack

#	if control == true:
#		var head_basis = self.get_global_transform().basis
#		var dir = Vector3()
#		var control_dir = Vector2()
#
#		if Input.is_action_pressed("move_up"):
#			dir -= head_basis.z
#			control_dir.y += 1
#		if Input.is_action_pressed("move_down"):
#			dir += head_basis.z
#			control_dir.y -= 1
#		if Input.is_action_pressed("move_left"):
#			dir -= head_basis.x
#			control_dir.x += 1
#		if Input.is_action_pressed("move_right"):
#			dir += head_basis.x
#			control_dir.x -= 1
#
#		dir = dir.normalized()
#
#		if Input.is_action_just_pressed("jump") and is_on_floor():
#			velocity.y += jump_y_power
#
#		var tempSpeed = speed
#		if control_dir == Vector2(0, 1) and Input.is_action_pressed("sprint"):
#			tempSpeed = sprint_speed
#			is_sprinting = true
#
#		velocity = velocity.linear_interpolate(dir * tempSpeed, acceleration * delta)
#
#		velocity.y -= gravity
#
#		velocity = move_and_slide(velocity, Vector3.UP)
#
#		rpc_unreliable("puppet_sprint", player_id, is_sprinting) 
#		rpc_unreliable("puppet_movement", player_id, self.transform)
	
		
#	if(is_sprinting):
#		animation.set_speed(2.5)
#		speed = speed_default * sprint_speed
#	else:
#		animation.set_speed(1.2)
#		speed = speed_default

#remote func puppet_sprint(pid, is_sprinting):
#	var root  = get_parent()
#	var playerNode = root.get_node(str(pid))
#	if playerNode != null:
#		playerNode.is_sprinting = is_sprinting
#
#remote func puppet_movement(pid, position):
#	var root = get_parent()
#	var playerNode = root.get_node(str(pid))
#	if playerNode != null:
#		playerNode.transform = position
