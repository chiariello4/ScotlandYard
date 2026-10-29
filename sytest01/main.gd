extends Node2D

# Add the player pieces
@onready var sus_00: Sprite2D = $Players/sus00
@onready var bear: Sprite2D = $Players/bear

# Scenes and nodes that get manipulated
@onready var player_panel: Control = $CanvasLayer/PlayerPanel
@onready var button_go_back: Button = $CanvasLayer/ButtonGoBack
@onready var button_special_move: Button = $CanvasLayer/ButtonSpecialMove
@onready var button_play: Button = $CanvasLayer/ButtonPlay
@onready var button_quit: Button = $CanvasLayer/ButtonQuit

# Other variables on ready
@onready var tile_map_layer_sparta_nj: TileMapLayer = $Maps/TileMapLayerSpartaNJ
@onready var loc_button_theme = load("res://themes/loc_button_theme.tres")
@onready var loc_button_theme_block = load("res://themes/loc_button_theme_block.tres")
@onready var random_location : int = 0 # Holds a random location used in some functions

# Arrays that were once performed using export, but it stopped working. Now using a work-around.
@onready var player : Array[Sprite2D] # Array of player sprites
@onready var location : Array[Button] # Holds all location buttons

# Signals
signal location_selected(player_number_start)
signal ticket_used()
signal sus_moved(sus_moved_num,sus_mode_used,sus_moved_turn,sus_duress)
signal stop_moves()
signal game_restart()
signal out_of_moves(player)

# Set other variables used
## Used to determine if the user is setting the start location
var setting_start : bool = false
## Identify the suspect (sprite) who has the focus
var sus_focus_sprite : Sprite2D
## Identify the suspect (number) who has the focus
var sus_focus : int
## Determines if game setup is in progress
var setup_mode : bool
## Holds the button number of the selected location
var location_focus : int
## Identify the turn number of the player who has the focus
var turn_focus : int
## Holds the number of possible moves for a player, obtained from the JSON file
var num_possible_moves : int
## Total possible moves adjusted for unavailable moves
var adjusted_possible_moves : int
## Holds an array of possible moves for a player, obtained from the JSON file
var possible_moves : Array[int]
## Holds an array of the mode for each possible player move
var possible_moves_modes : Array[int]
## Holds an array of the travel mediums for each possible player move
var possible_moves_medium : Array[String]
## Holds the threat factor of each possible move
var possible_moves_threat : Array[int]
## Holds an array of possible moves for a suspect, obtained from the JSON file
var possible_sus_moves : Array[int]
## Holds an array of the mode for each possible suspect move
var possible_sus_moves_modes : Array[int]
## Holds the threat factor of each possible sus move
var possible_sus_moves_threat : Array[int]
## Holds number of agents who can capture at that location in one move
var possible_sus_moves_capture_1 : Array[int]
## Used to offset player movement to center in tile
var use_tile_size : int
## Used to offset player movement to center in tile
var use_tile_size_offset : float
## Used to offset player movement to center in tile, at the location button
var use_tile_size_offset_b : float
## Speed of player movement used for tween
var player_move_speed : float
## Speed of player movement used for ASTAR Grid
var player_move_speed_grid : int
## Sets the suspect start location
var sus_start : Array[int]
## Holds the suspect's latest move mode
var sus_mode_used : int
## Identifies the victory condition if one is present
var victory_condition : int
## Used to populate an arrays of nodes
var matched_nodes : Array[Node] = []
## Distance of the closest player to the agent being checked
var distance_to_agent_check : float

# Variables used for the handling of the wild animal
## Holds the number of possible moves for a wild animal, obtained from the JSON file
var wild_animal_num_possible_moves : int
## Total possible moves for the wild animal adjusted for unavailable moves
var wild_animal_adjusted_possible_moves : int
## Holds an array of possible moves for a wild animal, obtained from the JSON file
var wild_animal_possible_moves : Array[int]
## Adjusted wild animal move maximum to randomize the value when the wild animal moves to a new section
var wild_animal_move_max_applies : int
## Condition exists to query user to skip turn for wild animal encounter
var skip_turn_query_wild_animal : bool = false

# AStar2D grid variables
var astar_grid = AStarGrid2D
var current_player_path: Array[Vector2i]
var current_point_path: PackedVector2Array

func _ready() -> void:
	_setup_map()
	_initialize_variables()
	player_move_speed = 0.2 # sets the speed of the tween
	player_move_speed_grid = 7 # sets the speed of the path finder
	# REMOVE THE NEXT LINE when suspect selection is working
	sus_focus = 0 # hard code only one suspect to start
	#region Connect to signals from GlobalVar
	GlobalVars.team_selected_from_dialogue.connect(_set_agent_sprites) # receive signal that players are selected
	GlobalVars.sus_moves_first.connect(_sus_first_move) # recewive signal that the suspect will make the first move
	GlobalVars.mode_choice_selected.connect(_move_after_selection)
	GlobalVars.play_again.connect(_play_again)
	GlobalVars.quit.connect(_quit_game)
	GlobalVars.out_of_moves_check.connect(_check_game_over_incapacitated)
	GlobalVars.use_special.connect(_use_special_move)
	GlobalVars.blockade.connect(_blockade)
	GlobalVars.skip_turn_wild_animal.connect(_skip_turn)
	GlobalVars.no_skip_turn_wild_animal.connect(_location_selection)
	#endregion
	#region Populate node paths
	# This is stupid, load the node arrays from the node paths because export arrays stopped working. This is a work-around.
	# First use export for node paths, then load the 'real' array of nodes from the export array.
	var parent_node : Variant
	var pattern : String
	# Populate player sprites based on node path
	parent_node = $Players
	pattern = "agent*"
	_populate_nodes_by_parent(parent_node,pattern)
	for node in matched_nodes:
		if node is Sprite2D:
			player.append(node)
	# Populate location array based on node path
	parent_node = $LocationButtons
	pattern = "LocButton*"
	_populate_nodes_by_parent(parent_node,pattern)
	for node in matched_nodes:
		if node is Button:
			location.append(node)
	#endregion
	# Add a signal to each location button
	var loc_button : Button
	for loc in location.size():
		loc_button = location[loc]
		loc_button.pressed.connect(_on_loc_button_pressed.bind(loc))
	# Open the game start dialogue
	var dialogue_resource = load("res://dialog/dl_start.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue_resource, "start")

## Common function called by _ready to populate node arrays
func _populate_nodes_by_parent(parent,string_pattern) -> void:
	matched_nodes.clear()
	for child in parent.get_children():
		if child.name.match(string_pattern):
			matched_nodes.append(child)
	# sort the results alphabetically by node name
	matched_nodes.sort_custom(func(a, b): return a.name.naturalnocasecmp_to(b.name) < 0)

## Set the initial size of some arrays and other variables
func _initialize_variables() -> void:
	GlobalVars.agent_location.resize(6)
	GlobalVars.sus_location.resize(1)
	GlobalVars.sus_00_loc_history.resize(1)
	GlobalVars.sus_00_mode_history.resize(1)
	# Initialize other variables
	setup_mode = true
	victory_condition = GlobalEnums.win_type.NO_VICTORY
	turn_focus = 0

## Establishes the AStar2D map grid
func _setup_map() -> void:
	use_tile_size = 32
	use_tile_size_offset = 0
	use_tile_size_offset_b = 1
	# Set up the astar grid
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_map_layer_sparta_nj.get_used_rect()
	astar_grid.cell_size = Vector2(use_tile_size,use_tile_size)
	# Define the astar huristiics which determines the path
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	_set_walkable_area(0)

## Sets the walkable areas of the tile map
func _set_walkable_area(mode) -> void:
	# Set walkable evaluation based on mode
	var walkable_eval : String
	match mode:
		0: walkable_eval = "mode_0_allowed"
		1: walkable_eval = "mode_1_allowed"
		2: walkable_eval = "mode_2_allowed"
		3: walkable_eval = "mode_3_allowed"
		4: walkable_eval = "mode_4_allowed"
	astar_grid.update()
	for x in tile_map_layer_sparta_nj.get_used_rect().size.x:
		for y in tile_map_layer_sparta_nj.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tile_map_layer_sparta_nj.get_used_rect().position.x,
				y + tile_map_layer_sparta_nj.get_used_rect().position.y
			)
			var tile_data = tile_map_layer_sparta_nj.get_cell_tile_data(tile_position)
			if tile_data == null or tile_data.get_custom_data(walkable_eval) == false:
				astar_grid.set_point_solid(tile_position, true)
			else:
				astar_grid.set_point_solid(tile_position, false)

