extends Node

@onready var travel_mode : Array[String]
@onready var travel_mode_start_number : Array[int]
@onready var travel_mode_start_number_sus : Array[int]
@onready var start_locations : Array[int] # Holds all the start location buttons
@onready var sus_reveal_turn : Array[int] # Holds the turns when the suspect location is revealed
@onready var threat_level : Array[String] # Holds the threat level for possible moves
@onready var threat_profile_a : Array[int] # Hold threat profile A for threat risk factors
@onready var threat_profile_b : Array[int] # Hold threat profile B for threat risk factors
@onready var threat_profile_c : Array[int] # Hold threat profile B for threat risk factors
@onready var sus_threat_profile : Array[int] # Suspect threat profile used
@onready var agent_name : Array[String] # Names of the agents
@onready var sus_name : String # Name of suspect to be pursued
@onready var player_focus_sprite : Sprite2D # Identify the player (sprite) who has the focus
@onready var player_focus : int # Identify the player (number) who has the focus
@onready var mode_option : Array[int] # if multiple modes are avaialble for the turn
@onready var mode_option_selected: int # if multiple modes are avaialble for the turn
@onready var captured_by : int = 0 # Agent ID who captured the suspect
@onready var closest_agent : int # Agent ID who is the closest to the suspect
@onready var closest_distance : float # distance of closest agent to the suspect
@onready var restart : bool = false # indicator if the game has restarted
@onready var turn_number : int
@onready var turn_limit : int # turn limit for the suspect to win
@onready var sus_00_loc_history : Array[int]  # Holds the location history of the susppect as the game progresses
@onready var sus_00_mode_history : Array[int] # Holds the movement mode history of the suspect as the game progresses

# Variables used for dialogue manager
@onready var sus_last_move_type : String
@onready var sus_last_location_description : String
@onready var sus_last_location_num : int
@onready var sus_last_location_index : int
@onready var sus_mode_since_reveal : String # list of all travel modes since last reveal

# Signals used to selet the mode of transportation used by dialogue manager
signal hide_moves()
signal unhide_moves()
signal mode_choice_selected(choice)

# Other common signals, such as those used by the dialogue manager
signal team_selected_from_dialogue
signal sus_moves_first
signal play_again
signal quit

func _ready() -> void:
	_set_travel_modes()
	_set_starting_tickets()
	_set_start_locations()
	_set_sus_reveal_turns()
	_set_threat_level()
	_set_threat_profile_a()
	_set_threat_profile_b()
	_set_threat_profile_c()
	turn_limit = 22 # sets the turn limit before the suspect wins, prod limit is 22
	# FOR TESTING, comment out the next line after testing
	#agent_name = ["Arthur","Bertha","Cristobal","Dolly","Hanna"]

func _set_travel_modes() -> void:
	# Define the travel modes for the map. This can be configurable for different maps
	travel_mode.resize(9)
	travel_mode[0] = "Foot"
	travel_mode[1] = "Taxi"
	travel_mode[2] = "Shuttle"
	travel_mode[3] = "Special"
	travel_mode[4] = "Start"
	travel_mode[5] = "x2 Foot"
	travel_mode[6] = "x2 Taxi"
	travel_mode[7] = "x2 Shuttle"
	travel_mode[8] = "x2 Special"

func _set_starting_tickets() -> void:
	# Define the starting mumber of tickets for agents
	travel_mode_start_number.resize(4)
	travel_mode_start_number = [10,8,4,0]
	# Define the starting number of tickets for suspects
	travel_mode_start_number_sus.resize(4)
	travel_mode_start_number_sus = [4,3,3,2]

func _set_start_locations() -> void:
	# Hard code them for now
	start_locations.resize(18)
	start_locations = [8,12,29,41,46,54,59,62,94,99,115,127,129,144,161,178,188,199]

func _set_sus_reveal_turns() -> void:
	# Sets the turns when the suspect location is revealed
	#sus_reveal_turn = [2,4] # for TESTING
	#sus_reveal_turn = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24] # for TESTING
	sus_reveal_turn = [3,8,13,18,24] # This is the actual array

func _set_threat_level() -> void:
	threat_level.resize(6)
	threat_level[0] = "Agent has 1 move and can capture"
	threat_level[1] = "Two or more agents can capture in 1 move"
	threat_level[2] = "Agent has 2 moves and can capture"
	threat_level[3] = "Agent has 3 or more moves and can capture"
	threat_level[4] = "Agent can capture in 2 moves"
	threat_level[5] = "Agent can't reach in 2 moves"

func _set_threat_profile_a() -> void:
	# Choose a move at random
	threat_profile_a.resize(6)
	threat_profile_a = [1,1,1,1,1,1]
	
func _set_threat_profile_b() -> void:
	# Aggressive - takes risks
	threat_profile_b.resize(6)
	threat_profile_b = [1,2,4,5,7,10]
	
func _set_threat_profile_c() -> void:
	# Conservative
	threat_profile_c.resize(6)
	threat_profile_c = [1,2,4,5,10,20]
