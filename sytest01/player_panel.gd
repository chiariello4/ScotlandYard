extends Control

# Arrays for panel objects
@onready var agent_sprite : Array[Sprite2D]
@export var button_icon : Array[Button] # holds the agent icon buttons
@export var agent_label : Array[Label] # holds the agent name labels
@export var button_start_agent : Array[Button] # holds the agent start buttons
@export var button_move_agent : Array[Button] # holds the agent move buttons

# Objects for the ticket counters
@onready var margin_container_tickets_01: MarginContainer = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent01/MarginContainer_tickets_01
@onready var margin_container_tickets_02: MarginContainer = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent02/MarginContainer_tickets_02
@onready var margin_container_tickets_03: MarginContainer = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent03/MarginContainer_tickets_03
@onready var margin_container_tickets_04: MarginContainer = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent04/MarginContainer_tickets_04
@onready var margin_container_tickets_05: MarginContainer = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent05/MarginContainer_tickets_05

# Arrays for the label names by agent for each mode type
# Makes it easier to refer to the label
@onready var label_agent01_mode_name : Array[Label]
@onready var label_agent02_mode_name : Array[Label]
@onready var label_agent03_mode_name : Array[Label]
@onready var label_agent04_mode_name : Array[Label]
@onready var label_agent05_mode_name : Array[Label]
@onready var label_sus00_mode_name : Array[Label]

# Arrays to display the remaining tickets by agent for each mode type
@onready var label_agent01_mode_remaining_tickets : Array[Label]
@onready var label_agent02_mode_remaining_tickets : Array[Label]
@onready var label_agent03_mode_remaining_tickets : Array[Label]
@onready var label_agent04_mode_remaining_tickets : Array[Label]
@onready var label_agent05_mode_remaining_tickets : Array[Label]
@onready var label_sus00_mode_remaining_tickets : Array[Label]

# Other objects
@onready var player_panel: Control = $"."
@onready var button_done: Button = $PanelContainer/VBoxContainer/MarginContainer_Done/Button_Done
@onready var margin_container_turn: MarginContainer = $PanelContainer/VBoxContainer/MarginContainer_Turn
@onready var label_turn_count: Label = $PanelContainer/VBoxContainer/MarginContainer_Turn/HBoxContainer/Label_Turn_Count
@onready var label_sus_00_mode_used: Label = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/MarginContainer_LabelSus00/VBoxContainer/Label_Sus00_mode_used
@onready var v_box_container_tickest_s_00: VBoxContainer = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/HBoxContainer_Sus00/MarginContainer_tickets_S00/VBoxContainer_tickest_S00
@onready var sus_00: Sprite2D = $"../../Players/sus00"
@onready var panel_container_sus_player: PanelContainer = $"../PanelContainer_sus-player"
@onready var button_view_close: Button = $"../ButtonViewClose"
@onready var label_sus_00: Label = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/MarginContainer_LabelSus00/VBoxContainer/Label_Sus00
@onready var texture_rect_sus_00: TextureRect = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/HBoxContainer_Sus00/Button_Sus00/TextureRect_Sus00
@onready var button_sus_00: Button = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/HBoxContainer_Sus00/Button_Sus00

# Other Variables
var button_change : Button
var player_sprite : Sprite2D
var player_number : int
#var turn_number : int
var setup_mode : bool
var travel_mode : Array[String]

# Player start status arrays, ignore array 0
@export var player_location_ready : Array[bool]

# Signals
signal set_start_location(player,player_number)
signal setup_is_complete()
signal turn_is_complete()
signal move_to_location(player,player_number,turn_number)
signal viewport_focus(player)

func _ready() -> void:
	_basic_setup()
	_initialize_label_mode_objects()
	_setup_tickets()
	GlobalVars.team_selected_from_dialogue.connect(_ready_from_dialogue)
	GlobalVars.hide_moves.connect(_hide_move_buttons)
	GlobalVars.unhide_moves.connect(_show_move_buttons)

