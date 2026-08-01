extends Node2D

# Add the player pieces
@onready var sus_00: Sprite2D = $Players/sus00

# Scenes and nodes that get manipulated
@onready var player_panel: Control = $CanvasLayer/PlayerPanel
@onready var button_go_back: Button = $CanvasLayer/ButtonGoBack
@onready var button_play: Button = $CanvasLayer/ButtonPlay

# Other variables on ready
@onready var tile_map_layer_sparta_nj: TileMapLayer = $Maps/TileMapLayerSpartaNJ

# Create arrays
@export var player : Array[Sprite2D] # Array of player sprites
@export var agent_location : Array[int] # Array of current player locations
@export var sus_location : Array[int] # Array of current suspect locations
@export var location : Array[Button] # Holds all location buttons

# Create arrays to hold the location history for each player
@onready var agent_01_loc_history : Array[int] # Holds the location history of the agent as the game progresses
@onready var agent_02_loc_history : Array[int] # Holds the location history of the agent as the game progresses
@onready var agent_03_loc_history : Array[int] # Holds the location history of the agent as the game progresses
@onready var agent_04_loc_history : Array[int] # Holds the location history of the agent as the game progresses
@onready var agent_05_loc_history : Array[int] # Holds the location history of the agent as the game progresses

# Create arrays to hold the mode history for each player
@onready var agent_01_mode_history : Array[int] # Holds the movement mode history of the agent as the game progresses
@onready var agent_02_mode_history : Array[int] # Holds the movement mode history of the agent as the game progresses
@onready var agent_03_mode_history : Array[int] # Holds the movement mode history of the agent as the game progresses
@onready var agent_04_mode_history : Array[int] # Holds the movement mode history of the agent as the game progresses
@onready var agent_05_mode_history : Array[int] # Holds the movement mode history of the agent as the game progresses

 #Track remaining player tickets
 #Arrays are for each mode, so tickets_remaining_agent01[0] is remaining tickets for mode 0
@onready var tickets_remaining_agent01 : Array[int]
@onready var tickets_remaining_agent02 : Array[int]
@onready var tickets_remaining_agent03 : Array[int]
@onready var tickets_remaining_agent04 : Array[int]
@onready var tickets_remaining_agent05 : Array[int]
@onready var tickets_remaining_sus00 : Array[int]

# Signals
signal location_selected(player_number_start)
signal ticket_used(player_number_used,mode_used,remaining,remaining_sus)
signal sus_moved(sus_moved_num,sus_mode_used,sus_remaining,sus_moved_turn)
signal stop_moves()
signal player_panel_restart()

# Set other variables used
var setting_start : bool = false # to determine if the user is setting the start location
var sus_focus_sprite : Sprite2D # Identify the player (sprite) who has the focus
var sus_focus : int # Identify the player (number) who has the focus
var setup_mode : bool # Game setup in progress or complete
var location_focus : int # Holds the button number of the selected location
var turn_focus : int # Identify the turn number of the player who has the focus
var num_possible_moves : int # Holds the number of possible moves for a player, obtained from the JSON file
var adjusted_possible_moves : int # Total possible moves adjusted for unavailable moves
var possible_moves : Array[int] # Holds an array of possible moves for a player, obtained from the JSON file
var possible_moves_modes : Array[int] # Holds an array of the mode for each possible player move
var possible_moves_threat : Array[int] # Holds the threat factor of each possible move
var possible_sus_moves : Array[int] # Holds an array of possible moves for a suspect, obtained from the JSON file
var possible_sus_moves_modes : Array[int] # Holds an array of the mode for each possible suspect move
var possible_sus_moves_threat : Array[int] # Holds the threat factor of each possible sus move
var possible_sus_moves_capture_1 : Array[int] # Holds number of agents who can capture at that location in one move
var astar_grid = AStarGrid2D
var current_player_path: Array[Vector2i]
var current_point_path: PackedVector2Array
var use_tile_size : int # Used to offset player movement to center in tile
var use_tile_size_offset : float # Used to offset player movement to center in tile
var use_tile_size_offset_b : float # Used to offset player movement to center in tile, at the location button
var player_move_speed : float # for tween
var player_move_speed_grid : int # for ASTAR Grid
var sus_start : Array[int] # To set the suspect start location
var sus_mode_used : int # holds the latest move mode for the suspect
var victory_condition : int

