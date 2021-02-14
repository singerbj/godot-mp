extends KinematicBody

export var is_sprinting = false
export var player_id = 0
export var control = false

export var speed = 10
export var sprint_speed = 15
export var acceleration = 10
export var gravity = 0.98
export var jump_y_power = 32.5
export var mouse_sensitivity = 0.00075

var velocity = Vector3()
var rot_x = 0
var y_delta

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
	if control == true:
		var head_basis = self.get_global_transform().basis
		var dir = Vector3()
		var control_dir = Vector2()
		
		if Input.is_action_pressed("move_up"):
			dir -= head_basis.z
			control_dir.y += 1
		if Input.is_action_pressed("move_down"):
			dir += head_basis.z
			control_dir.y -= 1
		if Input.is_action_pressed("move_left"):
			dir -= head_basis.x
			control_dir.x += 1
		if Input.is_action_pressed("move_right"):
			dir += head_basis.x
			control_dir.x -= 1
	
		dir = dir.normalized()
		
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y += jump_y_power
		
		var tempSpeed = speed
		if control_dir == Vector2(0, 1) and Input.is_action_pressed("sprint"):
			tempSpeed = sprint_speed
			is_sprinting = true
			
			
		velocity = velocity.linear_interpolate(dir * tempSpeed, acceleration * delta)
			
		velocity.y -= gravity
		
		velocity = move_and_slide(velocity, Vector3.UP)
		
#		rpc_unreliable("puppet_is_sprinting", player_id, is_sprinting) 
#		rpc_unreliable("puppet_do_move", player_id, velocity)
		rpc_unreliable("puppet_do_move", player_id, self.transform.origin)
	
		
#	if(is_sprinting):
#		animation.set_speed(2.5)
#		speed = speed_default * sprint_speed
#	else:
#		animation.set_speed(1.2)
#		speed = speed_default

remote func puppet_is_sprinting(pid, is_sprinting):
	var root  = get_parent()
	var playerNode = root.get_node(str(pid))
	if playerNode != null:
		playerNode.is_sprinting = is_sprinting
	
remote func puppet_do_move(pid, position):
	var root = get_parent()
	var playerNode = root.get_node(str(pid))
	if playerNode != null:
#		playerNode.move_and_slide(position)
		playerNode.transform.origin = position
