extends Node2D

# This is the main code branch.

# Add the player pieces
@onready var agent_01: Sprite2D = $Players/Agent01
@onready var agent_02: Sprite2D = $Players/Agent02
@onready var agent_03: Sprite2D = $Players/Agent03

# Buttons for start locations
@onready var loc_button_001: Button = $LocationButtons/LocButton001
@onready var loc_button_002: Button = $LocationButtons/LocButton002
@onready var loc_button_003: Button = $LocationButtons/LocButton003
@onready var loc_button_004: Button = $LocationButtons/LocButton004
@onready var loc_button_005: Button = $LocationButtons/LocButton005
@onready var loc_button_006: Button = $LocationButtons/LocButton006

# Scenes and nodes that get manipulated
@onready var player_panel: Control = $CanvasLayer/PlayerPanel
@onready var button_go_back: Button = $CanvasLayer/ButtonGoBack

# Set up the map locations
@export var map_locations : Array[Node]

# Set other variables
var setting_start : bool = false # to determine if the user is setting the start location
var player_turn = Sprite2D # Identify the player who has the focus
var button_select = Button # Identify the button with the focus

# When a signal is received that a player wants to set the start location
func _on_player_panel_set_start_location(player: Variant) -> void:
	player_panel.visible = false
	button_go_back.visible = true
	player_turn = player
	_enable_start_locations()

# Common code to enable/disable start locations
func _enable_start_locations() -> void:
	loc_button_001.disabled = false
	loc_button_002.disabled = false
	loc_button_004.disabled = false
func _disable_start_locations() -> void:
	loc_button_001.disabled = true
	loc_button_002.disabled = true
	loc_button_004.disabled = true

# What happens when a button is pressed
func _on_loc_button_001_pressed() -> void:
	button_select = loc_button_001
	_location_selection()
func _on_loc_button_002_pressed() -> void:
	button_select = loc_button_002
	_location_selection()
func _on_loc_button_003_pressed() -> void:
	button_select = loc_button_003
	_location_selection()
func _on_loc_button_004_pressed() -> void:
	button_select = loc_button_004
	_location_selection()
func _on_loc_button_005_pressed() -> void:
	button_select = loc_button_005
	_location_selection()
func _on_loc_button_006_pressed() -> void:
	button_select = loc_button_006
	_location_selection()
func _location_selection() -> void:
	_move_player()
	player_panel.visible = true
	button_go_back.visible = false
	_disable_start_locations()

func _move_player() -> void: # modify so it works for start and regular game play
	var move_player = create_tween()
	move_player.tween_property(player_turn, "position", button_select.position,1)
	
func _on_button_go_back_pressed() -> void:
	_disable_start_locations()
	player_panel.visible = true
	button_go_back.visible = false

#func _on_player_start_location_selected(location_choice: Variant) -> void:
	#player_location = location_choice
	#var player_move_start = create_tween()
	#player_move_start.tween_property(player, "position", map_locations[player_location].position, 1)
