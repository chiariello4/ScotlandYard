extends Node

# Declare common arrays
## Holds the description of the travel modes
@onready var travel_mode : Array[String]
## Defines the starting mumber of tickets for agents for each travel mode
@onready var travel_mode_start_number : Array[int]
## Defines the starting mumber of tickets for suspects for each travel mode
@onready var travel_mode_start_number_sus : Array[int]
## Holds all the start location buttons
@onready var start_locations : Array[int]
## Holds the turns when the suspect location is revealed
@onready var sus_reveal_turn : Array[int]
## Holds the threat level for possible moves
@onready var threat_level : Array[String]
## Hold threat profile A for threat risk factors
@onready var threat_profile_a : Array[int]
## Hold threat profile B for threat risk factors
@onready var threat_profile_b : Array[int]
## Hold threat profile C for threat risk factors
@onready var threat_profile_c : Array[int]
## Holds the travel mode options; used if multiple modes are avaialble for the turn
@onready var mode_option : Array[int]
## Holds the travel mode medium; used if multiple modes are avaialble for the turn
@onready var mode_medium_option : Array[String]
## Names of the agents who are players
@onready var agent_name : Array[String]
## Names of all possible agents
@onready var agent_roster : Array[String]
## Array of current player locations
@onready var agent_location : Array[int]
## Determines if an agent is out of moves or otherwise incapacitated
@onready var agent_incapacitated : Array[bool]
## Array of current suspect locations
@onready var sus_location : Array[int]
## Array of locations with listening devices
@onready var listening_device : Array[int]
## Names of the agents with special abilities
@onready var agents_with_special_abilities : Array[String]
## Holds locations that are blocked
@onready var blocked_location : Array[int]
## Holds sections of town
@onready var town_section : Array[String]
## Holds destination mediums, or types of pathways
@onready var destination_medium : Array[String]

# Create arrays to hold the location history for each player
## Holds the location history of agent 1 as the game progresses
@onready var agent_01_loc_history : Array[int]
## Holds the location history of agent 2 as the game progresses
@onready var agent_02_loc_history : Array[int]
## Holds the location history of agent 3 as the game progresses
@onready var agent_03_loc_history : Array[int]
## Holds the location history of agent 4 as the game progresses
@onready var agent_04_loc_history : Array[int]
## Holds the location history of agent 5 as the game progresses
@onready var agent_05_loc_history : Array[int]
## Holds the location history of the susppect as the game progresses
@onready var sus_00_loc_history : Array[int]

# Create arrays to hold the mode history for each player
## Holds the movement mode history of agent 1 as the game progresses
@onready var agent_01_mode_history : Array[int]
## Holds the movement mode history of agent 2 as the game progresses
@onready var agent_02_mode_history : Array[int]
## Holds the movement mode history of agent 3 as the game progresses
@onready var agent_03_mode_history : Array[int]
## Holds the movement mode history of agent 4 as the game progresses
@onready var agent_04_mode_history : Array[int]
## Holds the movement mode history of agent 5 as the game progresses
@onready var agent_05_mode_history : Array[int]
## Holds the movement mode history of the suspect as the game progresses
@onready var sus_00_mode_history : Array[int]

# Declare other common variables
## Number of agents/players in the game
@onready var agent_count : int
## Name of suspect to be pursued
@onready var sus_name : String
## Identify the player (sprite) who has the focus
@onready var player_focus_sprite : Sprite2D
## Identify the player (number) who has the focus
@onready var player_focus : int
## Identify the play (name) who has the focus
@onready var player_focus_name : String
## Selected mode if multiple modes are avaialble for the turn
@onready var mode_option_selected: int
## Selected travel medium if multiple modes are avaialble for the turn
@onready var medium_option_selected: String
## Agent ID who captured the suspect
@onready var captured_by : int = 0
# Agent ID who is the closest to the suspect
@onready var closest_agent : int
## Distance of closest agent to the suspect
@onready var closest_distance : float
## Indicator if the game has restarted
@onready var restart : bool = false
## Turn number
@onready var turn_number : int
## Turn limit for the suspect to win, used for victory (defeat) condition
@onready var turn_limit : int

# Variables for the behavior of the wild animal
## Turn that the wild animal is first placed on the map
@onready var wild_animal_start_turn : int
## Wild animal's (current) location ID
@onready var wild_animal_location : int
## Wild animal's (current) location section 
@onready var wild_animal_section : String
## Count of wild animal moves in the current town section
@onready var wild_animal_move_count : int
## Default number of moves before the wild animal moves to a new location
@onready var wild_animal_move_max : int
## Chance that the wild animal is revealed
@onready var wild_animal_reveal_chance : float
## Holds the locations in the section where the wild animal is located
@onready var wild_animal_section_locations : Array[int]
## Determines if the dispatcher has alerted the wild animal siting in that section, so it only happens once on the first time
@onready var wild_animal_section_spotted : bool = false
## Holds the section of town of the last wild animal siting
@onready var wild_animal_last_section_spotted : String
## Holds the turn number of the last wild animal siting
@onready var wild_animal_last_turn_spotted : int = 0
## Holds the turn number of ther last agent bear encounter
@onready var wild_animal_last_encounter : Array[int] = [0,0,0,0,0,0,0]
## Holds the number of turns since the agent's last wild animal encounter, during which the agent will calmly handle an encounter, and after which the agent will have a choice to wait.
@onready var wild_animal_agent_turns_until_choice : int

