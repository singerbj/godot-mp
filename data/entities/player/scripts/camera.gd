extends Camera

enum { FIRST_PERSON, THIRD_PERSON }
enum { RIGHT_SHOULDER, LEFT_SHOULDER }
var camera_view = THIRD_PERSON
var shoulder = RIGHT_SHOULDER
var camera_x_rotation = 0

var yaw = 0.0
var pitch = 0.0
var origin : Vector3 = Vector3()

onready var screen_size_x = get_viewport().size.x
onready var screen_size_y = get_viewport().size.y
#onready var crosshair = $Crosshair
onready var camera_tween = Tween.new()

func _ready():
	self.call_deferred("add_child", camera_tween)
		
func _process(delta):	
	if Input.is_action_just_pressed("toggle_camera"):
		toggle_camera_view()
	if Input.is_action_just_pressed("shoulder_right"):
		set_shoulder(RIGHT_SHOULDER)
	if Input.is_action_just_pressed("shoulder_left"):
		set_shoulder(LEFT_SHOULDER)				
#	set_camera_location(delta)

func set_crosshair_location():
	screen_size_x = get_viewport().size.x
	screen_size_y = get_viewport().size.y

#	var crosshair_x_location = (screen_size_x / 2) - (crosshair.texture.get_size().x / 2)
#	var crosshair_y_location = (screen_size_y / 2) - (crosshair.texture.get_size().y / 2)
#	crosshair.set_position(Vector2(crosshair_x_location, crosshair_y_location))
	
func set_allow_movement(menu_opened):
	if menu_opened:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func toggle_camera_view():
	if camera_view == FIRST_PERSON:
		camera_view = THIRD_PERSON
	else:
		camera_view = FIRST_PERSON

func set_shoulder(new_shoulder):
	if camera_view == THIRD_PERSON:
		shoulder = new_shoulder

#func set_camera_location(delta):
#	var self_to = self.transform.origin;
#	var new_camera_location = Vector3(self_to.x, self_to.y, self_to.z)
#	if camera_view == FIRST_PERSON:
#		new_camera_location.x = 0
#		new_camera_location.y = 0
#		new_camera_location.z = 0
#	elif camera_view == THIRD_PERSON:
#		if shoulder == RIGHT_SHOULDER:
#			new_camera_location.x = 0.5
#		elif shoulder == LEFT_SHOULDER:
#			new_camera_location.x = -0.5
#		new_camera_location.y = -0.15
#		new_camera_location.z = 1.5
#	if self.transform.origin != new_camera_location:
#		camera_tween.interpolate_property(self, "translation", 
#			self.transform.origin, new_camera_location, 0.1, 
#			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#		camera_tween.start()
