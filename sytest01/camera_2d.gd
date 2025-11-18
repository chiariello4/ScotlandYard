extends Camera2D

# The limits aren't working.
#@onready var camera_top_left: Marker2D = $CameraLimits/CameraTopLeft
#@onready var camera_bottom_right: Marker2D = $CameraLimits/CameraBottomRight

# Zoom Variables
var zoom_target : Vector2
var zoom_upper_limit : float = 3
var zoom_lower_limit : float = 0.5
var zoom_gradiient : float = 0.05
var zoom_weight : float = 1

# These are used for an alternate zoom method.
#var map_size : Vector2 = Vector2(640,540)
#var viewport_size : Vector2 = Vector2(320,180)

# These are used for the panning
var edge_margin : int = 5
var camera_speed : float = 300.0
var unzoomed_viewport_size : Vector2 = Vector2(1280,720) # play with this, was (640,360)

#func _ready():
	# The limits aren't working.
	#limit_top = camera_top_left.position.y
	#limit_left = camera_top_left.position.x
	#limit_bottom = camera_bottom_right.position.y
	#limit_right = camera_bottom_right.position.x

# Zoom
func _input(event: InputEvent) -> void:
	# Fix this later by limiting the vector to the map size
	if event.is_action_pressed("MOUSE_BUTTON_WHEEL_UP"):
		if get_zoom() < Vector2(zoom_upper_limit,zoom_upper_limit):
			zoom_target = get_zoom() + Vector2(0.05,0.05)
	if event.is_action_pressed("MOUSE_BUTTON_WHEEL_DOWN"):
		if get_zoom() > Vector2(zoom_lower_limit,zoom_lower_limit):
			zoom_target = get_zoom() - Vector2(zoom_gradiient,zoom_gradiient)
	zoom = zoom.slerp(zoom_target,zoom_weight)

# Pan
func _process(delta):
	# Get the current mouse posiition
	var mouse_position = get_viewport().get_mouse_position()
	# Initialize a vector to hold the camera's movement direction
	var move_vector = Vector2.ZERO
	# check if the mouse is near the left or right edge
	if mouse_position.x <= edge_margin:
		move_vector.x = -camera_speed * delta
	elif mouse_position.x >= unzoomed_viewport_size.x - edge_margin:
		move_vector.x = camera_speed * delta
	# check if the mouse is near the top or bottom edge
	if mouse_position.y <= edge_margin:
		move_vector.y = -camera_speed * delta
	elif mouse_position.y >= unzoomed_viewport_size.y - edge_margin:
		move_vector.y = camera_speed * delta
	# apply the move vector to the position
	position += move_vector
