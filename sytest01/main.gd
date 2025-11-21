extends Node2D

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
@onready var loc_button_007: Button = $LocationButtons/LocButton007
@onready var loc_button_008: Button = $LocationButtons/LocButton008

# Scenes and nodes that get manipulated
@onready var player_panel: Control = $CanvasLayer/PlayerPanel
@onready var button_go_back: Button = $CanvasLayer/ButtonGoBack

# Create arrays
@export var map_locations : Array[Node] # Set up the map locations - NOT USING YET
@export var agent_location : Array[int] # Array of current player locations
@export var start_locations : Array[Button] # Holds all the start location buttons

# Set other variables
var setting_start : bool = false # to determine if the user is setting the start location
var player_turn : Sprite2D # Identify the player (sprite) who has the focus
var player_turn_number : int # Identify the player (number) who has the focus
var button_select = Button # Identify the button with the focus
var location_number : int # Inteer number of the location button

func _onready() -> void:
	agent_location.resize(4) # Set the initial size of the array
	start_locations.resize(3) # Set the number of start locations

# When a signal is received that a player wants to set the start location,
# enable the start location and wait for a button to be selected
func _on_player_panel_set_start_location(player: Variant, player_number: Variant) -> void:
	player_panel.visible = false
	button_go_back.visible = true
	player_turn = player # Set from the signal
	player_turn_number = player_number # Set from the signal
	#_enable_start_locations()

# Common code to enable/disable start locations, stored in the array
#func _enable_start_locations() -> void:
	#for n in range(start_locations.size()):
		## If an agent is on that location, disable it
		#print("n=",n," - ",agent_location[0],",",agent_location[1],",",agent_location[2],",",agent_location[3])
		#if agent_location.has(n+1): # Agent location 0 is the start, so off-set by one
			#start_locations[n+1].disabled = true
			#print("disabled")
		#else:
			#start_locations[n+1].disabled = false
			#print("nothing")
#func _disable_start_locations() -> void:
	#for n in range(start_locations.size()):
		#start_locations[n].disabled = true

# When a location button (signal) is received, move the player to that location
# and record the location of that player in the agent location array
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
	button_select.disabled = true
	_move_player()
	agent_location[player_turn_number] = int(button_select.text)
	player_panel.visible = true
	button_go_back.visible = false
	#_disable_start_locations()

# Move the player and set the location of the player in the location array
func _move_player() -> void: # modify so it works for start and regular game play
	var move_player = create_tween()
	move_player.tween_property(player_turn, "position", button_select.position,1)
	agent_location[player_turn_number] = location_number

func _on_button_go_back_pressed() -> void:
	#_disable_start_locations()
	player_panel.visible = true
	button_go_back.visible = false