# Agent misbehavior variables
## Turn at which the agent misbehavior may start
@onready var agent_misbehavior_turn_start : Array[int]
## Agent misbehavior rate for the first occurance
@onready var agent_misbehavior_rate_1 : Array[float]
## Agent misbehavior rate for subsequent occurances
@onready var agent_misbehavior_rate_2 : Array[float]
## Agent last turn of misbehavior
@onready var agent_misbehavior_last : Array[int]
## Agent turns before misbehaving again
@onready var agent_misbehavior_turns : Array[float]
## Agent closest to Cristobal
@onready var agent_closest_to_cristobal : String
## Distance check to Cristobal
@onready var too_close_to_cristobal : int
## Original requested location name
@onready var original_location_name : String

# Suspect behavioral variables
## Suspect threat profile used
@onready var sus_threat_profile : Array[int]
## Determines if the sus may use a double-move, based on size of array possible_sus_moves_weighted in main.gd
@onready var sus_duress_limit_1 : int = 0
## Determines if the sus may use a double-move, based on size of array possible_sus_moves_weighted in main.gd, higher probability if under more duress
@onready var sus_duress_limit_2 : int = 0
## Chance of using special move for moderate duress
@onready var sus_duress_limit_1_prob : float = 0
## Chance of using special move for high duress
@onready var sus_duress_limit_2_prob : float = 0
## Number of double-moves the suspect can make
@onready var sus_num_2x_turns : int = 0
## Number of water moves the suspect can make
@onready var sus_num_water_moves : int = 0
## Number of concealed moves the suspect can make
@onready var sus_num_concealed_moves : int = 0
## Defines the sus duress level, equal to weighted number of possible moves
@onready var sus_duress : int = 0
## Describes the sus duress level, used by psychic agent based on sus_duress
@onready var sus_duress_level : String

 #Track remaining player tickets
## Remaining nuber of tickets for agent 1 for each mode, so tickets_remaining_agent01[0] is remaining tickets for mode 0
@onready var tickets_remaining_agent01 : Array[int]
## Remaining nuber of tickets for agent 2 for each mode, so tickets_remaining_agent02[0] is remaining tickets for mode 0
@onready var tickets_remaining_agent02 : Array[int]
## Remaining nuber of tickets for agent 3 for each mode, so tickets_remaining_agent03[0] is remaining tickets for mode 0
@onready var tickets_remaining_agent03 : Array[int]
## Remaining nuber of tickets for agent 4 for each mode, so tickets_remaining_agent04[0] is remaining tickets for mode 0
@onready var tickets_remaining_agent04 : Array[int]
## Remaining nuber of tickets for agent 5 for each mode, so tickets_remaining_agent05[0] is remaining tickets for mode 0
@onready var tickets_remaining_agent05 : Array[int]
## Remaining nuber of tickets for the suspect for each mode, so tickets_remaining_sus00[0] is remaining tickets for mode 0
@onready var tickets_remaining_sus00 : Array[int]

# Variables used for dialogue manager
## Suspect's last move mode
@onready var sus_last_move_type : String
## Suspect's most recently spotted location description
@onready var sus_last_location_description : String
## Suspect's most recently spotted location ID number
@onready var sus_last_location_num : int
## Suspect's turn number since the last spotted location
@onready var sus_last_location_index : int = 0
## List of all travel modes for the suspect since last reveal
@onready var sus_mode_since_reveal : String
## Identifies that a dialogue is active to prevent overlapping dialogues
@onready var dialogue_active : bool = false
## Holds the suspect's section of town relayed by the informant. It may not be accurate.
@onready var sus_section_response : String

# Variables used for dialogue manager when agent is selected
## Location name, includes the quadrant and the ID number
@onready var loc_name : String
## Location section
@onready var loc_section : String
## Location description
@onready var loc_description : String

# Signals used to selet the mode of transportation used by dialogue manager
@warning_ignore("unused_signal")
signal hide_moves()
@warning_ignore("unused_signal")
signal unhide_moves()
@warning_ignore("unused_signal")
signal mode_choice_selected(choice)