## After the setup dialog runs and agents are selected, set the agent and suspect sprite textures.
func _set_agent_sprites() -> void:
	var sprite_path : String
	# set the agent sprites
	for i in range (1,GlobalVars.agent_count + 1):
		sprite_path = "res://art/player_sprites/%ssprite.png" % GlobalVars.agent_name[i].to_lower()
		# if FileAccess.file_exists(sprite_path): # REMOVED as it would not work in itch.io
		player[i].texture = load(sprite_path)
	# set the suspect sprite
	sprite_path = "res://art/player_sprites/%ssprite.png" % GlobalVars.sus_name.to_lower()
	# if FileAccess.file_exists(sprite_path): # REMOVED as it would not work in itch.io
	sus_00.texture = load(sprite_path)

## When a signal is received that a player wants to set the start location, enable the start location and wait for a button to be selected
func _on_player_panel_set_start_location(player_sprite: Variant, player_number: Variant) -> void:
	player_panel.visible = false
	button_go_back.visible = true
	GlobalVars.player_focus_sprite = player_sprite # Set from the signal
	GlobalVars.player_focus = player_number # Set from the signal
	GlobalVars.player_focus_name = GlobalVars.agent_name[player_number]
	_enable_start_locations()

## Go back to the setup panel
func _on_button_go_back_pressed() -> void:
	if setup_mode == true:
		_disable_start_locations()
	else:
		_disable_possible_moves()
	player_panel.visible = true
	button_go_back.visible = false
	button_special_move.visible = false

## Enable start locations, stored in the array
func _enable_start_locations() -> void:
	for n in range(GlobalVars.start_locations.size()):
		location_focus = GlobalVars.start_locations[n]
		location[location_focus].disabled = false
	_disable_occupied_locations()

## Disable occupied locations on setup (occupied locations on regular move are handled elsewhere)
func _disable_occupied_locations() -> void:
	if setup_mode == true:
		for n in range(GlobalVars.start_locations.size()):
			location_focus = GlobalVars.start_locations[n]
			if GlobalVars.agent_location.has(location_focus):
				location[location_focus].disabled = true

## Reset the start locations after the player moves
func _disable_start_locations():
	for n in range(GlobalVars.start_locations.size()):
		location_focus = GlobalVars.start_locations[n]
		location[location_focus].disabled = true