#DEPRECATED variables
#var player_focus_sprite : Sprite2D # Identify the player (sprite) who has the focus
#var player_focus : int # Identify the player (number) who has the focus

func _ready() -> void:
	_setup_map()
	_initialize_player_tickets()
	_initialize_variables()
	player_move_speed = 0.2 # sets the speed of the tween
	player_move_speed_grid = 6 # sets the speed of the path finder
	# REMOVE THE NEXT LINE when suspect selection is working
	sus_focus = 0 # hard code only one suspect to start
	# Connect to signals from GlobalVar
	GlobalVars.team_selected_from_dialogue.connect(_set_agent_sprites) # receive signal that players are selected
	GlobalVars.sus_moves_first.connect(_sus_first_move) # recewive signal that the suspect will make the first move
	GlobalVars.mode_choice_selected.connect(_move_after_selection)
	GlobalVars.play_again.connect(_play_again)
	GlobalVars.quit.connect(_quit_game)
	# Open the game start dialogue
	var dialogue_resource = load("res://dialog/dl_start.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue_resource, "start")

func _initialize_variables() -> void:
	# Set the initial size of the arrays
	agent_location.resize(6)
	sus_location.resize(1)
	GlobalVars.sus_00_loc_history.resize(1)
	GlobalVars.sus_00_mode_history.resize(1)
	player.resize(6)
	# Initialize other variables
	setup_mode = true
	victory_condition = GlobalEnums.win_type.NO_VICTORY
	turn_focus = 0

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

# Sets the walkable areas of the tile map
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

func _initialize_player_tickets() -> void:
	tickets_remaining_agent01.resize(4)
	tickets_remaining_agent02.resize(4)
	tickets_remaining_agent03.resize(4)
	tickets_remaining_agent04.resize(4)
	tickets_remaining_agent05.resize(4)
	for n in 4:
		tickets_remaining_agent01[n] = GlobalVars.travel_mode_start_number[n]
		tickets_remaining_agent02[n] = GlobalVars.travel_mode_start_number[n]
		tickets_remaining_agent03[n] = GlobalVars.travel_mode_start_number[n]
		tickets_remaining_agent04[n] = GlobalVars.travel_mode_start_number[n]
		tickets_remaining_agent05[n] = GlobalVars.travel_mode_start_number[n]
	# Also for the suspect
	tickets_remaining_sus00.resize(4)
	for n in 4:
		tickets_remaining_sus00[n] = GlobalVars.travel_mode_start_number_sus[n]

# After the setup dialog runs and agents are selected, set the sprite textures. Also for suspect.
func _set_agent_sprites() -> void:
	var sprite_path : String
	# set the agent sprites
	for i in [1,2,3,4,5]:
		sprite_path = "res://art/player_sprites/%ssprite.png" % GlobalVars.agent_name[i].to_lower()
		# if FileAccess.file_exists(sprite_path): # REMOVED as it would not work in itch.io
		player[i].texture = load(sprite_path)
	# set the suspect sprite
	sprite_path = "res://art/player_sprites/%ssprite.png" % GlobalVars.sus_name.to_lower()
	# if FileAccess.file_exists(sprite_path): # REMOVED as it would not work in itch.io
	sus_00.texture = load(sprite_path)

# When a signal is received that a player wants to set the start location,
# enable the start location and wait for a button to be selected
func _on_player_panel_set_start_location(player_sprite: Variant, player_number: Variant) -> void:
	player_panel.visible = false
	button_go_back.visible = true
	GlobalVars.player_focus_sprite = player_sprite # Set from the signal
	GlobalVars.player_focus = player_number # Set from the signal
	_enable_start_locations()

# Go back to the setup panel
func _on_button_go_back_pressed() -> void:
	if setup_mode == true:
		_disable_start_locations()
	else:
		_disable_possible_moves()
	player_panel.visible = true
	button_go_back.visible = false

# Enable start locations, stored in the array
func _enable_start_locations() -> void:
	for n in range(GlobalVars.start_locations.size()):
		location_focus = GlobalVars.start_locations[n]
		location[location_focus].disabled = false
	_disable_occupied_locations()

# Disable occupied locations on setup (occupied locations on regular move are handled elsewhere)
func _disable_occupied_locations() -> void:
	if setup_mode == true:
		for n in range(GlobalVars.start_locations.size()):
			location_focus = GlobalVars.start_locations[n]
			if agent_location.has(location_focus):
				location[location_focus].disabled = true

# Reset the start locations after the player moves
func _disable_start_locations():
	for n in range(GlobalVars.start_locations.size()):
		location_focus = GlobalVars.start_locations[n]
		location[location_focus].disabled = true

# Setup complete
func _on_player_panel_setup_is_complete() -> void:
	# Set the suspect start location, 2 steps:
	# 1 - loop through start locations and add unoccupied locations to a new array
	for n in range(GlobalVars.start_locations.size()):
		if agent_location.has(GlobalVars.start_locations[n]) == false:
			sus_start.append(GlobalVars.start_locations[n])
	# 2 - Randomize the order in the array and pick the first one as a randomly chosen start location for the suspect
	sus_start.shuffle()
	sus_location[0] = sus_start[0]
	# For TESTING, manually set the suspect start location
	#sus_location[0] = 1
	GlobalVars.sus_00_loc_history[0] = sus_start[0]
	GlobalVars.sus_00_mode_history[0] = 4
	# Move suspect to the start location
	_move_sus(sus_00,sus_location[0])
	# Send message that suspect will make the first move
	var dialogue_resource = load("res://dialog/dl_dispatch.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue_resource, "setup")

# Handles the suspect's first move
func _sus_first_move() -> void:
	setup_mode = false
	turn_focus = 1
	_get_sus_move(sus_focus,sus_location[0],turn_focus)
	GlobalVars.sus_last_move_type = GlobalVars.travel_mode[sus_mode_used].to_lower()
	var dialogue_resource = load("res://dialog/dl_dispatch.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue_resource, "susmovefirst")

# When the 'complete turn' button is pressed from the player panel
func _on_player_panel_turn_is_complete() -> void:
	# Get closest agent to the suspect
	var eval_distance : float = INF
	GlobalVars.closest_distance = player[1].global_position.distance_to(sus_00.global_position)
	GlobalVars.closest_agent = 1
	for i in [2,3,4,5]:
		eval_distance = player[i].global_position.distance_to(sus_00.global_position)
		if eval_distance < GlobalVars.closest_distance:
			GlobalVars.closest_agent = i
			GlobalVars.closest_distance = eval_distance
	# FOR TESTING
	#print("Closest agent: ",GlobalVars.closest_agent,", distance: ",GlobalVars.closest_distance)
	_check_game_over()
	if victory_condition == GlobalEnums.win_type.CAPTURE:
		emit_signal("stop_moves")
	else:
		turn_focus += 1
		#print("turn_focus: ",turn_focus) # FOR TESTING
		# Suspect moves
		_get_sus_move(sus_focus,sus_location[0],turn_focus)
		GlobalVars.sus_last_move_type = GlobalVars.travel_mode[sus_mode_used].to_lower()
		var dialogue_resource = load("res://dialog/dl_dispatch.dialogue")
		DialogueManager.show_dialogue_balloon(dialogue_resource, "susmove")

func _check_game_over() -> void:
	if agent_location.has(sus_location[0]):
		victory_condition = GlobalEnums.win_type.CAPTURE
		for n in 6:
			if agent_location[n] == sus_location[0]:
				GlobalVars.captured_by = n
		var dialogue_resource = load("res://dialog/dl_end.dialogue")
		DialogueManager.show_dialogue_balloon(dialogue_resource, "capture")
	if victory_condition == GlobalEnums.win_type.SURROUNDED:
		var dialogue_resource = load("res://dialog/dl_end.dialogue")
		DialogueManager.show_dialogue_balloon(dialogue_resource, "surrounded")
	if GlobalVars.turn_number >= GlobalVars.turn_limit:
		var dialogue_resource = load("res://dialog/dl_end.dialogue")
		DialogueManager.show_dialogue_balloon(dialogue_resource, "suswins")

# When a location button (signal) is received, move the player to that location
# and record the location of that player in the agent location array
func _on_loc_button_pressed(button_id: int) -> void:
	location_focus = button_id
	_location_selection()
	
func _location_selection() -> void:
	# Select travel mode
	GlobalVars.mode_option.clear()
	for n in range(adjusted_possible_moves):
		if possible_moves[n] == location_focus:
			GlobalVars.mode_option.append(possible_moves_modes[n])
	if GlobalVars.mode_option.size() == 0 :
		_move_after_selection(4)
	elif GlobalVars.mode_option.size() == 1:
		GlobalVars.mode_option_selected = GlobalVars.mode_option[0]
		_move_after_selection(GlobalVars.mode_option_selected)
	else:
		# Open the dialogue to select a mode if more than one option is available
		var dialogue_resource = load("res://dialog/dl_agent.dialogue")
		DialogueManager.show_dialogue_balloon(dialogue_resource, "travelmode")

func _move_after_selection(mode_selected) -> void:
	var ticket_use = mode_selected
	if setup_mode == false:
		# set mode-specific walkable area
		_set_walkable_area(ticket_use)
		#var mode_focus = ticket_use
		var remaining_tickets : int
		var remaining_tickets_sus : int
		match GlobalVars.player_focus:
			1:
				tickets_remaining_agent01[ticket_use] = tickets_remaining_agent01[ticket_use] - 1
				remaining_tickets = tickets_remaining_agent01[ticket_use]
			2:
				tickets_remaining_agent02[ticket_use] = tickets_remaining_agent02[ticket_use] - 1
				remaining_tickets = tickets_remaining_agent02[ticket_use]
			3:
				tickets_remaining_agent03[ticket_use] = tickets_remaining_agent03[ticket_use] - 1
				remaining_tickets = tickets_remaining_agent03[ticket_use]
			4:
				tickets_remaining_agent03[ticket_use] = tickets_remaining_agent04[ticket_use] - 1
				remaining_tickets = tickets_remaining_agent03[ticket_use]
			5:
				tickets_remaining_agent03[ticket_use] = tickets_remaining_agent05[ticket_use] - 1
				remaining_tickets = tickets_remaining_agent03[ticket_use]
		tickets_remaining_sus00[ticket_use] = tickets_remaining_sus00[ticket_use] +1
		remaining_tickets_sus = tickets_remaining_sus00[ticket_use] 
		emit_signal("ticket_used",GlobalVars.player_focus,ticket_use,remaining_tickets,remaining_tickets_sus)
	_move_player(GlobalVars.player_focus_sprite,location_focus)
	agent_location[GlobalVars.player_focus] = location_focus
	emit_signal("location_selected",GlobalVars.player_focus)
	player_panel.visible = true
	button_go_back.visible = false
	_record_history(GlobalVars.player_focus,location_focus,turn_focus,ticket_use)
	if setup_mode == true:
		_disable_start_locations()
	else:
		_disable_possible_moves()

# Record the movement in the player's history log
func _record_history(player_history,location_history,_turn_history,mode_history) -> void:
	if setup_mode == true:
		#turn_history = 0
		mode_history = 4
	match player_history:
		1: 
			agent_01_loc_history.append(location_history)
			agent_01_mode_history.append(mode_history)
			#print("Agent 1 location history: ",agent_01_loc_history) # FOR TESTING
			#print("Agent 1 mode history: ",agent_01_mode_history) # FOR TESTING
		2: 
			agent_02_loc_history.append(location_history)
			agent_02_mode_history.append(mode_history)
			#print("Agent 2 location history: ",agent_02_loc_history) # FOR TESTING
			#print("Agent 2 mode history: ",agent_02_mode_history) # FOR TESTING
		3: 
			agent_03_loc_history.append(location_history)
			agent_03_mode_history.append(mode_history)
			#print("Agent 3 location history: ",agent_03_loc_history) # FOR TESTING
			#print("Agent 3 mode history: ",agent_03_mode_history) # FOR TESTING
		4: 
			agent_04_loc_history.append(location_history)
			agent_04_mode_history.append(mode_history)
			#print("Agent 4 location history: ",agent_04_loc_history) # FOR TESTING
			#print("Agent 4 mode history: ",agent_04_mode_history) # FOR TESTING
		5: 
			agent_05_loc_history.append(location_history)
			agent_05_mode_history.append(mode_history)
			#print("Agent 5 location history: ",agent_05_loc_history) # FOR TESTING
			#print("Agent 5 mode history: ",agent_05_mode_history) # FOR TESTING

# Move the player and set the location of the player in the location array
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

func _move_sus(move_what,move_to) -> void:
	var move_player = create_tween()
	move_player.tween_property(move_what, "position", location[move_to].position + Vector2(use_tile_size*use_tile_size_offset_b,use_tile_size*use_tile_size_offset_b),player_move_speed)
	await move_player.finished

func _process(_delta: float) -> void:
	if current_player_path.is_empty():
		get_viewport().gui_disable_input = false
		return
	get_viewport().gui_disable_input = true
	var target_position = tile_map_layer_sparta_nj.map_to_local(current_player_path.front())
	GlobalVars.player_focus_sprite.position = GlobalVars.player_focus_sprite.position.move_toward(target_position,player_move_speed_grid)
	if GlobalVars.player_focus_sprite.position == target_position:
		current_player_path.pop_front()

# Enable the possible moves for a player
func _on_player_panel_move_to_location(player_sprite: Variant, player_number: Variant, _turn_number: Variant) -> void:
	current_player_path.clear()
	GlobalVars.player_focus_sprite = player_sprite
	GlobalVars.player_focus = player_number
	#turn_focus = turn_number
	player_panel.visible = false
	button_go_back.visible = true
	_get_possible_moves(GlobalVars.player_focus)
	# Enable the location buttons for items in the array
	for n in range(adjusted_possible_moves):
		var enable_possible_location = possible_moves[n]
		location[enable_possible_location].disabled = false

# Accepts agent number, returns three arrays - possible moves, their modes and their thret level
func _get_possible_moves(agent_possible: Variant) -> void:
	# Get the player's current location
	location_focus = agent_location[agent_possible]
	# Get the number of gross possible moves for the agent's location from the JSON file
	num_possible_moves = int(JsonHandler.location_variables[location_focus]["num_eligible_destinations"])
	# Clear the arrays holding all the possible moves, their modes, and their threat levels
	possible_moves.clear()
	possible_moves_modes.clear()
	possible_moves_threat.clear()
	# Loop through the possible moves to populate the array from the JSON file
	for n in range(num_possible_moves):
		# Ignore this possible move if there are no tickets left for that mode
		var move_mode_eval = int(JsonHandler.location_variables[location_focus]["destinations"][n]["mode"])
		match GlobalVars.player_focus:
			1:
				if tickets_remaining_agent01[move_mode_eval] == 0:
					continue
			2:
				if tickets_remaining_agent02[move_mode_eval] == 0:
					continue
			3:
				if tickets_remaining_agent03[move_mode_eval] == 0:
					continue
			4:
				if tickets_remaining_agent04[move_mode_eval] == 0:
					continue
			5:
				if tickets_remaining_agent05[move_mode_eval] == 0:
					continue
		# Ignore this possible move if an agent occupies that location
		var location_eval = int(JsonHandler.location_variables[location_focus]["destinations"][n]["end_location"])
		if agent_location.has(location_eval):
			continue
		# If everything checks out, add that location to the array of possible moves
		possible_moves.append(int(JsonHandler.location_variables[location_focus]["destinations"][n]["end_location"]))
		possible_moves_modes.append(int(JsonHandler.location_variables[location_focus]["destinations"][n]["mode"]))
		adjusted_possible_moves = possible_moves.size()
		possible_moves_threat.resize(adjusted_possible_moves)

# For cleanup after a location is selected
func _disable_possible_moves() -> void:
	for n in range(adjusted_possible_moves):
		var enable_possible_location = possible_moves[n]
		location[enable_possible_location].disabled = true

# DEPRECATED - REPLACE THIS WITH DIALOGUE MANAGER
#func _on_game_message_message_ack(ack_type) -> void:
	#match ack_type:
		#1: # GlobalEnums.message_type.GAME_OVER:
			#_play_again()

func _get_sus_move(current_sus_focus, current_sus_location,sus_turn_num) -> void:
	location_focus = current_sus_location
	sus_focus = current_sus_focus
	var sus_num_possible_moves : int # Holds the number of possible moves for the suspect
	var sus_move_add : int # Possible location ID to be added to the array
	var sus_move_mode_add : int # Travel mode for location iD to be added to the array
	# Get the number of possible moves for the suspect's location from the JSON file
	sus_num_possible_moves = int(JsonHandler.location_variables[location_focus]["num_eligible_destinations"])
	# Clear the arrays holding all the possible sus moves
	possible_sus_moves.clear()
	possible_sus_moves_modes.clear()
	possible_sus_moves_threat.clear()
	possible_sus_moves_capture_1.clear()
	# Populate the array from the JSON file
	for n in range(sus_num_possible_moves):
		var move_mode_eval = int(JsonHandler.location_variables[location_focus]["destinations"][n]["mode"])
		# Ignore this possible move if there are no tickets left for that mode
		match sus_focus:
			0:
				if tickets_remaining_sus00[move_mode_eval] == 0:
					continue
		# Ignore this possible move if an agent occupies that location
		var location_eval = int(JsonHandler.location_variables[location_focus]["destinations"][n]["end_location"])
		if agent_location.has(location_eval) or sus_location.has(location_eval):
			continue
		# If everything checks out, populate the arrray with the possible move
		sus_move_add = int(JsonHandler.location_variables[location_focus]["destinations"][n]["end_location"])
		possible_sus_moves.append(sus_move_add)
		sus_move_mode_add = int(JsonHandler.location_variables[location_focus]["destinations"][n]["mode"])
		possible_sus_moves_modes.append(sus_move_mode_add)
		possible_sus_moves_threat.append(5) # Set to the lowest threat level for now
		possible_sus_moves_capture_1.append(0) # Set to zero the number of agents who can capture at that location in one move for now
	if possible_sus_moves.size() == 0:
		# If there are no possible moves, the agents have won.
		victory_condition = GlobalEnums.win_type.SURROUNDED
		_check_game_over()
	else:
		_assess_agent_moves()
		var possible_sus_moves_weighted : Array[int]
		var weighted_sus_move : int
		for x in range(possible_sus_moves.size()):
			if possible_sus_moves_weighted.has(possible_sus_moves[x]):
				continue
			# Get the weighted number of moves
			weighted_sus_move = GlobalVars.sus_threat_profile[possible_sus_moves_threat[x]]
			for y in weighted_sus_move:
				possible_sus_moves_weighted.append(possible_sus_moves[x])
		possible_sus_moves_weighted.shuffle() # randomize the array values
		sus_location[0] = possible_sus_moves_weighted[0] # pick the first value in the array as the location for the sus to move to
		_move_sus(sus_00,sus_location[0])
		GlobalVars.sus_00_loc_history.append(sus_location[0])
		# set the mode and mode history by getting the index value of the original array
		var find_selection_index = possible_sus_moves.find(sus_location[0])
		sus_mode_used = possible_sus_moves_modes[find_selection_index]
		GlobalVars.sus_00_mode_history.append(sus_mode_used)
		# Reduce the number of tickets for that node by 1
		tickets_remaining_sus00[sus_mode_used] = tickets_remaining_sus00[sus_mode_used] -1
		print("Sus history: ",GlobalVars.sus_00_loc_history) # FOR TESTING
		print("Sus mode history: ",GlobalVars.sus_00_mode_history)  # FOR TESTING
		#print("sus_profile: ",GlobalVars.sus_threat_profile) # FOR TESTING
		# Signal to player panel to enable move buttons and show move
		emit_signal("sus_moved",sus_focus,sus_mode_used,tickets_remaining_sus00[sus_mode_used],sus_turn_num)

func _play_again() -> void:
	agent_location.clear()
	sus_location.clear()
	sus_start.clear()
	agent_01_loc_history.clear()
	agent_02_loc_history.clear()
	agent_03_loc_history.clear()
	agent_04_loc_history.clear()
	agent_05_loc_history.clear()
	agent_01_mode_history.clear()
	agent_02_mode_history.clear()
	agent_03_mode_history.clear()
	agent_04_mode_history.clear()
	agent_05_mode_history.clear()
	GlobalVars.sus_00_loc_history.clear()
	GlobalVars.sus_00_mode_history.clear()
	tickets_remaining_agent01.clear()
	tickets_remaining_agent02.clear()
	tickets_remaining_agent03.clear()
	tickets_remaining_agent04.clear()
	tickets_remaining_agent05.clear()
	tickets_remaining_sus00.clear()
	GlobalVars.agent_name.clear()
	_initialize_player_tickets()
	_initialize_variables()
	# Reset player sprites and starting location
	var base_sprite : Texture2D
	base_sprite = load('res://art/player_sprites/ignoresprite.png')
	for n in [1,2,3,4,5]:
		player[n].visible = false
		player[n].texture = base_sprite
	sus_00.visible = false
	GlobalVars.restart = true	
	emit_signal("player_panel_restart")

func _assess_agent_moves() -> void:
	# For each agent, get the possible moves, put them into an array, and assign a threat level
	var second_possible_moves : Array[int] # holds the possible moves after making the first move
	# Loop through all agents
	for n in [1,2,3,4,5]:
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
						possible_sus_moves_threat[y] = 0
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

func _on_button_play_pressed() -> void:
	# Open the game start dialogue
	var dialogue_resource = load("res://dialog/dl_start.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
	button_play.visible = false

func _quit_game() -> void:
	button_play.visible = true