# Other common signals, such as those used by the dialogue manager
@warning_ignore("unused_signal")
signal team_selected_from_dialogue
@warning_ignore("unused_signal")
signal sus_moves_first
@warning_ignore("unused_signal")
signal play_again
@warning_ignore("unused_signal")
signal quit
@warning_ignore("unused_signal")
signal out_of_moves_check
@warning_ignore("unused_signal")
signal use_special
@warning_ignore("unused_signal")
signal blockade
@warning_ignore("unused_signal")
signal random_team
@warning_ignore("unused_signal")
signal skip_turn_wild_animal
@warning_ignore("unused_signal")
signal no_skip_turn_wild_animal

func _ready() -> void:
	_set_travel_modes()
	_set_starting_tickets()
	_set_start_locations()
	_set_sus_reveal_turns()
	_set_threat_level()
	_set_threat_profile_a()
	_set_threat_profile_b()
	_set_threat_profile_c()
	_set_wild_animal_behavior()
	_initialize_player_tickets()
	_set_agent_misbehavior()
	random_team.connect(_create_random_team)
	turn_limit = 22 # sets the turn limit before the suspect wins, prod limit is 22
	# Initialize array for agents who can't move
	agent_incapacitated.resize(6)
	agent_incapacitated[0] = true
	for n in range (1,agent_count + 1):
		agent_incapacitated[n] = false
	# There's work to do to make the agent count actually do something.
	agent_count = 5
	# Initialize other string variables
	agent_roster = ["Arthur","Bertha","Cristobal","Dolly","Edouard","Fay","Gonzalo","Hanna"]
	agents_with_special_abilities = ["Bertha","Edouard","Cristobal","Dolly","Hanna"] 
	town_section = ["Downtown Sparta","Andover","Camp Sacajawea","Franklin-Ogdensburg","Hampton-Newton","High School - Middle School - Station Park","Edison - Sparta Mountain","Lafayette","Lake Mohawk","Limecrest - North Village","Mount Paul","Pimple Hills - West Mountain","Pinkneyville - Sussex Mills","Weldon Brook","Woodport"]
	destination_medium = ["highway","path","path-public","road","water"]

## Creates a team made up of five randomly selected agents
func _create_random_team() -> void:
	var agent_roster_shuffle : Array[String]
	agent_roster_shuffle = agent_roster
	agent_name.clear()
	agent_roster_shuffle.shuffle()
	for i in 5:
		agent_name.append(agent_roster_shuffle[i])

## Defines the textural description of the travel mode (IDs).
func _set_travel_modes() -> void:
	# Define the travel modes for the map. This can be configurable for different maps
	travel_mode.resize(6)
	travel_mode[0] = "Foot"
	travel_mode[1] = "Taxi"
	travel_mode[2] = "Shuttle"
	travel_mode[3] = "Special"
	travel_mode[4] = "Start"
	travel_mode[5] = "Skip" # also used when the suspect uses a double-move

## Set the starting number of tickets by travel mode for agents and for the suspect
func _set_starting_tickets() -> void:
	# Define the starting mumber of tickets for agents
	travel_mode_start_number.resize(4)
	travel_mode_start_number = [10,8,4,2]
	#region FOR TESTING, SET HIGH NUMBER OF TICKETS
	#travel_mode_start_number = [90,90,90,0]
	#endregion
	# Define the starting number of tickets for suspects
	travel_mode_start_number_sus.resize(4)
	travel_mode_start_number_sus = [4,3,3,2]

## Determine the eligible start locations
func _set_start_locations() -> void:
	# Hard code them for now
	start_locations.resize(18)
	start_locations = [8,12,29,41,46,54,59,62,94,99,115,127,129,144,161,178,188,199]

## Set the suspect reveal turns. Has options for testing.
func _set_sus_reveal_turns() -> void:
	# Sets the turns when the suspect location is revealed
	sus_reveal_turn = [3,8,13,18,24] # This is the actual array from the game
	#region TESTING to enable suspect reveal
	#sus_reveal_turn = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24] # for TESTING
	#sus_reveal_turn = [2,4,6,8,10,12,14,16,18,20,22,24] # for TESTING
	#endregion

## Set the threat level of the agent to the suspect
func _set_threat_level() -> void:
	threat_level.resize(6)
	threat_level[0] = "Agent has 1 move and can capture"
	threat_level[1] = "Two or more agents can capture in 1 move"
	threat_level[2] = "Agent has 2 moves and can capture"
	threat_level[3] = "Agent has 3 or more moves and can capture"
	threat_level[4] = "Agent can capture in 2 moves"
	threat_level[5] = "Agent can't reach in 2 moves"

## Sets the suspect's threat profile, 'a' generates random moves and disregards all threats.
func _set_threat_profile_a() -> void:
	# Choose a move at random
	threat_profile_a.resize(6)
	threat_profile_a = [1,1,1,1,1,1]