# After the setup dialog runs and agents are selected, set the button textures
func _ready_from_dialogue() -> void:
	var sprite_path : String
	for i in [1,2,3,4,5]:
		# Set agent button icons
		sprite_path = "res://art/player_sprites/%ssprite.png" % GlobalVars.agent_name[i].to_lower()
		#if FileAccess.file_exists(sprite_path): #REMOVED as it would not run in itch.io
		button_icon[i].icon = load(sprite_path)
		# Set agent name labels
		agent_label[i].text = GlobalVars.agent_name[i]
	# Set suspect button icon and label
	sprite_path = "res://art/player_sprites/%ssprite.png" % GlobalVars.sus_name.to_lower()
	label_sus_00.text = GlobalVars.sus_name
	button_sus_00.icon  = load(sprite_path)
	player_panel.visible = true

func _basic_setup() -> void:
	# Set the initial size of the arrays
	player_location_ready.resize(6)
	# Set array 0 to true just to get it out of the way
	player_location_ready[0] = true
	setup_mode = true
	button_done.text = "Complete Setup"
	# Fill array with agent sprites
	agent_sprite.resize(6)
	agent_sprite[0] = $"../../Players/agent01" # not used
	agent_sprite[1] = $"../../Players/agent01"
	agent_sprite[2] = $"../../Players/agent02"
	agent_sprite[3] = $"../../Players/agent03"
	agent_sprite[4] = $"../../Players/agent04"
	agent_sprite[5] = $"../../Players/agent05"

