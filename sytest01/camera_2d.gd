extends Camera2D

# Zoom Variables
var zoom_target : Vector2
var zoom_upper_limit : float = 3
var zoom_lower_limit : float = 0.375
var zoom_gradiient : float = 0.05
var zoom_weight : float = 0.5

# These are used for the panning
var edge_margin : int = 50
var camera_speed : float = 400.0
#var unzoomed_viewport_size : Vector2 = Vector2(1280,720)

# Zoom
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("MOUSE_BUTTON_WHEEL_UP"):
		if get_zoom() < Vector2(zoom_upper_limit,zoom_upper_limit):
			zoom_target = get_zoom() + Vector2(zoom_gradiient,zoom_gradiient)
			zoom = zoom.slerp(zoom_target,zoom_weight)
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
	#elif mouse_position.x >= unzoomed_viewport_size.x - edge_margin:
	elif mouse_position.x >= get_viewport().size.x - edge_margin:
		move_vector.x = camera_speed * delta
	# check if the mouse is near the top or bottom edge
	if mouse_position.y <= edge_margin:
		move_vector.y = -camera_speed * delta
	elif mouse_position.y >= get_viewport().size.y - edge_margin:
		move_vector.y = camera_speed * delta
	# apply the move vector to the position
	position += move_vector