## Sets the suspect's threat profile, 'b' sets an aggressive profile.
func _set_threat_profile_b() -> void:
	# Aggressive - takes risks
	threat_profile_b.resize(6)
	threat_profile_b = [1,2,4,5,7,10]

## Sets the suspect's threat profile, 'c' sets a conservative profile.
func _set_threat_profile_c() -> void:
	# Conservative
	threat_profile_c.resize(6)
	threat_profile_c = [1,2,4,5,10,20]

## Sets wild animal default behavior variables
func _set_wild_animal_behavior() -> void:
	wild_animal_start_turn = 2
	wild_animal_move_max = 5 # actual 5
	wild_animal_reveal_chance = 0.2 # actual 0.2
	wild_animal_agent_turns_until_choice = 8 # actual 8

## Re-initialize the starting player tickets
func _initialize_player_tickets() -> void:
	tickets_remaining_agent01.resize(4)
	tickets_remaining_agent02.resize(4)
	tickets_remaining_agent03.resize(4)
	tickets_remaining_agent04.resize(4)
	tickets_remaining_agent05.resize(4)
	for n in 4:
		tickets_remaining_agent01[n] = travel_mode_start_number[n]
		tickets_remaining_agent02[n] = travel_mode_start_number[n]
		tickets_remaining_agent03[n] = travel_mode_start_number[n]
		tickets_remaining_agent04[n] = travel_mode_start_number[n]
		tickets_remaining_agent05[n] = travel_mode_start_number[n]
#region TESTING end of game, sets all ticket counts to 1 for handling of remaining tickets
	#tickets_remaining_agent01[0] = 3
	#tickets_remaining_agent01[1] = 1
	#tickets_remaining_agent01[2] = 1
	#tickets_remaining_agent01[3] = 1
	#tickets_remaining_agent02[0] = 1
	#tickets_remaining_agent02[1] = 1
	#tickets_remaining_agent02[2] = 1
	#tickets_remaining_agent02[3] = 1
	#tickets_remaining_agent03[0] = 3
	#tickets_remaining_agent03[1] = 1
	#tickets_remaining_agent03[2] = 1
	#tickets_remaining_agent03[3] = 1
	#tickets_remaining_agent04[0] = 1
	#tickets_remaining_agent04[1] = 1
	#tickets_remaining_agent04[2] = 1
	#tickets_remaining_agent04[3] = 1
	#tickets_remaining_agent05[0] = 1
	#tickets_remaining_agent05[1] = 1
	#tickets_remaining_agent05[2] = 1
	#tickets_remaining_agent05[3] = 1
#endregion
	# Also for the suspect
	tickets_remaining_sus00.resize(4)
	for n in 4:
		tickets_remaining_sus00[n] = travel_mode_start_number_sus[n]

## This function generates an informant's response as to the suspect's section of town. It may generate a false lead.
func _sus_section_informant() -> void:
	var sus_section_accuracy : float = 0.9 # sets the accuracy of the informant
	var sus_section_accuracy_check : float
	var sus_section_actual : String
	var random_section_list : Array[String]
	sus_section_actual = JsonHandler.location_variables[sus_location[0]]["section"]
	random_section_list = town_section
	random_section_list.erase(sus_section_actual)
	sus_section_accuracy_check = randf()
	if sus_section_accuracy_check < sus_section_accuracy :
		sus_section_response = sus_section_actual
	else:
		sus_section_response = random_section_list.pick_random()

## This function sets agent misbehavior variables. Arrays uses the values from agent_roster to align the agent with the variables.
func _set_agent_misbehavior() -> void:
	#A - water, B - rogue moves, C - fights, D - doesn't like paths, E - lost on paths, F - out of shape, G - eats, H - social media adict
	# Set the rate of misbehavior for the first occurance
	agent_misbehavior_rate_1 = [0.5,0.25,0.5,1,0.5,1,0.5,1] #[0.5,0.25,0.5,1,0.5,1,0.5,1]
	# Set the rate of misbehavior for subsequent occurances
	agent_misbehavior_rate_2 = [0.33,0.25,0.25,0.25,0.25,0.25,0.25,0.25] #[0.33,0.25,0.25,0.25,0.25,0.25,0.25,0.25]
	# Set the first turn by which the agent's misbehavior will start to occur
	agent_misbehavior_turn_start = [1,4,1,1,5,10,4,4] #[1,4,1,1,5,10,4,4]
	# Set the number of turn after misbehavior before it can happen again
	agent_misbehavior_turns = [6,4,6,8,6,4,6,6] #[6,4,6,8,6,4,6,6]
	# Initialize the last turn that the misbehavior occured
	agent_misbehavior_last = [0,0,0,0,0,0,0,0]
	## Sets the distance of an agent to Cristobal before an argument ensues
	too_close_to_cristobal = 300
	