func _initialize_label_mode_objects() -> void:
	# for each agent, suspect, and for each mode, set the label object into the array
	# Agent 1 objects
	label_agent01_mode_name.resize(4)
	label_agent01_mode_name[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent01/MarginContainer_tickets_01/VBoxContainer_tickest_01/MarginContainer_01_mode0/HBoxContainer_01_mode0/Label_Title_01_mode0
	label_agent01_mode_name[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent01/MarginContainer_tickets_01/VBoxContainer_tickest_01/MarginContainer_01_mode1/HBoxContainer_01_mode1/Label_Title_01_mode1
	label_agent01_mode_name[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent01/MarginContainer_tickets_01/VBoxContainer_tickest_01/MarginContainer_01_mode2/HBoxContainer_01_mode2/Label_Title_01_mode2
	label_agent01_mode_name[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent01/MarginContainer_tickets_01/VBoxContainer_tickest_01/MarginContainer_01_mode3/HBoxContainer_01_mode3/Label_Title_01_mode3
	label_agent01_mode_remaining_tickets.resize(4)
	label_agent01_mode_remaining_tickets[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent01/MarginContainer_tickets_01/VBoxContainer_tickest_01/MarginContainer_01_mode0/HBoxContainer_01_mode0/Label_Amt_01_mode0
	label_agent01_mode_remaining_tickets[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent01/MarginContainer_tickets_01/VBoxContainer_tickest_01/MarginContainer_01_mode1/HBoxContainer_01_mode1/Label_Amt_01_mode1
	label_agent01_mode_remaining_tickets[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent01/MarginContainer_tickets_01/VBoxContainer_tickest_01/MarginContainer_01_mode2/HBoxContainer_01_mode2/Label_Amt_01_mode2
	label_agent01_mode_remaining_tickets[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent01/MarginContainer_tickets_01/VBoxContainer_tickest_01/MarginContainer_01_mode3/HBoxContainer_01_mode3/Label_Amt_01_mode3
	# Agemt 2 objects
	label_agent02_mode_name.resize(4)
	label_agent02_mode_name[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent02/MarginContainer_tickets_02/VBoxContainer_tickest_02/MarginContainer_02_mode0/HBoxContainer_02_mode0/Label_Title_02_mode0
	label_agent02_mode_name[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent02/MarginContainer_tickets_02/VBoxContainer_tickest_02/MarginContainer_02_mode1/HBoxContainer_02_mode1/Label_Title_02_mode1
	label_agent02_mode_name[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent02/MarginContainer_tickets_02/VBoxContainer_tickest_02/MarginContainer_02_mode2/HBoxContainer_02_mode2/Label_Title_02_mode2
	label_agent02_mode_name[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent02/MarginContainer_tickets_02/VBoxContainer_tickest_02/MarginContainer_02_mode3/HBoxContainer_02_mode3/Label_Title_02_mode3
	label_agent02_mode_remaining_tickets.resize(4)
	label_agent02_mode_remaining_tickets[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent02/MarginContainer_tickets_02/VBoxContainer_tickest_02/MarginContainer_02_mode0/HBoxContainer_02_mode0/Label_Amt_02_mode0
	label_agent02_mode_remaining_tickets[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent02/MarginContainer_tickets_02/VBoxContainer_tickest_02/MarginContainer_02_mode1/HBoxContainer_02_mode1/Label_Amt_02_mode1
	label_agent02_mode_remaining_tickets[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent02/MarginContainer_tickets_02/VBoxContainer_tickest_02/MarginContainer_02_mode2/HBoxContainer_02_mode2/Label_Amt_02_mode2
	label_agent02_mode_remaining_tickets[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent02/MarginContainer_tickets_02/VBoxContainer_tickest_02/MarginContainer_02_mode3/HBoxContainer_02_mode3/Label_Amt_02_mode3
	# Agemt 3 objects
	label_agent03_mode_name.resize(4)
	label_agent03_mode_name[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent03/MarginContainer_tickets_03/VBoxContainer_tickest_03/MarginContainer_03_mode0/HBoxContainer_03_mode0/Label_Title_03_mode0
	label_agent03_mode_name[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent03/MarginContainer_tickets_03/VBoxContainer_tickest_03/MarginContainer_03_mode1/HBoxContainer_03_mode1/Label_Title_03_mode1
	label_agent03_mode_name[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent03/MarginContainer_tickets_03/VBoxContainer_tickest_03/MarginContainer_03_mode2/HBoxContainer_03_mode2/Label_Title_03_mode2
	label_agent03_mode_name[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent03/MarginContainer_tickets_03/VBoxContainer_tickest_03/MarginContainer_03_mode3/HBoxContainer_03_mode3/Label_Title_03_mode3
	label_agent03_mode_remaining_tickets.resize(4)
	label_agent03_mode_remaining_tickets[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent03/MarginContainer_tickets_03/VBoxContainer_tickest_03/MarginContainer_03_mode0/HBoxContainer_03_mode0/Label_Amt_03_mode0
	label_agent03_mode_remaining_tickets[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent03/MarginContainer_tickets_03/VBoxContainer_tickest_03/MarginContainer_03_mode1/HBoxContainer_03_mode1/Label_Amt_03_mode1
	label_agent03_mode_remaining_tickets[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent03/MarginContainer_tickets_03/VBoxContainer_tickest_03/MarginContainer_03_mode2/HBoxContainer_03_mode2/Label_Amt_03_mode2
	label_agent03_mode_remaining_tickets[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent03/MarginContainer_tickets_03/VBoxContainer_tickest_03/MarginContainer_03_mode3/HBoxContainer_03_mode3/Label_Amt_03_mode3
	# Agemt 4 objects
	label_agent04_mode_name.resize(4)
	label_agent04_mode_name[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent04/MarginContainer_tickets_04/VBoxContainer_tickest_04/MarginContainer_04_mode0/HBoxContainer_04_mode0/Label_Title_04_mode0
	label_agent04_mode_name[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent04/MarginContainer_tickets_04/VBoxContainer_tickest_04/MarginContainer_04_mode1/HBoxContainer_04_mode1/Label_Title_04_mode1
	label_agent04_mode_name[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent04/MarginContainer_tickets_04/VBoxContainer_tickest_04/MarginContainer_04_mode2/HBoxContainer_04_mode2/Label_Title_04_mode2
	label_agent04_mode_name[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent04/MarginContainer_tickets_04/VBoxContainer_tickest_04/MarginContainer_04_mode3/HBoxContainer_04_mode3/Label_Title_04_mode3
	label_agent04_mode_remaining_tickets.resize(4)
	label_agent04_mode_remaining_tickets[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent04/MarginContainer_tickets_04/VBoxContainer_tickest_04/MarginContainer_04_mode0/HBoxContainer_04_mode0/Label_Amt_04_mode0
	label_agent04_mode_remaining_tickets[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent04/MarginContainer_tickets_04/VBoxContainer_tickest_04/MarginContainer_04_mode1/HBoxContainer_04_mode1/Label_Amt_04_mode1
	label_agent04_mode_remaining_tickets[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent04/MarginContainer_tickets_04/VBoxContainer_tickest_04/MarginContainer_04_mode2/HBoxContainer_04_mode2/Label_Amt_04_mode2
	label_agent04_mode_remaining_tickets[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent04/MarginContainer_tickets_04/VBoxContainer_tickest_04/MarginContainer_04_mode3/HBoxContainer_04_mode3/Label_Amt_04_mode3
	# Agemt 5 objects
	label_agent05_mode_name.resize(4)
	label_agent05_mode_name[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent05/MarginContainer_tickets_05/VBoxContainer_tickest_05/MarginContainer_05_mode0/HBoxContainer_05_mode0/Label_Title_05_mode0
	label_agent05_mode_name[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent05/MarginContainer_tickets_05/VBoxContainer_tickest_05/MarginContainer_05_mode1/HBoxContainer_05_mode1/Label_Title_05_mode1
	label_agent05_mode_name[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent05/MarginContainer_tickets_05/VBoxContainer_tickest_05/MarginContainer_05_mode2/HBoxContainer_05_mode2/Label_Title_05_mode2
	label_agent05_mode_name[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent05/MarginContainer_tickets_05/VBoxContainer_tickest_05/MarginContainer_05_mode3/HBoxContainer_05_mode3/Label_Title_05_mode3
	label_agent05_mode_remaining_tickets.resize(4)
	label_agent05_mode_remaining_tickets[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent05/MarginContainer_tickets_05/VBoxContainer_tickest_05/MarginContainer_05_mode0/HBoxContainer_05_mode0/Label_Amt_05_mode0
	label_agent05_mode_remaining_tickets[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent05/MarginContainer_tickets_05/VBoxContainer_tickest_05/MarginContainer_05_mode1/HBoxContainer_05_mode1/Label_Amt_05_mode1
	label_agent05_mode_remaining_tickets[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent05/MarginContainer_tickets_05/VBoxContainer_tickest_05/MarginContainer_05_mode2/HBoxContainer_05_mode2/Label_Amt_05_mode2
	label_agent05_mode_remaining_tickets[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent05/MarginContainer_tickets_05/VBoxContainer_tickest_05/MarginContainer_05_mode3/HBoxContainer_05_mode3/Label_Amt_05_mode3
	# Sus 0 ojbects
	label_sus00_mode_name.resize(4)
	label_sus00_mode_name[0] = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/HBoxContainer_Sus00/MarginContainer_tickets_S00/VBoxContainer_tickest_S00/MarginContainer_S00_mode0/HBoxContainer_S00_mode0/Label_Title_S00_mode0
	label_sus00_mode_name[1] = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/HBoxContainer_Sus00/MarginContainer_tickets_S00/VBoxContainer_tickest_S00/MarginContainer_S00_mode1/HBoxContainer_S00_mode1/Label_Title_S00_mode1
	label_sus00_mode_name[2] = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/HBoxContainer_Sus00/MarginContainer_tickets_S00/VBoxContainer_tickest_S00/MarginContainer_S00_mode2/HBoxContainer_S00_mode2/Label_Title_S00_mode2
	label_sus00_mode_name[3] = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/HBoxContainer_Sus00/MarginContainer_tickets_S00/VBoxContainer_tickest_S00/MarginContainer_S00_mode3/HBoxContainer_S00_mode3/Label_Title_S00_mode3
	label_sus00_mode_remaining_tickets.resize(4)
	label_sus00_mode_remaining_tickets[0] = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/HBoxContainer_Sus00/MarginContainer_tickets_S00/VBoxContainer_tickest_S00/MarginContainer_S00_mode0/HBoxContainer_S00_mode0/Label_Amt_S00_mode0
	label_sus00_mode_remaining_tickets[1] = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/HBoxContainer_Sus00/MarginContainer_tickets_S00/VBoxContainer_tickest_S00/MarginContainer_S00_mode1/HBoxContainer_S00_mode1/Label_Amt_S00_mode1
	label_sus00_mode_remaining_tickets[2] = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/HBoxContainer_Sus00/MarginContainer_tickets_S00/VBoxContainer_tickest_S00/MarginContainer_S00_mode2/HBoxContainer_S00_mode2/Label_Amt_S00_mode2
	label_sus00_mode_remaining_tickets[3] = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/HBoxContainer_Sus00/MarginContainer_tickets_S00/VBoxContainer_tickest_S00/MarginContainer_S00_mode3/HBoxContainer_S00_mode3/Label_Amt_S00_mode3

func _setup_tickets() -> void:
# Setup ticket label object mode names and remaining tickets
	for n in 4:
		label_agent01_mode_name[n].text = GlobalVars.travel_mode[n]
		label_agent02_mode_name[n].text = GlobalVars.travel_mode[n]
		label_agent03_mode_name[n].text = GlobalVars.travel_mode[n]
		label_agent04_mode_name[n].text = GlobalVars.travel_mode[n]
		label_agent05_mode_name[n].text = GlobalVars.travel_mode[n]
		label_sus00_mode_name[n].text = GlobalVars.travel_mode[n]
		label_agent01_mode_remaining_tickets[n].text = str(GlobalVars.travel_mode_start_number[n])
		label_agent02_mode_remaining_tickets[n].text = str(GlobalVars.travel_mode_start_number[n])
		label_agent03_mode_remaining_tickets[n].text = str(GlobalVars.travel_mode_start_number[n])
		label_agent04_mode_remaining_tickets[n].text = str(GlobalVars.travel_mode_start_number[n])
		label_agent05_mode_remaining_tickets[n].text = str(GlobalVars.travel_mode_start_number[n])
		label_sus00_mode_remaining_tickets[n].text = str(GlobalVars.travel_mode_start_number_sus[n])

# When an agent button is selected, show where the agent is.
func _on_button_icon_agent_pressed(num) -> void:
	var player_send = agent_sprite[num]
	if setup_mode == false:
		panel_container_sus_player.visible = true
		button_view_close.visible = true
		emit_signal("viewport_focus",player_send)
	else:
		GlobalVars.player_focus = num
		var dialogue_resource = load("res://dialog/dl_agent.dialogue")
		DialogueManager.show_dialogue_balloon(dialogue_resource, "waittodeploy")

# When the suspect button is selected, show where the suspect is if the suspect is revealed.
func _on_button_sus_00_pressed() -> void:
	var sus_next_location_index : int
	if setup_mode == true :
		var dialogue_resource = load("res://dialog/dl_sus.dialogue")
		DialogueManager.show_dialogue_balloon(dialogue_resource, "taunt")
	elif GlobalVars.sus_reveal_turn.has(GlobalVars.turn_number) :
		var player_send = sus_00
		panel_container_sus_player.visible = true
		button_view_close.visible = true
		emit_signal("viewport_focus",player_send)
	elif GlobalVars.turn_number < GlobalVars.sus_reveal_turn[0] :
		sus_next_location_index = 0
		_get_sus_recent_moves(sus_next_location_index)
		var dialogue_resource = load("res://dialog/dl_sus.dialogue")
		DialogueManager.show_dialogue_balloon(dialogue_resource, "location")
	else :
		sus_next_location_index = GlobalVars.sus_last_location_index + 1
		_get_sus_recent_moves(sus_next_location_index) 
		var dialogue_resource = load("res://dialog/dl_sus.dialogue")
		DialogueManager.show_dialogue_balloon(dialogue_resource, "location")

func _get_sus_recent_moves(index) -> void:
	GlobalVars.sus_mode_since_reveal = ""
	var sus_mode_append : String
	var counter : int = 1
	var start_counter : int = 0
	for n in (GlobalVars.sus_00_mode_history.size()-1):
		if index != 0 : start_counter = GlobalVars.sus_reveal_turn[index - 1]
		if (start_counter + counter) <= GlobalVars.sus_00_mode_history.size() - 1 :
			sus_mode_append = GlobalVars.travel_mode[GlobalVars.sus_00_mode_history[(start_counter + counter)]]
			if counter == 1:
				GlobalVars.sus_mode_since_reveal = GlobalVars.sus_mode_since_reveal + sus_mode_append
			else:
				GlobalVars.sus_mode_since_reveal = GlobalVars.sus_mode_since_reveal + ", then by " + sus_mode_append
			counter += 1
		else:
			break

# Functions for setting the player being moved during setup
func _on_button_start_agent_pressed(num) -> void:
	player_sprite = agent_sprite[num]
	player_number = num
	emit_signal("set_start_location",player_sprite,player_number)

# Signal from the Main node after a location is selected
func _on_main_location_selected(player_number_start: Variant) -> void:
	player_location_ready[player_number_start] = true
	if setup_mode == false:
		# Disable the move buttons after a player has moved
		button_move_agent[player_number_start].disabled = true
	_enable_setup_done() #Check if setup complete

# Check to see if the setup is complete
func _enable_setup_done():
	if player_location_ready.has(false):
		button_done.disabled = true
	else:
		button_done.disabled = false

# End setup and start and regular game
func _on_button_done_pressed() -> void:
	button_done.disabled = true
	if setup_mode == true:
		for n in range(button_move_agent.size()):
			button_move_agent[n].disabled = false
		_setup_cleanup()
		setup_mode = false
		label_sus_00_mode_used.visible = true
		v_box_container_tickest_s_00.visible = true
		emit_signal("setup_is_complete")
	else:
		emit_signal("turn_is_complete")
	# Reset the player move status
	for i in range(player_location_ready.size()):
		player_location_ready[i] = false
	player_location_ready[0] = true # we don't use player 0

# Clean up some items, only when in setup mode
func _setup_cleanup() -> void:
	for n in range(button_start_agent.size()):
		button_start_agent[n].disabled = true
		button_start_agent[n].visible = false
	margin_container_tickets_01.visible = true
	margin_container_tickets_02.visible = true
	margin_container_tickets_03.visible = true
	margin_container_tickets_04.visible = true
	margin_container_tickets_05.visible = true
	# General functions
	_show_move_buttons()
	_disable_move_buttons()
	margin_container_turn.visible = true
	button_done.text = "End Turn"

func _on_button_move_agent_pressed(num) -> void:
	player_sprite = agent_sprite[num]
	player_number = num
	emit_signal("move_to_location",player_sprite,player_number,GlobalVars.turn_number)

func _on_main_ticket_used(player_number_used: Variant, mode_used: Variant, remaining: Variant, remaining_sus: Variant) -> void:
	match player_number_used:
		1:
			label_agent01_mode_remaining_tickets[mode_used].text = str(remaining)
		2:
			label_agent02_mode_remaining_tickets[mode_used].text = str(remaining)
		3:
			label_agent03_mode_remaining_tickets[mode_used].text = str(remaining)
		4:
			label_agent04_mode_remaining_tickets[mode_used].text = str(remaining)
		5:
			label_agent05_mode_remaining_tickets[mode_used].text = str(remaining)
	label_sus00_mode_remaining_tickets[mode_used].text = str(remaining_sus)

func _hide_move_buttons() -> void:
	for n in range(button_move_agent.size()):
		button_move_agent[n].visible = false

func _show_move_buttons() -> void:
	for n in range(button_move_agent.size()):
		button_move_agent[n].visible = true

func _enable_move_buttons() -> void:
	for n in range(button_move_agent.size()):
		button_move_agent[n].disabled = false

func _disable_move_buttons() -> void:
	for n in range(button_move_agent.size()):
		button_move_agent[n].disabled = true

func _on_main_sus_moved(sus_moved_num: Variant, sus_mode_used: Variant, sus_remaining: Variant, sus_moved_turn: Variant) -> void:
	var sus_mode_text : String
	GlobalVars.turn_number = sus_moved_turn
	label_turn_count.text = str(sus_moved_turn)
	sus_mode_text = "Turn "
	sus_mode_text += str(sus_moved_turn)
	sus_mode_text += ": "
	sus_mode_text += GlobalVars.travel_mode[sus_mode_used]
	label_sus_00_mode_used.text = sus_mode_text
	label_sus00_mode_remaining_tickets[sus_mode_used].text = str(sus_remaining)
	#_show_move_buttons()
	_enable_move_buttons()
	# Reveal or hide suspect based on turn number
	var dialogue_resource = load("res://dialog/dl_dispatch.dialogue")
	if GlobalVars.sus_reveal_turn.has(sus_moved_turn):
		sus_00.visible = true
		GlobalVars.sus_last_location_num = GlobalVars.sus_00_loc_history[-1] # set the last known suspect location to the suspect's current location number
		GlobalVars.sus_last_location_index = GlobalVars.sus_reveal_turn.find(sus_moved_turn)
		GlobalVars.sus_last_location_description = "Location " + str(GlobalVars.sus_last_location_num)
		panel_container_sus_player.visible = true
		button_view_close.visible = true
		if sus_moved_turn > 1 : DialogueManager.show_dialogue_balloon(dialogue_resource, "susreveal")
		emit_signal("viewport_focus",sus_00)
	else:
		sus_00.visible = false
		panel_container_sus_player.visible = false
		button_view_close.visible = false
		if sus_moved_turn > 2 and GlobalVars.sus_reveal_turn.has(sus_moved_turn - 1):
			DialogueManager.show_dialogue_balloon(dialogue_resource, "suslost")

func _on_main_stop_moves() -> void:
	_hide_move_buttons()

func _on_main_player_panel_restart() -> void:
	player_location_ready.clear()
	_basic_setup()
	_initialize_label_mode_objects()
	_setup_tickets()
	GlobalVars.turn_number = 0
	# Common agent functions
	for n in range (0,6):
		button_start_agent[n].disabled = false
		button_start_agent[n].visible = true
		button_move_agent[n].disabled = true
	margin_container_tickets_01.visible = false
	margin_container_tickets_02.visible = false
	margin_container_tickets_03.visible = false
	margin_container_tickets_04.visible = false
	margin_container_tickets_05.visible = false
	# Other reset functions
	margin_container_turn.visible = false
	button_done.disabled = true
	label_sus_00_mode_used.visible = false
	v_box_container_tickest_s_00.visible = false
	# Reset the agent names and icons
	var sprite_path : String
	for i in [1,2,3,4,5]:
		# Set agent button icons
		sprite_path = "res://art/player_sprites/ignoresprite.png"
		# if FileAccess.file_exists(sprite_path): # REMOVED as it would not run in itch.io
		button_icon[i].icon = load(sprite_path)
		# Set agent name labels
		agent_label[i].text = "Agent " + str(i)
	# Set suspect button icon and label
	sprite_path = "res://art/player_sprites/select32.png"
	label_sus_00.text = "Suspect"
	button_sus_00.icon  = load(sprite_path)
	GlobalVars.sus_name = ""
	# NEXT LINE FOR TESTING
	#GlobalVars.agent_name = ["Arthur","Bertha","Cristobal","Dolly","Hanna"] # uncomment out for TESTING
	# Open the game start dialogue
	var dialogue_resource = load("res://dialog/dl_start.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue_resource, "SuspectList")

func _on_button_view_close_pressed() -> void:
	panel_container_sus_player.visible = false
	button_view_close.visible = false