## Actions taken after setup is complete
func _on_player_panel_setup_is_complete() -> void:
	# Set the suspect start location, 2 steps:
	# 1 - loop through start locations and add unoccupied locations to a new array
	for n in range(GlobalVars.start_locations.size()):
		if GlobalVars.agent_location.has(GlobalVars.start_locations[n]) == false:
			sus_start.append(GlobalVars.start_locations[n])
	# 2 - Randomize the order in the array and pick the first one as a randomly chosen start location for the suspect
	sus_start.shuffle()
	GlobalVars.sus_location[0] = sus_start[0]
	#region For TESTING, manually set the suspect start location
	#GlobalVars.sus_location[0] = 1
	#endregion
	GlobalVars.sus_00_loc_history[0] = GlobalVars.sus_location[0]
	GlobalVars.sus_00_mode_history[0] = 4
	# Move suspect to the start location
	_move_sus(sus_00,GlobalVars.sus_location[0])
	# Send message that suspect will make the first move
	var dialogue_resource = load("res://dialog/dl_dispatch.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue_resource, "setup")

## Handles the suspect's first move
func _sus_first_move() -> void:
	setup_mode = false
	turn_focus = 1
	_get_sus_move(sus_focus,GlobalVars.sus_location[0],turn_focus)
	GlobalVars.sus_last_move_type = GlobalVars.travel_mode[sus_mode_used].to_lower()
	var dialogue_resource = load("res://dialog/dl_dispatch.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue_resource, "susmovefirst")

## When the 'complete turn' button is pressed from the player panel
func _on_player_panel_turn_is_complete() -> void:
	_check_game_over()
	if victory_condition != GlobalEnums.win_type.NO_VICTORY:
		emit_signal("stop_moves")
	else:
		turn_focus += 1
		# Suspect moves
		_get_sus_move(sus_focus,GlobalVars.sus_location[0],turn_focus)
		_wild_animal_movement()

## Check if any game-over conditions are met
func _check_game_over() -> void:
	# Suspect is captured
	if GlobalVars.agent_location.has(GlobalVars.sus_location[0]):
		victory_condition = GlobalEnums.win_type.CAPTURE
		emit_signal("stop_moves")
		for n in 6:
			if GlobalVars.agent_location[n] == GlobalVars.sus_location[0]:
				GlobalVars.captured_by = n
		button_go_back.visible = false
		button_special_move.visible = false
		var dialogue_resource = load("res://dialog/dl_end.dialogue")
		DialogueManager.show_dialogue_balloon(dialogue_resource, "capture")
	# Suspect is surrounded and has no available moves
	if victory_condition == GlobalEnums.win_type.SURROUNDED:
		button_go_back.visible = false
		button_special_move.visible = false
		var dialogue_resource = load("res://dialog/dl_end.dialogue")
		DialogueManager.show_dialogue_balloon(dialogue_resource, "surrounded")
	# The suspect wins after reaching the turn limit
	if GlobalVars.turn_number >= GlobalVars.turn_limit:
		button_go_back.visible = false
		button_special_move.visible = false
		victory_condition = GlobalEnums.win_type.OUT_OF_MOVES
		var dialogue_resource = load("res://dialog/dl_end.dialogue")
		DialogueManager.show_dialogue_balloon(dialogue_resource, "suswins")
	# Incapacitated game-over check handled separately, invoked from diaglogue

## The suspect wins if all agents are incapacitated and can't move, invoked from dl_agent:outofmoves
func _check_game_over_incapacitated() -> void:
	if not GlobalVars.agent_incapacitated.has(false):
		button_go_back.visible = false
		button_special_move.visible = false
		victory_condition = GlobalEnums.win_type.INCAPACITATED
		var dialogue_resource = load("res://dialog/dl_end.dialogue")
		DialogueManager.show_dialogue_balloon(dialogue_resource, "incapacitated")

## When a location button (signal) is received, check if a skip-turn condition is present. If not, move the player to that location and record the location of that player in the agent location array
func _on_loc_button_pressed(button_id: int) -> void:
	location_focus = button_id
	# Check if wild animal is in that location/section.
	_wild_animal_encounter(location_focus)
	# EVALUATE SKIP TURN CONDITIONS
	# > Moving into visible bear location
	if skip_turn_query_wild_animal == true:
		_skip_turn_eval_wild_animal()
		return # stop the player movement
	# If no skip turn conditions are present, proceed to move the agent
	_location_selection()

## Determines what happens when an agent moves into a section or location with a wild animal
func _wild_animal_encounter(location_encounter: int) -> void:
	var dialogue_resource = load("res://dialog/dl_agent.dialogue")
	var section_check : String
	section_check = JsonHandler.location_variables[location_encounter]["section"]
	if location_encounter == GlobalVars.wild_animal_location : # if the wild animal is at that location
		if bear.visible == false :
			# if the wild animal is last spotted in this section
			if section_check == GlobalVars.wild_animal_last_section_spotted :
				DialogueManager.show_dialogue_balloon(dialogue_resource, "wild_animal_nervous")
			# bear becomes visible, spotted, and agent encounters
			bear.visible = true
			GlobalVars.wild_animal_last_section_spotted = GlobalVars.wild_animal_section
			GlobalVars.wild_animal_last_turn_spotted = turn_focus
			DialogueManager.show_dialogue_balloon(dialogue_resource, "wild_animal_encounter")
			# bear moves away
			_wild_animal_movement() 
		if bear.visible == true :
			# if first bear encounter
			if GlobalVars.wild_animal_last_encounter[GlobalVars.player_focus] == 0 :
				skip_turn_query_wild_animal = true
			# if turns since last bear encounter > max
			elif (turn_focus - GlobalVars.wild_animal_last_encounter[GlobalVars.player_focus]) > GlobalVars.wild_animal_agent_turns_until_choice :
				skip_turn_query_wild_animal = true
			# if turns since last encounter < max, no skip-turn condition exists
			else :
				DialogueManager.show_dialogue_balloon(dialogue_resource, "wild_animal_encounter")
	else :
		# if the wild animal is last spotted in this section
		if section_check == GlobalVars.wild_animal_last_section_spotted :
			DialogueManager.show_dialogue_balloon(dialogue_resource, "wild_animal_nervous")

## This function is invoked if there is a skip-turn condition present for a wild animal. The user is queried.
func _skip_turn_eval_wild_animal() -> void:
	var dialogue_resource = load("res://dialog/dl_agent.dialogue")
	# if this is a first-time encounter
	if GlobalVars.wild_animal_last_encounter[GlobalVars.player_focus] == 0 :
		DialogueManager.show_dialogue_balloon(dialogue_resource, "wild_animal_at_location_choice")
		GlobalVars.wild_animal_last_encounter[GlobalVars.player_focus] = turn_focus
	# if turns since last bear encounter > max
	if (turn_focus - GlobalVars.wild_animal_last_encounter[GlobalVars.player_focus]) > GlobalVars.wild_animal_agent_turns_until_choice :
		DialogueManager.show_dialogue_balloon(dialogue_resource, "wild_animal_at_location_choice_again")
		GlobalVars.wild_animal_last_encounter[GlobalVars.player_focus] = turn_focus
	skip_turn_query_wild_animal = false # reset the flag

func _skip_turn() -> void:
	# Record turn and mode history to skip turn
	_record_history(GlobalVars.player_focus,location_focus,turn_focus,5)
	# Increase the agent's special moves by 1
	match GlobalVars.player_focus:
		1:
			GlobalVars.tickets_remaining_agent01[3] += 1
		2:
			GlobalVars.tickets_remaining_agent02[3] += 1
		3:
			GlobalVars.tickets_remaining_agent03[3] += 1
		4:
			GlobalVars.tickets_remaining_agent04[3] += 1
		5:
			GlobalVars.tickets_remaining_agent05[3] += 1
	player_panel.visible = true
	button_go_back.visible = false
	button_special_move.visible = false
	emit_signal("location_selected",GlobalVars.player_focus)
	_disable_possible_moves()

## Actions taken after a location is selected
func _location_selection() -> void:
	print("possible_moves at start of function: ",possible_moves)
	var dialogue_resource = load("res://dialog/dl_agent.dialogue")
	#region Check if the agent is misbehaving.
	var misbehavior_check : float
	misbehavior_check = randf()
	print("misbehavior_check: ",misbehavior_check)
	match GlobalVars.player_focus_name :
		"Arthur": # Arthur is agent 0 from the full agent list (not the list of agents in the game)
			# Swims near water
			if GlobalVars.agent_misbehavior_turn_start[0] <= GlobalVars.turn_number : # if it's past the turn when the misbehavior starts to appear
				var location_lookup : int
				location_lookup = GlobalVars.agent_location[GlobalVars.agent_name.find("Arthur")]
				var location_near_water : bool
				location_near_water = JsonHandler.location_variables[location_lookup]["near_water"]
				if location_near_water == true : # Must be near water
					if (GlobalVars.agent_misbehavior_last[0] == 0) : # First offense
						if misbehavior_check <= GlobalVars.agent_misbehavior_rate_1[0] :
							_skip_turn()
							DialogueManager.show_dialogue_balloon(dialogue_resource, "misbehavior_arthur")
							GlobalVars.agent_misbehavior_last[0] = GlobalVars.turn_number
							return
					elif ((GlobalVars.turn_number - GlobalVars.agent_misbehavior_last[0]) > GlobalVars.agent_misbehavior_turns[0]) : # Sufficient time after last offense
						if misbehavior_check <= GlobalVars.agent_misbehavior_rate_2[0] :
							_skip_turn()
							DialogueManager.show_dialogue_balloon(dialogue_resource, "misbehavior_arthur_2")
							GlobalVars.agent_misbehavior_last[0] = GlobalVars.turn_number
							return
		"Cristobal": # Cristobal is agent 2 from the full agent list (not the list of agents in the game)
			# Doesn't like working close to other agents
			# Check closest agent
			if GlobalVars.agent_misbehavior_turn_start[2] <= GlobalVars.turn_number : # if it's past the turn when the misbehavior starts to appear
				if (GlobalVars.agent_misbehavior_last[2] == 0) : # First offense:
					if misbehavior_check <= GlobalVars.agent_misbehavior_rate_1[2] :
						var cristobal_index : int
						cristobal_index = GlobalVars.agent_name.find("Cristobal")
						_closest_agent(cristobal_index) # find the closest agent to Cristobal
						if distance_to_agent_check <= GlobalVars.too_close_to_cristobal :
							_skip_turn()
							DialogueManager.show_dialogue_balloon(dialogue_resource, "misbehavior_cristobal")
							GlobalVars.agent_misbehavior_last[2] = GlobalVars.turn_number
							return
				elif ((GlobalVars.turn_number - GlobalVars.agent_misbehavior_last[2]) > GlobalVars.agent_misbehavior_turns[2]) : # Sufficient time after last offense
					if misbehavior_check <= GlobalVars.agent_misbehavior_rate_2[2] :
						var cristobal_index : int
						cristobal_index = GlobalVars.agent_name.find("Cristobal")
						_closest_agent(cristobal_index) # find the closest agent to Cristobal
						if distance_to_agent_check <= GlobalVars.too_close_to_cristobal :
							_skip_turn()
							DialogueManager.show_dialogue_balloon(dialogue_resource, "misbehavior_cristobal_2")
							GlobalVars.agent_misbehavior_last[2] = GlobalVars.turn_number
							return
		"Gonzalo": # Gonzalo is agent 6 from the full agent list (not the list of agents in the game)
			# Stops to eat near food
			if GlobalVars.agent_misbehavior_turn_start[6] <= GlobalVars.turn_number : # if it's past the turn when the misbehavior starts to appear
				var location_lookup : int
				location_lookup = GlobalVars.agent_location[GlobalVars.agent_name.find("Gonzalo")]
				var location_has_food : bool
				location_has_food = JsonHandler.location_variables[location_lookup]["has_food"]
				if location_has_food == true : # Must have food
					if (GlobalVars.agent_misbehavior_last[6] == 0) : # First offense
						if misbehavior_check <= GlobalVars.agent_misbehavior_rate_1[6] :
							_skip_turn()
							DialogueManager.show_dialogue_balloon(dialogue_resource, "misbehavior_gonzalo")
							GlobalVars.agent_misbehavior_last[6] = GlobalVars.turn_number
							return
					elif ((GlobalVars.turn_number - GlobalVars.agent_misbehavior_last[6]) > GlobalVars.agent_misbehavior_turns[6]) : # Sufficient time after last offense
						if misbehavior_check <= GlobalVars.agent_misbehavior_rate_2[6] :
							_skip_turn()
							DialogueManager.show_dialogue_balloon(dialogue_resource, "misbehavior_gonzalo_2")
							GlobalVars.agent_misbehavior_last[6] = GlobalVars.turn_number
							return
		"Hanna": # Hanna is agent 7 from the full agent list (not the list of agents in the game)
			# Adicted to social media
			if GlobalVars.agent_misbehavior_turn_start[7] <= GlobalVars.turn_number : # if it's past the turn when the misbehavior starts to appear
				if (GlobalVars.agent_misbehavior_last[7] == 0) : # First offense
					if misbehavior_check <= GlobalVars.agent_misbehavior_rate_1[7] :
						_skip_turn()
						DialogueManager.show_dialogue_balloon(dialogue_resource, "misbehavior_hanna")
						GlobalVars.agent_misbehavior_last[7] = GlobalVars.turn_number
						return
				elif ((GlobalVars.turn_number - GlobalVars.agent_misbehavior_last[7]) > GlobalVars.agent_misbehavior_turns[7]) : # Sufficient time after last offense
					if misbehavior_check <= GlobalVars.agent_misbehavior_rate_2[7] :
						_skip_turn()
						DialogueManager.show_dialogue_balloon(dialogue_resource, "misbehavior_hanna_2")
						GlobalVars.agent_misbehavior_last[7] = GlobalVars.turn_number
						return
	#endregion
	# Select travel mode
	GlobalVars.mode_option.clear()
	GlobalVars.mode_medium_option.clear()
	for n in range(adjusted_possible_moves):
		if possible_moves[n] == location_focus:
			GlobalVars.mode_option.append(possible_moves_modes[n])
			GlobalVars.mode_medium_option.append(possible_moves_medium[n])
	if GlobalVars.mode_option.size() == 0 :
		_move_after_selection(5)
	elif GlobalVars.mode_option.size() == 1:
		GlobalVars.mode_option_selected = GlobalVars.mode_option[0]
		GlobalVars.medium_option_selected = GlobalVars.mode_medium_option[0]
		#region Check if the agent is misbehaving.
		match GlobalVars.player_focus_name :
			"Bertha": # Bertha is agent 1 from the full agent list (not the list of agents in the game)
				# Makes a rogue, random move
				if GlobalVars.agent_misbehavior_turn_start[1] <= GlobalVars.turn_number : # if it's past the turn when the misbehavior starts to appear
					if (GlobalVars.agent_misbehavior_last[1] == 0) : # First offense:
						if misbehavior_check <= GlobalVars.agent_misbehavior_rate_1[1] :
							if possible_moves.size() >1 : #if there is more than one possible move
								_generate_random_rogue_move()
								DialogueManager.show_dialogue_balloon(dialogue_resource, "misbehavior_bertha")
								GlobalVars.agent_misbehavior_last[1] = GlobalVars.turn_number
					elif ((GlobalVars.turn_number - GlobalVars.agent_misbehavior_last[1]) > GlobalVars.agent_misbehavior_turns[1]) : # Sufficient time after last offense
						if misbehavior_check <= GlobalVars.agent_misbehavior_rate_2[1] :
							if possible_moves.size() >1 : #if there is more than one possible move
								_generate_random_rogue_move()
								DialogueManager.show_dialogue_balloon(dialogue_resource, "misbehavior_bertha_2")
								GlobalVars.agent_misbehavior_last[1] = GlobalVars.turn_number
								return
			"Dolly": # Dolly is agent 3 from the full agent list (not the list of agents in the game)
				# Doesn't like paths
				if GlobalVars.medium_option_selected == "path" or GlobalVars.medium_option_selected == "path-public" : # if Edouard is taking a path
					if GlobalVars.agent_misbehavior_turn_start[3] <= GlobalVars.turn_number : # if it's past the turn when the misbehavior starts to appear
						if (GlobalVars.agent_misbehavior_last[3] == 0) : # First offense:
							if misbehavior_check <= GlobalVars.agent_misbehavior_rate_1[3] :
								# Retain original location and description for dialogue
								GlobalVars.original_location_name = JsonHandler.location_variables[location_focus]["location_name"]
								_skip_turn()
								DialogueManager.show_dialogue_balloon(dialogue_resource, "misbehavior_dolly")
								GlobalVars.agent_misbehavior_last[3] = GlobalVars.turn_number
								return
						elif ((GlobalVars.turn_number - GlobalVars.agent_misbehavior_last[3]) > GlobalVars.agent_misbehavior_turns[3]) : # Sufficient time after last offense
							if misbehavior_check <= GlobalVars.agent_misbehavior_rate_2[3] : # if the misbehavior rate is triggered
								# Retain original location and description for dialogue
								GlobalVars.original_location_name = JsonHandler.location_variables[location_focus]["location_name"]
								_skip_turn()
								DialogueManager.show_dialogue_balloon(dialogue_resource, "misbehavior_dolly_2")
								GlobalVars.agent_misbehavior_last[3] = GlobalVars.turn_number
								return
			"Edouard": # Edouard is agent 4 from the full agent list (not the list of agents in the game)
				# Gets lost on paths
				if GlobalVars.medium_option_selected == "path" or GlobalVars.medium_option_selected == "path-public" : # if Edouard is taking a path
					if GlobalVars.agent_misbehavior_turn_start[4] <= GlobalVars.turn_number : # if it's past the turn when the misbehavior starts to appear
						if (GlobalVars.agent_misbehavior_last[4] == 0) : # First offense:
							if misbehavior_check <= GlobalVars.agent_misbehavior_rate_1[4] :
								# Retain original location and description for dialogue
								GlobalVars.original_location_name = JsonHandler.location_variables[location_focus]["location_name"]
								_skip_turn()
								DialogueManager.show_dialogue_balloon(dialogue_resource, "misbehavior_edouard")
								GlobalVars.agent_misbehavior_last[4] = GlobalVars.turn_number
								return
						elif ((GlobalVars.turn_number - GlobalVars.agent_misbehavior_last[4]) > GlobalVars.agent_misbehavior_turns[4]) : # Sufficient time after last offense
							if misbehavior_check <= GlobalVars.agent_misbehavior_rate_2[4] : # if the misbehavior rate is triggered
								# Retain original location and description for dialogue
								GlobalVars.original_location_name = JsonHandler.location_variables[location_focus]["location_name"]
								_skip_turn()
								DialogueManager.show_dialogue_balloon(dialogue_resource, "misbehavior_edouard_2")
								GlobalVars.agent_misbehavior_last[4] = GlobalVars.turn_number
								return
			"Fay": # FAY is agent 5 from the full agent list (not the list of agents in the game)
				# CHECK MISBEHAVIOR FOR FAY, if only one option is available and it's on foot
				# Needs to rest if asked to walk
				if GlobalVars.agent_misbehavior_turn_start[5] <= GlobalVars.turn_number : # if it's past the turn when the misbehavior starts to appear
					if GlobalVars.mode_option_selected == 0 : # if there is only one travel mode option and it's on foot
						if (GlobalVars.agent_misbehavior_last[3] == 0) : # First offense
							if misbehavior_check <= GlobalVars.agent_misbehavior_rate_1[5] : # if the misbehavior rate is triggered
								_skip_turn()
								DialogueManager.show_dialogue_balloon(dialogue_resource, "misbehavior_dolly")
								GlobalVars.agent_misbehavior_last[5] = GlobalVars.turn_number
								return
						elif ((GlobalVars.turn_number - GlobalVars.agent_misbehavior_last[5]) > GlobalVars.agent_misbehavior_turns[5]) : # Sufficient time after last offense
							if misbehavior_check <= GlobalVars.agent_misbehavior_rate_2[5] : # if the misbehavior rate is triggered
								_skip_turn()
								DialogueManager.show_dialogue_balloon(dialogue_resource, "misbehavior_dolly_2")
								GlobalVars.agent_misbehavior_last[5] = GlobalVars.turn_number
								return
		#endregion
		_move_after_selection(GlobalVars.mode_option_selected)
	else:
		# Open the dialogue to select a mode if more than one option is available
		DialogueManager.show_dialogue_balloon(dialogue_resource, "travelmode")

## Receives an agent index number and finds the closest agent to that one
func _closest_agent(agent_check : int) -> void:
	distance_to_agent_check = 0
	var distance_to_agent_check_eval : float = 0
	for i in range(1,(GlobalVars.agent_count)+1) :
		print("GlobalVars.agent_name[i]: ",GlobalVars.agent_name[i])
		if i == agent_check :
			pass
		else:
			distance_to_agent_check_eval = player[i].global_position.distance_to(player[agent_check].global_position)
			print("distance_to_agent_check_eval: ",distance_to_agent_check_eval)
			if distance_to_agent_check == 0 or distance_to_agent_check_eval < distance_to_agent_check:
				distance_to_agent_check = distance_to_agent_check_eval
				GlobalVars.agent_closest_to_cristobal = GlobalVars.agent_name[i]

func _generate_random_rogue_move() -> void:
	# Retain original location and description for dialogue
	GlobalVars.original_location_name = JsonHandler.location_variables[location_focus]["location_name"]
	# Get a random move different from the one originally requested
	var location_index : int
	var rogue_moves : Array[int]
	var rogue_moves_modes : Array[int]
	var rogue_moves_count : int
	var random_move_index : int
	rogue_moves = possible_moves.duplicate()
	rogue_moves_modes = possible_moves_modes.duplicate()
	location_index = possible_moves.find(location_focus)
	rogue_moves.remove_at(location_index)
	rogue_moves_modes.remove_at(location_index)
	rogue_moves_count = rogue_moves.size()
	random_move_index = randi_range(0,random_move_index)
	location_focus = rogue_moves[random_move_index]
	GlobalVars.mode_option_selected = rogue_moves_modes[random_move_index]

## Actions taken to handle the movement of the agent sprite after a location is selected
func _move_after_selection(mode_selected: int) -> void:
	var ticket_use = mode_selected
	if setup_mode == false:
		_set_walkable_area(ticket_use)
		# Debit from ticket type used
		match GlobalVars.player_focus:
			1:
				GlobalVars.tickets_remaining_agent01[ticket_use] -= 1
			2:
				GlobalVars.tickets_remaining_agent02[ticket_use] -= 1
			3:
				GlobalVars.tickets_remaining_agent03[ticket_use] -= 1
			4:
				GlobalVars.tickets_remaining_agent04[ticket_use] -= 1
			5:
				GlobalVars.tickets_remaining_agent05[ticket_use] -= 1
		GlobalVars.tickets_remaining_sus00[ticket_use] += 1
		emit_signal("ticket_used")
	_move_player(GlobalVars.player_focus_sprite,location_focus)
	GlobalVars.agent_location[GlobalVars.player_focus] = location_focus
	emit_signal("location_selected",GlobalVars.player_focus)
	player_panel.visible = true
	button_go_back.visible = false
	button_special_move.visible = false
	_record_history(GlobalVars.player_focus,location_focus,turn_focus,ticket_use)
	if setup_mode == true:
		_disable_start_locations()
	else:
		_disable_possible_moves()
	if location_focus == GlobalVars.wild_animal_location and bear.visible == true : 
		_wild_animal_pick_new_location()

## Actions taken when the agent's special move button is pressed (requires confirmation)
func _on_button_special_move_pressed() -> void:
	# Check for closest agent and distance
	var eval_distance : float = INF
	GlobalVars.closest_distance = player[1].global_position.distance_to(sus_00.global_position)
	GlobalVars.closest_agent = 1
	for i in range (2,GlobalVars.agent_count + 1):
		eval_distance = player[i].global_position.distance_to(sus_00.global_position)
		if eval_distance < GlobalVars.closest_distance:
			GlobalVars.closest_agent = i
			GlobalVars.closest_distance = eval_distance
	# Display the dialogue box
	var dialogue_resource = load("res://dialog/dl_agent.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue_resource, "special")

## Actions taken when the player uses a special move.
func _use_special_move() -> void:
	_disable_possible_moves()
	player_panel.visible = true
	button_go_back.visible = false
	button_special_move.visible = false
	match GlobalVars.player_focus:
		1:
			GlobalVars.tickets_remaining_agent01[3] -= 1
		2:
			GlobalVars.tickets_remaining_agent02[3] -= 1
		3:
			GlobalVars.tickets_remaining_agent03[3] -= 1
		4:
			GlobalVars.tickets_remaining_agent04[3] -= 1
		5:
			GlobalVars.tickets_remaining_agent05[3] -= 1
	emit_signal("location_selected",GlobalVars.player_focus)

## Set theme for blocked locations
func _blockade() -> void:
	for x in GlobalVars.blocked_location :
		location[x].theme = loc_button_theme_block
	_use_special_move()

## Record the movement in the player's history log
func _record_history(player_history,location_history,_turn_history,mode_history) -> void:
	if setup_mode == true:
		mode_history = 4
	match player_history:
		1: 
			GlobalVars.agent_01_loc_history.append(location_history)
			GlobalVars.agent_01_mode_history.append(mode_history)
			print("Agent 1 location history: ",GlobalVars.agent_01_loc_history) # FOR TESTING
			print("Agent 1 mode history: ",GlobalVars.agent_01_mode_history) # FOR TESTING
		2: 
			GlobalVars.agent_02_loc_history.append(location_history)
			GlobalVars.agent_02_mode_history.append(mode_history)
			print("Agent 2 location history: ",GlobalVars.agent_02_loc_history) # FOR TESTING
			print("Agent 2 mode history: ",GlobalVars.agent_02_mode_history) # FOR TESTING
		3: 
			GlobalVars.agent_03_loc_history.append(location_history)
			GlobalVars.agent_03_mode_history.append(mode_history)
			print("Agent 3 location history: ",GlobalVars.agent_03_loc_history) # FOR TESTING
			print("Agent 3 mode history: ",GlobalVars.agent_03_mode_history) # FOR TESTING
		4: 
			GlobalVars.agent_04_loc_history.append(location_history)
			GlobalVars.agent_04_mode_history.append(mode_history)
			print("Agent 4 location history: ",GlobalVars.agent_04_loc_history) # FOR TESTING
			print("Agent 4 mode history: ",GlobalVars.agent_04_mode_history) # FOR TESTING
		5: 
			GlobalVars.agent_05_loc_history.append(location_history)
			GlobalVars.agent_05_mode_history.append(mode_history)
			print("Agent 5 location history: ",GlobalVars.agent_05_loc_history) # FOR TESTING
			print("Agent 5 mode history: ",GlobalVars.agent_05_mode_history) # FOR TESTING

## Move the player and set the location of the player in the location array
func _move_player(move_what,move_to) -> void:
	# Movement during setup
	if setup_mode == true:
		move_what.visible = true
		var move_player = create_tween()
		move_player.tween_property(move_what, "position", location[move_to].position + Vector2(use_tile_size*use_tile_size_offset_b,use_tile_size*use_tile_size_offset_b),player_move_speed)
	else:
		var id_path = astar_grid.get_id_path(
		tile_map_layer_sparta_nj.local_to_map(GlobalVars.player_focus_sprite.position + Vector2(use_tile_size*use_tile_size_offset,use_tile_size*use_tile_size_offset)),
		tile_map_layer_sparta_nj.local_to_map(location[move_to].position + Vector2(use_tile_size*use_tile_size_offset_b,use_tile_size*use_tile_size_offset_b))
		).slice(1)
		current_player_path = id_path

## Handles the movement of the suspect
func _move_sus(move_what,move_to) -> void:
	var move_player = create_tween()
	move_player.tween_property(move_what, "position", location[move_to].position + Vector2(use_tile_size*use_tile_size_offset_b,use_tile_size*use_tile_size_offset_b),player_move_speed)
	await move_player.finished

## Move the suspect a second time when the suspect uses a double-move
func _on_player_panel_double_move() -> void:
	_get_sus_move(sus_focus,GlobalVars.sus_location[0],GlobalVars.turn_number)

func _process(_delta: float) -> void:
	if current_player_path.is_empty():
		get_viewport().gui_disable_input = false
		return
	get_viewport().gui_disable_input = true
	var target_position = tile_map_layer_sparta_nj.map_to_local(current_player_path.front())
	GlobalVars.player_focus_sprite.position = GlobalVars.player_focus_sprite.position.move_toward(target_position,player_move_speed_grid)
	if GlobalVars.player_focus_sprite.position == target_position:
		current_player_path.pop_front()

## Enable the possible moves for a player
func _on_player_panel_move_to_location(player_sprite: Variant, player_number: Variant, _turn_number: Variant) -> void:
	current_player_path.clear()
	GlobalVars.player_focus_sprite = player_sprite
	GlobalVars.player_focus = player_number
	GlobalVars.player_focus_name = GlobalVars.agent_name[player_number]
	player_panel.visible = false
	button_go_back.visible = true
	#region display special move button if the player has special moves remaining
	if GlobalVars.agent_name[player_number] == "Artnur" :
		pass
	if GlobalVars.agent_name[player_number] in GlobalVars.agents_with_special_abilities :
		match player_number :
			1:
				if GlobalVars.tickets_remaining_agent01[3] > 0 :
					button_special_move.visible = true
			2:
				if GlobalVars.tickets_remaining_agent02[3] > 0 :
					button_special_move.visible = true
			3:
				if GlobalVars.tickets_remaining_agent03[3] > 0 :
					button_special_move.visible = true
			4:
				if GlobalVars.tickets_remaining_agent04[3] > 0 :
					button_special_move.visible = true
			5:
				if GlobalVars.tickets_remaining_agent05[3] > 0 :
					button_special_move.visible = true
	#endregion
	_get_possible_moves(GlobalVars.player_focus)
	# Remove the agent if the player is out of moves
	if adjusted_possible_moves == 0:
		GlobalVars.agent_incapacitated[player_number] = true
		var dialogue_resource = load("res://dialog/dl_agent.dialogue")
		DialogueManager.show_dialogue_balloon(dialogue_resource,"outofmoves")
		_on_button_go_back_pressed()
		emit_signal("out_of_moves",player_number)
	else:
		# Enable the location buttons for items in the array
		for n in range(adjusted_possible_moves):
			var enable_possible_location = possible_moves[n]
			location[enable_possible_location].disabled = false
	_check_game_over()

## Get the possible moves for an agent. Accepts agent number, returns three arrays - possible moves, their modes and their threat level
func _get_possible_moves(agent_possible: Variant) -> void:
	# Get the player's current location
	location_focus = GlobalVars.agent_location[agent_possible]
	# Get the number of gross possible moves for the agent's location from the JSON file
	num_possible_moves = JsonHandler.location_variables[location_focus]["num_eligible_destinations"]
	# Clear the arrays holding all the possible moves, their modes, and their threat levels
	possible_moves.clear()
	possible_moves_modes.clear()
	possible_moves_medium.clear()
	possible_moves_threat.clear()
	# Loop through the possible moves to populate the array from the JSON file
	for n in range(num_possible_moves):
		# Ignore this possible move if there are no tickets left for that mode
		var move_mode_eval = int(JsonHandler.location_variables[location_focus]["destinations"][n]["mode"])
		match agent_possible:
			1:
				if GlobalVars.tickets_remaining_agent01[move_mode_eval] == 0:
					continue
			2:
				if GlobalVars.tickets_remaining_agent02[move_mode_eval] == 0:
					continue
			3:
				if GlobalVars.tickets_remaining_agent03[move_mode_eval] == 0:
					continue
			4:
				if GlobalVars.tickets_remaining_agent04[move_mode_eval] == 0:
					continue
			5:
				if GlobalVars.tickets_remaining_agent05[move_mode_eval] == 0:
					continue
		# Ignore this possible move if an agent occupies that location
		var location_eval = int(JsonHandler.location_variables[location_focus]["destinations"][n]["end_location"])
		if GlobalVars.agent_location.has(location_eval):
			continue
		# Ignore this possible move if it's a water route the agent is not Arthur
		var index_arthur : int = GlobalVars.agent_name.find("Arthur") # will be -1 if Arthur is not in the array
		if move_mode_eval == 3 and index_arthur != agent_possible :
			continue
		# If everything checks out, add that location to the array of possible moves
		possible_moves.append(JsonHandler.location_variables[location_focus]["destinations"][n]["end_location"])
		possible_moves_modes.append(JsonHandler.location_variables[location_focus]["destinations"][n]["mode"])
		possible_moves_medium.append(JsonHandler.location_variables[location_focus]["destinations"][n]["medium"])
	adjusted_possible_moves = possible_moves.size()
	possible_moves_threat.resize(adjusted_possible_moves)

## For cleanup after a location is selected
func _disable_possible_moves() -> void:
	for n in range(adjusted_possible_moves):
		var enable_possible_location = possible_moves[n]
		location[enable_possible_location].disabled = true

## Handles the possible moves and movement of the suspect when it's the suspect's turn
func _get_sus_move(current_sus_focus, current_sus_location,sus_turn_num) -> void:
	var listening_device_check : bool = false
	location_focus = current_sus_location
	sus_focus = current_sus_focus
	# Get possible moves from JSON file
	_get_moves_from_location(current_sus_focus,current_sus_location,listening_device_check)
	# If there are no possible moves, the agents have won.
	if possible_sus_moves.size() == 0:
		victory_condition = GlobalEnums.win_type.SURROUNDED
		_check_game_over()
	else:
		_assess_agent_moves()
		var possible_sus_moves_weighted : Array[int] # Each possible sus move appears in the array a number of time depending on the threat level.
		var weighted_sus_move : int
		for x in range(possible_sus_moves.size()):
			if possible_sus_moves_weighted.has(possible_sus_moves[x]):
				continue
			# Get the weighted factor of moves, depending on the threat level
			weighted_sus_move = GlobalVars.sus_threat_profile[possible_sus_moves_threat[x]]
			for y in weighted_sus_move:
				possible_sus_moves_weighted.append(possible_sus_moves[x]) # add the move 'y' number of times to the weighted array, where 'y' is the weighted threat level
		possible_sus_moves_weighted.shuffle() # randomize the array values
		GlobalVars.sus_location[0] = possible_sus_moves_weighted[0] # pick the first value in the array as the location for the sus to move to
		_move_sus(sus_00,GlobalVars.sus_location[0])
		GlobalVars.sus_00_loc_history.append(GlobalVars.sus_location[0])
		GlobalVars.sus_duress = possible_sus_moves_weighted.size()
		# set the mode and mode history by getting the index value of the original array
		var find_selection_index = possible_sus_moves.find(GlobalVars.sus_location[0])
		sus_mode_used = possible_sus_moves_modes[find_selection_index]
		GlobalVars.sus_00_mode_history.append(sus_mode_used)
		GlobalVars.sus_last_move_type = GlobalVars.travel_mode[sus_mode_used].to_lower()
		# Reduce the number of tickets for that mode by 1
		GlobalVars.tickets_remaining_sus00[sus_mode_used] -= 1
		# If a water move was used, reduce the number of remaining water moves by 1
		if sus_mode_used == 3:
			GlobalVars.sus_num_water_moves -= 1
		#region FOR TESTING, display sus history and duress level
		#print("Sus moves possible: ",possible_sus_moves)
		print("Sus history: ",GlobalVars.sus_00_loc_history)
		print("Sus mode history: ",GlobalVars.sus_00_mode_history)
		#endregion
		#region Determine if listening device is tripped
		if not GlobalVars.listening_device.is_empty() :
			var listening_device_alarm : bool = false
			listening_device_check = true
			_get_moves_from_location(sus_focus,GlobalVars.sus_location[0],listening_device_check)
			#print("Possible sus moves for check: ",possible_sus_moves)
			for item in GlobalVars.listening_device :
				if possible_sus_moves.has(item):
					listening_device_alarm = true
			# also check to see if the suspect's location has a listening device
			if possible_sus_moves.has(GlobalVars.sus_location[0]) :
				listening_device_alarm = true
			if listening_device_alarm == true :
				var dialogue_resource = load("res://dialog/dl_agent.dialogue")
				DialogueManager.show_dialogue_balloon(dialogue_resource, "listening_device")
		#endregion
		# Signal to player panel to enable move buttons and show move
		emit_signal("sus_moved",sus_focus,sus_mode_used,sus_turn_num)

## Finds all possible suspect moves for the suspect's location
func _get_moves_from_location(current_sus_focus,location_check,listening_device_check) -> void:
	var sus_num_possible_moves : int # Holds the number of possible moves for the suspect
	var sus_move_add : int # Possible location ID to be added to the array
	var sus_move_mode_add : int # Travel mode for location iD to be added to the array
	# Get the number of possible moves for the suspect's location from the JSON file
	sus_num_possible_moves = int(JsonHandler.location_variables[location_check]["num_eligible_destinations"])
	# Clear the arrays holding all the possible sus moves
	possible_sus_moves.clear()
	possible_sus_moves_modes.clear()
	possible_sus_moves_threat.clear()
	possible_sus_moves_capture_1.clear()
	# Populate the array from the JSON file
	for n in range(sus_num_possible_moves):
		var move_mode_eval = int(JsonHandler.location_variables[location_check]["destinations"][n]["mode"])
		# Ignore the location if there are no tickets left for that mode and it's not for a listening device check
		if GlobalVars.tickets_remaining_sus00[move_mode_eval] == 0 and listening_device_check == false:
			continue
		# Ignore the location if the mode is 3 (water) and there are no water moves left and it's not for a listening device check
		if move_mode_eval == 3 and GlobalVars.sus_num_water_moves == 0 and listening_device_check == false:
			continue
		var location_eval = int(JsonHandler.location_variables[location_check]["destinations"][n]["end_location"])
		if listening_device_check == false :
			# Ignore the location if an agent occupies that location and it's not for a listening device check
			if GlobalVars.agent_location.has(location_eval) or GlobalVars.sus_location.has(location_eval):
				continue
			# Ignore the location if there is a blockade on that location and it's not for a listening device check
			if GlobalVars.blocked_location.has(location_eval):
				continue
		# If everything checks out, populate the arrray with the possible move
		sus_move_add = int(JsonHandler.location_variables[location_check]["destinations"][n]["end_location"])
		possible_sus_moves.append(sus_move_add)
		sus_move_mode_add = int(JsonHandler.location_variables[location_check]["destinations"][n]["mode"])
		possible_sus_moves_modes.append(sus_move_mode_add)
		possible_sus_moves_threat.append(5) # Set to the lowest threat level for now
		possible_sus_moves_capture_1.append(0) # Set to zero the number of agents who can capture at that location in one move for now

## Handles the movement of the wild animal during it's turn
func _wild_animal_movement() -> void:
	# set the initial location based on the start turn
	if GlobalVars.wild_animal_start_turn == turn_focus :
		_wild_animal_section_location()
		_wild_animal_reveal_check()
		return
	# Set the new location if the move max is reached
	if GlobalVars.wild_animal_move_count == wild_animal_move_max_applies :
		# If the wild animal moves have reached the move max, move it to a new section
		_wild_animal_section_location()
		_wild_animal_reveal_check()
	else:
		# Move to a new foot location within that same section
		_wild_animal_pick_new_location()
		_move_wild_animal()
		_wild_animal_reveal_check()

## Check to see if the wild animal is revealed, and if so, display the dialogue.
func _wild_animal_reveal_check() -> void:
	var generate_reveal_chance = randf()
	if generate_reveal_chance <= GlobalVars.wild_animal_reveal_chance :
		bear.visible = true
		GlobalVars.wild_animal_last_section_spotted = GlobalVars.wild_animal_section
		GlobalVars.wild_animal_last_turn_spotted = GlobalVars.turn_number
		if GlobalVars.wild_animal_section_spotted == false :
			# Only invoke the dialogue once per section
			var dialogue_resource = load("res://dialog/dl_dispatch.dialogue")
			DialogueManager.show_dialogue_balloon(dialogue_resource, "wild_animal_spotted")
			GlobalVars.wild_animal_section_spotted = true
	else:
		bear.visible = false

## Move the wild animal to a new, random section of town and set the wild animal move count to 1.
func _wild_animal_section_location() -> void:
	var get_section : Array[String]
	# Start with the full list of town sections
	get_section = GlobalVars.town_section.duplicate()
	# Remove downtown and current section
	get_section.erase("Downtown Sparta")
	if not GlobalVars.wild_animal_section.is_empty():
		get_section.erase(GlobalVars.wild_animal_section)
	GlobalVars.wild_animal_section = get_section.pick_random()
	print("bear section: ",GlobalVars.wild_animal_section)
	# After a section is selected, pick a location
	_locations_in_section(GlobalVars.wild_animal_section)
	_get_random_unoccupied_location(GlobalVars.wild_animal_section_locations)
	GlobalVars.wild_animal_location = random_location
	print("bear location: ",GlobalVars.wild_animal_location)
	random_location = 0 # reset the variable
	GlobalVars.wild_animal_move_count = 0 # reset the move counter
	# move wild animal to that location after evaluating the reveal chance
	GlobalVars.wild_animal_section_spotted = false
	_move_wild_animal()
	# Randomize the move max to +/-1 of the default
	var random_mov_max_dif : Array[int] = [-2,-1,0,1,2]
	wild_animal_move_max_applies = GlobalVars.wild_animal_move_max + random_mov_max_dif.pick_random()

## Retrieve all of the locations in a section of town.
func _locations_in_section(use_section: String) -> void:
	GlobalVars.wild_animal_section_locations.clear()
	var section_eval : String
	# Loop through all locations. If section matches animal section, add location to array
	for n in range(1,200):
		section_eval = String(JsonHandler.location_variables[n]["section"])
		if section_eval == GlobalVars.wild_animal_section :
			GlobalVars.wild_animal_section_locations.append(n)

## Pick a new location in that section for the wild animal using only foot movements
func _wild_animal_pick_new_location() -> void:
	# Get the number of gross possible moves for the wild animal's location from the JSON file
	wild_animal_num_possible_moves = JsonHandler.location_variables[GlobalVars.wild_animal_location]["num_eligible_destinations"]
	# Clear the array holding all the possible moves
	wild_animal_possible_moves.clear()
	# Loop through the possible moves to populate the array from the JSON file
	for n in range(wild_animal_num_possible_moves):
		# Ignore the possible move if it's not mode zero
		var move_mode_eval = JsonHandler.location_variables[GlobalVars.wild_animal_location]["destinations"][n]["mode"]
		if move_mode_eval != 0:
			continue
		# Ignore the possible move if the location is occupied by an agent
		if GlobalVars.agent_location.has(JsonHandler.location_variables[GlobalVars.wild_animal_location]["destinations"][n]["end_location"]) :
			continue
		# If everything checks out, add that location to the array of possible moves
		wild_animal_possible_moves.append(JsonHandler.location_variables[GlobalVars.wild_animal_location]["destinations"][n]["end_location"])
	# if there are no possible moves, move the wild animal to a new section
	if wild_animal_possible_moves.is_empty() :
		_wild_animal_section_location() # if there are no possible moves, move the wild animal to a new section
	else:
		GlobalVars.wild_animal_location = wild_animal_possible_moves.pick_random() # Select a random move from the possible moves
		_move_wild_animal()
	print("wild_animal_location: ",GlobalVars.wild_animal_location)
	wild_animal_possible_moves.clear()

## Move the wild animal via a tween to the new location
func _move_wild_animal() -> void:
	var move_bear = create_tween()
	move_bear.tween_property(bear, "position", location[GlobalVars.wild_animal_location].position,player_move_speed)
	# move_bear.tween_property(bear, "position", location[GlobalVars.wild_animal_location].position + Vector2(use_tile_size*use_tile_size_offset_b,use_tile_size*use_tile_size_offset_b),player_move_speed)
	GlobalVars.wild_animal_move_count += 1

## Get a random location ID in a section that is not occupied by an agent
func _get_random_unoccupied_location(array_location_eval : Array[int]) -> void:
	var location_randomize : Array[int]
	location_randomize = array_location_eval
	for i in range(location_randomize.size()):
		if not GlobalVars.agent_location.has(location_randomize[i]):
			random_location = location_randomize[i]
			continue

## Play again; restart the game
func _play_again() -> void:
	GlobalVars.agent_location.clear()
	GlobalVars.sus_location.clear()
	sus_start.clear()
	GlobalVars.agent_01_loc_history.clear()
	GlobalVars.agent_02_loc_history.clear()
	GlobalVars.agent_03_loc_history.clear()
	GlobalVars.agent_04_loc_history.clear()
	GlobalVars.agent_05_loc_history.clear()
	GlobalVars.agent_01_mode_history.clear()
	GlobalVars.agent_02_mode_history.clear()
	GlobalVars.agent_03_mode_history.clear()
	GlobalVars.agent_04_mode_history.clear()
	GlobalVars.agent_05_mode_history.clear()
	GlobalVars.sus_00_loc_history.clear()
	GlobalVars.sus_00_mode_history.clear()
	GlobalVars.tickets_remaining_agent01.clear()
	GlobalVars.tickets_remaining_agent02.clear()
	GlobalVars.tickets_remaining_agent03.clear()
	GlobalVars.tickets_remaining_agent04.clear()
	GlobalVars.tickets_remaining_agent05.clear()
	GlobalVars.tickets_remaining_sus00.clear()
	_initialize_variables()
	_disable_possible_moves()
	# Reset player sprites and starting location
	var base_sprite : Texture2D
	base_sprite = load('res://art/player_sprites/ignoresprite.png')
	for n in range (1,GlobalVars.agent_count + 1):
		player[n].visible = false
		player[n].texture = base_sprite
	sus_00.visible = false
	GlobalVars.restart = true	
	emit_signal("game_restart")

## Sets the threat level to the suspect of all agent possible moves
func _assess_agent_moves() -> void:
	# For each agent, get the possible moves, put them into an array, and assign a threat level
	var second_possible_moves : Array[int] # holds the possible moves after making the first move
	# Loop through all agents
	for n in range (1,GlobalVars.agent_count + 1):
		# Pass the agent number to get it's possible moves
		_get_possible_moves(n)
		# See if any of those moves overlap with the suspect's possible moves
		for y in possible_sus_moves:
			# If the agent's possible moves contain the suspect's possible moves, 
			# Set the sus move threat level to that agent's move threat level
			if possible_moves.has(y):
				var find_selection_index = possible_sus_moves.find(y)
				# Add 1 to the number of agents who can capture at that location in one move
				possible_sus_moves_capture_1[find_selection_index] += 1
				# Level 0 - This is the agent's only possible move
				if possible_moves.size() == 1:
						possible_sus_moves_threat[y] = 0 # highest threat level
				# Level 2 - Agent has only 2 moves
				elif possible_moves.size() == 2:
					for nn in range(adjusted_possible_moves):
						if possible_moves[nn] == y and possible_sus_moves_threat[find_selection_index] > 2:
							possible_sus_moves_threat[find_selection_index] = 2
				else:
					for nnn in range(adjusted_possible_moves):
						if possible_moves[nnn] == y and possible_sus_moves_threat[find_selection_index] > 3:
							possible_sus_moves_threat[find_selection_index] = 3
			# Then for each possible agent move, get the range of second moves.
			for z in possible_moves:
				# Get the number of gross (second) possible moves for the agent's possible location from the JSON file
				var second_num_possible_moves = int(JsonHandler.location_variables[z]["num_eligible_destinations"])
				# Populate array of second possible moves
				for yy in range(second_num_possible_moves):
					second_possible_moves.append(int(JsonHandler.location_variables[z]["destinations"][yy]["end_location"]))
				# If the agent's possible second move contains the suspect's possible moves,
				# set the sus move threat level
				for zz in possible_sus_moves:
					if second_possible_moves.has(zz):
						var find_selection_index = possible_sus_moves.find(zz)
						if possible_sus_moves_threat[find_selection_index] > 4:
							possible_sus_moves_threat[find_selection_index] = 4
	# ADD LOGIC FOR THREAT LEVEL 1
	for nn in possible_sus_moves_capture_1.size():
		# If for that location, more than one agent can capture in one move, set the threat level to 1
		if possible_sus_moves_capture_1[nn] > 1:
			possible_sus_moves_threat[nn] = 1

## When the 'play' button is pressed
func _on_button_play_pressed() -> void:
	# Open the game start dialogue
	var dialogue_resource = load("res://dialog/dl_start.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
	button_play.visible = false

## When the 'quit' button is pressed
func _quit_game() -> void:
	player_panel.visible = false
	button_play.visible = true
	button_quit.visible = true

## Exits the game
func _on_button_quit_pressed() -> void:
	get_tree().quit()
