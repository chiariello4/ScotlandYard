extends Control

# Arrays for panel objects
## Holds the agent sprites in an array by agent number
@onready var agent_sprite : Array[Sprite2D]

# Player start status arrays, ignore array 0
## Holds the start-ready status of the agents during setup
@onready var player_location_ready : Array[bool] = []

# Arrays that were once performed using export, but it stopped working. Now using a work-around.
## Holds the agent icon buttons node paths
@export var button_icon_path : Array[NodePath] = []
## Holds the agent icon buttons
@onready var button_icon : Array[Button]
## Holds the agent label node paths
@export var agent_label_path : Array[NodePath] = []
## Holds the agent name labels
@onready var agent_label : Array[Label]
## Holds the agent button start node paths
@export var button_start_agent_path : Array[NodePath] = []
## Holds the agent start buttons
@onready var button_start_agent : Array[Button] = []
## Holds the agent button move node ptahs
@export var button_move_agent_path : Array[NodePath] = []
## Holds the agent move buttons
@onready var button_move_agent : Array[Button] = []

# Objects for the ticket counters
@onready var margin_container_tickets_01: MarginContainer = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent01/MarginContainer_tickets_01
@onready var margin_container_tickets_02: MarginContainer = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent02/MarginContainer_tickets_02
@onready var margin_container_tickets_03: MarginContainer = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent03/MarginContainer_tickets_03
@onready var margin_container_tickets_04: MarginContainer = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent04/MarginContainer_tickets_04
@onready var margin_container_tickets_05: MarginContainer = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent05/MarginContainer_tickets_05

# Agent icon buttons, because the export inexplicably stopped working
@onready var button_icon_agent_01: Button = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent01/ButtonIcon_Agent01
@onready var button_icon_agent_02: Button = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent02/ButtonIcon_Agent02
@onready var button_icon_agent_03: Button = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent03/ButtonIcon_Agent03
@onready var button_icon_agent_04: Button = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent04/ButtonIcon_Agent04
@onready var button_icon_agent_05: Button = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent05/ButtonIcon_Agent05

# Arrays for the label names by agent for each mode type; makes it easier to refer to the label
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
var setup_mode : bool
var travel_mode : Array[String]

# Signals
signal set_start_location(player,player_number)
signal setup_is_complete()
signal turn_is_complete()
signal move_to_location(player,player_number,turn_number)
signal viewport_focus(player)
signal double_move()

func _ready() -> void:
	_basic_setup()
	_initialize_agent_sprite()
	_initialize_label_mode_objects()
	_setup_tickets()
	# This is stupid, load the node arrays from the node paths because export arrays stopped working. This is a work-around.
	# First use export for node paths, then load the 'real' array of nodes from the export array.
	for path_bi in button_icon_path:
		button_icon.append(get_node(path_bi))
	for path_al in agent_label_path:
		agent_label.append(get_node(path_al))
	for path_bsa in button_start_agent_path:
		button_start_agent.append(get_node(path_bsa))
	for path_bma in button_move_agent_path:
		button_move_agent.append(get_node(path_bma))
	GlobalVars.team_selected_from_dialogue.connect(_ready_from_dialogue)
	GlobalVars.hide_moves.connect(_hide_move_buttons)
	GlobalVars.unhide_moves.connect(_show_move_buttons)

## After the setup dialog runs and agents are selected, set the button textures
func _ready_from_dialogue() -> void:
	_set_sus_variables()
	var sprite_path : String
	for i in range (1,GlobalVars.agent_count + 1):
		# Set agent button icons
		sprite_path = "res://art/player_sprites/%ssprite.png" % GlobalVars.agent_name[i].to_lower()
		button_icon[i].icon = load(sprite_path)
		# This does not work on the web:
		#if FileAccess.file_exists(sprite_path):
			#button_icon[i].icon = load(sprite_path)
		# Set agent name labels
		agent_label[i].text = GlobalVars.agent_name[i]
	# Set suspect button icon and label
	sprite_path = "res://art/player_sprites/%ssprite.png" % GlobalVars.sus_name.to_lower()
	label_sus_00.text = GlobalVars.sus_name
	button_sus_00.icon  = load(sprite_path)
	player_panel.visible = true
	_special_agent_ticket_start()
	_set_remaining_tickets()

## Adjust the starting ticket count for agents with special abilities
func _special_agent_ticket_start() -> void:
	if GlobalVars.agent_name.has("Fay"):
		# find index value for Fay
		var index_fay = GlobalVars.agent_name.find("Fay")
		# replace starting tickets [10,8,4,2] with [20,3,1,0]
		match index_fay:
			1:
				GlobalVars.tickets_remaining_agent01.clear()
				GlobalVars.tickets_remaining_agent01 = [20,3,1,0]
			2:
				GlobalVars.tickets_remaining_agent02.clear()
				GlobalVars.tickets_remaining_agent02 = [20,3,1,0]
			3:
				GlobalVars.tickets_remaining_agent03.clear()
				GlobalVars.tickets_remaining_agent03 = [20,3,1,0]
			4:
				GlobalVars.tickets_remaining_agent04.clear()
				GlobalVars.tickets_remaining_agent04 = [20,3,1,0]
			5:
				GlobalVars.tickets_remaining_agent05.clear()
				GlobalVars.tickets_remaining_agent05 = [20,3,1,0]
	if GlobalVars.agent_name.has("Gonzalo"):
		# find index value for Gonzalo
		var index_fay = GlobalVars.agent_name.find("Gonzalo")
		# replace starting tickets [10,8,4,2] with [3,14,7,0]
		match index_fay:
			1:
				GlobalVars.tickets_remaining_agent01.clear()
				GlobalVars.tickets_remaining_agent01 = [4,13,7,0]
			2:
				GlobalVars.tickets_remaining_agent02.clear()
				GlobalVars.tickets_remaining_agent02 = [4,13,7,0]
			3:
				GlobalVars.tickets_remaining_agent03.clear()
				GlobalVars.tickets_remaining_agent03 = [4,13,7,0]
			4:
				GlobalVars.tickets_remaining_agent04.clear()
				GlobalVars.tickets_remaining_agent04 = [4,13,7,0]
			5:
				GlobalVars.tickets_remaining_agent05.clear()
				GlobalVars.tickets_remaining_agent05 = [4,13,7,0]

## Performs some basic game setup tasks
func _basic_setup() -> void:
	# Set the initial size of the arrays
	player_location_ready.resize(6)
	# Set array 0 to true just to get it out of the way
	player_location_ready[0] = true
	setup_mode = true
	button_done.text = "Complete Setup"

## Fill array with agent sprites
func _initialize_agent_sprite() -> void:
	agent_sprite.resize(6)
	agent_sprite[0] = $"../../Players/agent01" # not used
	agent_sprite[1] = $"../../Players/agent01"
	agent_sprite[2] = $"../../Players/agent02"
	agent_sprite[3] = $"../../Players/agent03"
	agent_sprite[4] = $"../../Players/agent04"
	agent_sprite[5] = $"../../Players/agent05"

## For each agent, suspect, and for each mode, set the label object into the array
func _initialize_label_mode_objects() -> void:
	# Agent 1 objects
	label_agent01_mode_name.clear()
	label_agent01_mode_name.resize(4)
	label_agent01_mode_name[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent01/MarginContainer_tickets_01/VBoxContainer_tickest_01/MarginContainer_01_mode0/HBoxContainer_01_mode0/Label_Title_01_mode0
	label_agent01_mode_name[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent01/MarginContainer_tickets_01/VBoxContainer_tickest_01/MarginContainer_01_mode1/HBoxContainer_01_mode1/Label_Title_01_mode1
	label_agent01_mode_name[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent01/MarginContainer_tickets_01/VBoxContainer_tickest_01/MarginContainer_01_mode2/HBoxContainer_01_mode2/Label_Title_01_mode2
	label_agent01_mode_name[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent01/MarginContainer_tickets_01/VBoxContainer_tickest_01/MarginContainer_01_mode3/HBoxContainer_01_mode3/Label_Title_01_mode3
	label_agent01_mode_remaining_tickets.clear()
	label_agent01_mode_remaining_tickets.resize(4)
	label_agent01_mode_remaining_tickets[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent01/MarginContainer_tickets_01/VBoxContainer_tickest_01/MarginContainer_01_mode0/HBoxContainer_01_mode0/Label_Amt_01_mode0
	label_agent01_mode_remaining_tickets[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent01/MarginContainer_tickets_01/VBoxContainer_tickest_01/MarginContainer_01_mode1/HBoxContainer_01_mode1/Label_Amt_01_mode1
	label_agent01_mode_remaining_tickets[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent01/MarginContainer_tickets_01/VBoxContainer_tickest_01/MarginContainer_01_mode2/HBoxContainer_01_mode2/Label_Amt_01_mode2
	label_agent01_mode_remaining_tickets[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent01/MarginContainer_tickets_01/VBoxContainer_tickest_01/MarginContainer_01_mode3/HBoxContainer_01_mode3/Label_Amt_01_mode3
	# Agent 2 objects
	label_agent02_mode_name.clear()
	label_agent02_mode_name.resize(4)
	label_agent02_mode_name[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent02/MarginContainer_tickets_02/VBoxContainer_tickest_02/MarginContainer_02_mode0/HBoxContainer_02_mode0/Label_Title_02_mode0
	label_agent02_mode_name[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent02/MarginContainer_tickets_02/VBoxContainer_tickest_02/MarginContainer_02_mode1/HBoxContainer_02_mode1/Label_Title_02_mode1
	label_agent02_mode_name[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent02/MarginContainer_tickets_02/VBoxContainer_tickest_02/MarginContainer_02_mode2/HBoxContainer_02_mode2/Label_Title_02_mode2
	label_agent02_mode_name[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent02/MarginContainer_tickets_02/VBoxContainer_tickest_02/MarginContainer_02_mode3/HBoxContainer_02_mode3/Label_Title_02_mode3
	label_agent02_mode_remaining_tickets.clear()
	label_agent02_mode_remaining_tickets.resize(4)
	label_agent02_mode_remaining_tickets[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent02/MarginContainer_tickets_02/VBoxContainer_tickest_02/MarginContainer_02_mode0/HBoxContainer_02_mode0/Label_Amt_02_mode0
	label_agent02_mode_remaining_tickets[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent02/MarginContainer_tickets_02/VBoxContainer_tickest_02/MarginContainer_02_mode1/HBoxContainer_02_mode1/Label_Amt_02_mode1
	label_agent02_mode_remaining_tickets[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent02/MarginContainer_tickets_02/VBoxContainer_tickest_02/MarginContainer_02_mode2/HBoxContainer_02_mode2/Label_Amt_02_mode2
	label_agent02_mode_remaining_tickets[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent02/MarginContainer_tickets_02/VBoxContainer_tickest_02/MarginContainer_02_mode3/HBoxContainer_02_mode3/Label_Amt_02_mode3
	# Agent 3 objects
	label_agent03_mode_name.clear()
	label_agent03_mode_name.resize(4)
	label_agent03_mode_name[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent03/MarginContainer_tickets_03/VBoxContainer_tickest_03/MarginContainer_03_mode0/HBoxContainer_03_mode0/Label_Title_03_mode0
	label_agent03_mode_name[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent03/MarginContainer_tickets_03/VBoxContainer_tickest_03/MarginContainer_03_mode1/HBoxContainer_03_mode1/Label_Title_03_mode1
	label_agent03_mode_name[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent03/MarginContainer_tickets_03/VBoxContainer_tickest_03/MarginContainer_03_mode2/HBoxContainer_03_mode2/Label_Title_03_mode2
	label_agent03_mode_name[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent03/MarginContainer_tickets_03/VBoxContainer_tickest_03/MarginContainer_03_mode3/HBoxContainer_03_mode3/Label_Title_03_mode3
	label_agent03_mode_remaining_tickets.clear()
	label_agent03_mode_remaining_tickets.resize(4)
	label_agent03_mode_remaining_tickets[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent03/MarginContainer_tickets_03/VBoxContainer_tickest_03/MarginContainer_03_mode0/HBoxContainer_03_mode0/Label_Amt_03_mode0
	label_agent03_mode_remaining_tickets[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent03/MarginContainer_tickets_03/VBoxContainer_tickest_03/MarginContainer_03_mode1/HBoxContainer_03_mode1/Label_Amt_03_mode1
	label_agent03_mode_remaining_tickets[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent03/MarginContainer_tickets_03/VBoxContainer_tickest_03/MarginContainer_03_mode2/HBoxContainer_03_mode2/Label_Amt_03_mode2
	label_agent03_mode_remaining_tickets[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent03/MarginContainer_tickets_03/VBoxContainer_tickest_03/MarginContainer_03_mode3/HBoxContainer_03_mode3/Label_Amt_03_mode3
	# Agent 4 objects
	label_agent04_mode_name.clear()
	label_agent04_mode_name.resize(4)
	label_agent04_mode_name[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent04/MarginContainer_tickets_04/VBoxContainer_tickest_04/MarginContainer_04_mode0/HBoxContainer_04_mode0/Label_Title_04_mode0
	label_agent04_mode_name[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent04/MarginContainer_tickets_04/VBoxContainer_tickest_04/MarginContainer_04_mode1/HBoxContainer_04_mode1/Label_Title_04_mode1
	label_agent04_mode_name[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent04/MarginContainer_tickets_04/VBoxContainer_tickest_04/MarginContainer_04_mode2/HBoxContainer_04_mode2/Label_Title_04_mode2
	label_agent04_mode_name[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent04/MarginContainer_tickets_04/VBoxContainer_tickest_04/MarginContainer_04_mode3/HBoxContainer_04_mode3/Label_Title_04_mode3
	label_agent04_mode_remaining_tickets.clear()
	label_agent04_mode_remaining_tickets.resize(4)
	label_agent04_mode_remaining_tickets[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent04/MarginContainer_tickets_04/VBoxContainer_tickest_04/MarginContainer_04_mode0/HBoxContainer_04_mode0/Label_Amt_04_mode0
	label_agent04_mode_remaining_tickets[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent04/MarginContainer_tickets_04/VBoxContainer_tickest_04/MarginContainer_04_mode1/HBoxContainer_04_mode1/Label_Amt_04_mode1
	label_agent04_mode_remaining_tickets[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent04/MarginContainer_tickets_04/VBoxContainer_tickest_04/MarginContainer_04_mode2/HBoxContainer_04_mode2/Label_Amt_04_mode2
	label_agent04_mode_remaining_tickets[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent04/MarginContainer_tickets_04/VBoxContainer_tickest_04/MarginContainer_04_mode3/HBoxContainer_04_mode3/Label_Amt_04_mode3
	# Agemt 5 objects
	label_agent05_mode_name.clear()
	label_agent05_mode_name.resize(4)
	label_agent05_mode_name[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent05/MarginContainer_tickets_05/VBoxContainer_tickest_05/MarginContainer_05_mode0/HBoxContainer_05_mode0/Label_Title_05_mode0
	label_agent05_mode_name[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent05/MarginContainer_tickets_05/VBoxContainer_tickest_05/MarginContainer_05_mode1/HBoxContainer_05_mode1/Label_Title_05_mode1
	label_agent05_mode_name[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent05/MarginContainer_tickets_05/VBoxContainer_tickest_05/MarginContainer_05_mode2/HBoxContainer_05_mode2/Label_Title_05_mode2
	label_agent05_mode_name[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent05/MarginContainer_tickets_05/VBoxContainer_tickest_05/MarginContainer_05_mode3/HBoxContainer_05_mode3/Label_Title_05_mode3
	label_agent05_mode_remaining_tickets.clear()
	label_agent05_mode_remaining_tickets.resize(4)
	label_agent05_mode_remaining_tickets[0] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent05/MarginContainer_tickets_05/VBoxContainer_tickest_05/MarginContainer_05_mode0/HBoxContainer_05_mode0/Label_Amt_05_mode0
	label_agent05_mode_remaining_tickets[1] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent05/MarginContainer_tickets_05/VBoxContainer_tickest_05/MarginContainer_05_mode1/HBoxContainer_05_mode1/Label_Amt_05_mode1
	label_agent05_mode_remaining_tickets[2] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent05/MarginContainer_tickets_05/VBoxContainer_tickest_05/MarginContainer_05_mode2/HBoxContainer_05_mode2/Label_Amt_05_mode2
	label_agent05_mode_remaining_tickets[3] = $PanelContainer/VBoxContainer/MarginContainer_Agents/VBoxContainer_Agents/HBoxContainer_Agent05/MarginContainer_tickets_05/VBoxContainer_tickest_05/MarginContainer_05_mode3/HBoxContainer_05_mode3/Label_Amt_05_mode3
	# Sus 0 ojbects
	label_sus00_mode_name.clear()
	label_sus00_mode_name.resize(4)
	label_sus00_mode_name[0] = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/HBoxContainer_Sus00/MarginContainer_tickets_S00/VBoxContainer_tickest_S00/MarginContainer_S00_mode0/HBoxContainer_S00_mode0/Label_Title_S00_mode0
	label_sus00_mode_name[1] = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/HBoxContainer_Sus00/MarginContainer_tickets_S00/VBoxContainer_tickest_S00/MarginContainer_S00_mode1/HBoxContainer_S00_mode1/Label_Title_S00_mode1
	label_sus00_mode_name[2] = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/HBoxContainer_Sus00/MarginContainer_tickets_S00/VBoxContainer_tickest_S00/MarginContainer_S00_mode2/HBoxContainer_S00_mode2/Label_Title_S00_mode2
	label_sus00_mode_name[3] = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/HBoxContainer_Sus00/MarginContainer_tickets_S00/VBoxContainer_tickest_S00/MarginContainer_S00_mode3/HBoxContainer_S00_mode3/Label_Title_S00_mode3
	label_sus00_mode_remaining_tickets.clear()
	label_sus00_mode_remaining_tickets.resize(4)
	label_sus00_mode_remaining_tickets[0] = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/HBoxContainer_Sus00/MarginContainer_tickets_S00/VBoxContainer_tickest_S00/MarginContainer_S00_mode0/HBoxContainer_S00_mode0/Label_Amt_S00_mode0
	label_sus00_mode_remaining_tickets[1] = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/HBoxContainer_Sus00/MarginContainer_tickets_S00/VBoxContainer_tickest_S00/MarginContainer_S00_mode1/HBoxContainer_S00_mode1/Label_Amt_S00_mode1
	label_sus00_mode_remaining_tickets[2] = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/HBoxContainer_Sus00/MarginContainer_tickets_S00/VBoxContainer_tickest_S00/MarginContainer_S00_mode2/HBoxContainer_S00_mode2/Label_Amt_S00_mode2
	label_sus00_mode_remaining_tickets[3] = $PanelContainer/VBoxContainer/MarginContainer_Sus/VBoxContainer_Sus/HBoxContainer_Sus00/MarginContainer_tickets_S00/VBoxContainer_tickest_S00/MarginContainer_S00_mode3/HBoxContainer_S00_mode3/Label_Amt_S00_mode3

## Setup ticket label object mode names and remaining tickets
func _setup_tickets() -> void:
	for n in 4: # where 'n' is the travel method ID number
		label_agent01_mode_name[n].text = GlobalVars.travel_mode[n]
		label_agent02_mode_name[n].text = GlobalVars.travel_mode[n]
		label_agent03_mode_name[n].text = GlobalVars.travel_mode[n]
		label_agent04_mode_name[n].text = GlobalVars.travel_mode[n]
		label_agent05_mode_name[n].text = GlobalVars.travel_mode[n]
		label_sus00_mode_name[n].text = GlobalVars.travel_mode[n]

## Update the labels (display) showing the remaining tickets
func _set_remaining_tickets() -> void:
	for n in 4: # where 'n' is the travel method ID number
		label_agent01_mode_remaining_tickets[n].text = str(GlobalVars.tickets_remaining_agent01[n])
		label_agent02_mode_remaining_tickets[n].text = str(GlobalVars.tickets_remaining_agent02[n])
		label_agent03_mode_remaining_tickets[n].text = str(GlobalVars.tickets_remaining_agent03[n])
		label_agent04_mode_remaining_tickets[n].text = str(GlobalVars.tickets_remaining_agent04[n])
		label_agent05_mode_remaining_tickets[n].text = str(GlobalVars.tickets_remaining_agent05[n])
		label_sus00_mode_remaining_tickets[n].text = str(GlobalVars.tickets_remaining_sus00[n])

## This establishes the unique behavior of each suspect
func _set_sus_variables() -> void:
	match GlobalVars.sus_name:
		"Keith":
			GlobalVars.sus_threat_profile = GlobalVars.threat_profile_a.duplicate()
			GlobalVars.tickets_remaining_sus00[3] = 0 # starting number of special tickets
			# all other sus behavior variables remain zero
		"Patti":
			GlobalVars.sus_threat_profile = GlobalVars.threat_profile_b.duplicate()
			GlobalVars.sus_duress_limit_1 = 25
			GlobalVars.sus_duress_limit_2 = 10
			GlobalVars.sus_duress_limit_1_prob = 0.35
			GlobalVars.sus_duress_limit_2_prob = 0.85
			GlobalVars.sus_num_2x_turns = 2
			GlobalVars.sus_num_water_moves = 2
			GlobalVars.sus_num_concealed_moves = 2
			GlobalVars.tickets_remaining_sus00[3] = 4 # starting number of special tickets
		"Mo":
			GlobalVars.sus_threat_profile = GlobalVars.threat_profile_c.duplicate()
			GlobalVars.sus_duress_limit_1 = 25
			GlobalVars.sus_duress_limit_2 = 10
			GlobalVars.sus_duress_limit_1_prob = 0.35
			GlobalVars.sus_duress_limit_2_prob = 0.85
			GlobalVars.sus_num_2x_turns = 2
			GlobalVars.sus_num_water_moves = 2
			GlobalVars.sus_num_concealed_moves = 2
			GlobalVars.tickets_remaining_sus00[3] = 6 # starting number of special tickets
	# Update the remaining ticket labels
	_set_remaining_tickets()
	
## When an agent button is selected, show where the agent is and present a dialogue.
func _on_button_icon_agent_pressed(num) -> void:
	var player_send = agent_sprite[num]
	GlobalVars.player_focus = num
	if setup_mode == false:
		panel_container_sus_player.visible = true
		button_view_close.visible = true
		emit_signal("viewport_focus",player_send)
		#region FOR TESTING
		#print(GlobalVars.agent_location[GlobalVars.player_focus])
		#endregion
		GlobalVars.loc_name = str(JsonHandler.location_variables[GlobalVars.agent_location[GlobalVars.player_focus]]["location_name"])
		GlobalVars.loc_section = str(JsonHandler.location_variables[GlobalVars.agent_location[GlobalVars.player_focus]]["section"])
		GlobalVars.loc_description = str(JsonHandler.location_variables[GlobalVars.agent_location[GlobalVars.player_focus]]["location_description"])
		var dialogue_resource = load("res://dialog/dl_agent.dialogue")
		DialogueManager.show_dialogue_balloon(dialogue_resource, "location")
	else:
		var dialogue_resource = load("res://dialog/dl_agent.dialogue")
		DialogueManager.show_dialogue_balloon(dialogue_resource, "waittodeploy")

## When the suspect button is selected, show where the suspect is if the suspect is revealed.
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

## Craft a string that lists the suspect's moves since the last reveal turn, used for dialogue
func _get_sus_recent_moves(index) -> void:
	GlobalVars.sus_mode_since_reveal = ""
	var sus_mode_append : String
	var sus_mode_count_start : int
	if GlobalVars.sus_last_location_index == 0 :
		sus_mode_count_start = 1
	else :
		sus_mode_count_start = GlobalVars.sus_last_location_index + 1
	for n in range(sus_mode_count_start,GlobalVars.sus_00_mode_history.size()):
		sus_mode_append = GlobalVars.travel_mode[GlobalVars.sus_00_mode_history[n]]
		if n == sus_mode_count_start:
			GlobalVars.sus_mode_since_reveal = GlobalVars.sus_mode_since_reveal + sus_mode_append
		else :
			GlobalVars.sus_mode_since_reveal = GlobalVars.sus_mode_since_reveal + ", then by " + sus_mode_append

## Set the player being moved during setup
func _on_button_start_agent_pressed(num) -> void:
	player_sprite = agent_sprite[num]
	player_number = num
	emit_signal("set_start_location",player_sprite,player_number)

## Signal from the Main node after a location button is selected
func _on_main_location_selected(player_number_start: Variant) -> void:
	player_location_ready[player_number_start] = true
	if setup_mode == false:
		# Disable the move buttons after a player has moved
		button_move_agent[player_number_start].disabled = true
		_set_remaining_tickets()
	_enable_setup_done() #Check if setup complete

## Check to see if the setup or turn is complete
func _enable_setup_done():
	if player_location_ready.has(false):
		button_done.disabled = true
	else:
		button_done.disabled = false

## End setup and start and regular game
func _on_button_done_pressed() -> void:
	button_done.disabled = true
	if setup_mode == true:
		for n in range (1,GlobalVars.agent_count + 1):
			button_move_agent[n].disabled = false
		_setup_cleanup()
		setup_mode = false
		v_box_container_tickest_s_00.visible = true
		emit_signal("setup_is_complete")
	else:
		emit_signal("turn_is_complete")
	# Reset the player move status
	player_location_ready.fill(false)
	player_location_ready[0] = true # we don't use player 0
	# disable the move buttons for inactive players
	for i in range(1,GlobalVars.agent_incapacitated.size()) :
		if GlobalVars.agent_incapacitated[i] == true:
			button_move_agent[i].disabled = true
			player_location_ready[i] = true
		else:
			button_move_agent[i].disabled = false
			player_location_ready[i] = false

## Clean up some items, only when in setup mode
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

## Select the agent to move, signal for main.gd to identify possible moves
func _on_button_move_agent_pressed(num) -> void:
	player_sprite = agent_sprite[num]
	player_number = num
	GlobalVars.player_focus = num
	#region Use dialogue manager to provide a warning if remaining foot turns are low
	var dialogue_resource = load("res://dialog/dl_dispatch.dialogue")
	match player_number:
		1:
			if GlobalVars.tickets_remaining_agent01[0] == 2:
				DialogueManager.show_dialogue_balloon(dialogue_resource, "footmoves2")
			if GlobalVars.tickets_remaining_agent01[0] == 1:
				DialogueManager.show_dialogue_balloon(dialogue_resource, "footmoves1")
		2:
			if GlobalVars.tickets_remaining_agent02[0] == 2:
				DialogueManager.show_dialogue_balloon(dialogue_resource, "footmoves2")
			if GlobalVars.tickets_remaining_agent02[0] == 1:
				DialogueManager.show_dialogue_balloon(dialogue_resource, "footmoves1")
		3:
			if GlobalVars.tickets_remaining_agent03[0] == 2:
				DialogueManager.show_dialogue_balloon(dialogue_resource, "footmoves2")
			if GlobalVars.tickets_remaining_agent03[0] == 1:
				DialogueManager.show_dialogue_balloon(dialogue_resource, "footmoves1")
		4:
			if GlobalVars.tickets_remaining_agent04[0] == 2:
				DialogueManager.show_dialogue_balloon(dialogue_resource, "footmoves2")
			if GlobalVars.tickets_remaining_agent04[0] == 1:
				DialogueManager.show_dialogue_balloon(dialogue_resource, "footmoves1")
		5:
			if GlobalVars.tickets_remaining_agent05[0] == 2:
				DialogueManager.show_dialogue_balloon(dialogue_resource, "footmoves2")
			if GlobalVars.tickets_remaining_agent05[0] == 1:
				DialogueManager.show_dialogue_balloon(dialogue_resource, "footmoves1")
	#endregion
	emit_signal("move_to_location",player_sprite,player_number,GlobalVars.turn_number)

## Receives a signal from main.gd to update the ticket display
func _on_main_ticket_used() -> void:
	_set_remaining_tickets()

func _hide_move_buttons() -> void:
	for n in [1,2,3,4,5]:
		button_move_agent[n].visible = false

func _show_move_buttons() -> void:
	for n in [1,2,3,4,5]:
		button_move_agent[n].visible = true

func _enable_move_buttons() -> void:
	for n in [1,2,3,4,5]:
		button_move_agent[n].disabled = false

func _disable_move_buttons() -> void:
	for n in [1,2,3,4,5]:
		button_move_agent[n].disabled = true

## Actions taken after the suspect has moved, includes using a choice to use a concealed or double move, enabling the agent move buttons, and check if the suspect is revealed
func _on_main_sus_moved(sus_moved_num: Variant, sus_mode_used: Variant, sus_moved_turn: Variant) -> void:
	var dialogue_resource = load("res://dialog/dl_dispatch.dialogue")
	_sus_duress_level()
	# Determine if a concealed move is used
	if GlobalVars.tickets_remaining_sus00[3] > 0 and GlobalVars.sus_num_concealed_moves > 0 and sus_mode_used !=3 and sus_mode_used !=4:
		# If special moves and concealed moves available, and if water not used, determine probability of using it
		var random_value : float = randf() # generates a random number between 0 and 1
		# Check duress 1 upper limit to use concealed move
		if GlobalVars.sus_duress <= GlobalVars.sus_duress_limit_1 :
			if random_value <= GlobalVars.sus_duress_limit_1_prob :
				_use_concealed_move(sus_moved_num,sus_mode_used,sus_moved_turn)
	_set_remaining_tickets()
	GlobalVars.turn_number = sus_moved_turn
	label_turn_count.text = str(sus_moved_turn)
	# Enable the move buttons for active players
	for i in GlobalVars.agent_incapacitated.size():
		if GlobalVars.agent_incapacitated[i] == true:
			button_move_agent[i].disabled = true
			player_location_ready[i] = true
		else:
			button_move_agent[i].disabled = false
	# Reveal or hide suspect based on turn number
	if GlobalVars.sus_reveal_turn.has(sus_moved_turn):
		sus_00.visible = true
		GlobalVars.sus_last_location_num = GlobalVars.sus_00_loc_history[-1] # set the last known suspect location to the suspect's current location number
		GlobalVars.sus_last_location_index = sus_moved_turn
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
	DialogueManager.show_dialogue_balloon(dialogue_resource, "susmove")
	# Check to see if the sus will use a double-move
	if GlobalVars.tickets_remaining_sus00[3] > 0 and GlobalVars.sus_num_2x_turns > 0 :
		# if there are special moves and double-moves available, determine probability of using it
		var random_value : float = randf() # generates a random number between 0 and 1
		# Check duress 1 upper limit to use special move move
		if GlobalVars.sus_duress <= GlobalVars.sus_duress_limit_1 :
			# if true, check duress 2 limit, which has a higher probability
			if GlobalVars.sus_duress <= GlobalVars.sus_duress_limit_2 :
				# if true, see if random value is less than the limit 2 probability to use the special move
				if random_value <= GlobalVars.sus_duress_limit_2_prob :
					_use_double_move()
			else :
				# if false, see if random value is less than the limit 1 probability to use the special move
				if random_value <= GlobalVars.sus_duress_limit_1_prob :
					_use_double_move()

## Actions taken when the suspect uses a double-move
func _use_double_move() -> void:
	GlobalVars.turn_number += 1 # increase the turn number by one
	# record agent player history > same position and skip turn
	if GlobalVars.agent_incapacitated[1] == false :
		GlobalVars.agent_01_loc_history.append(GlobalVars.agent_location[1])
		GlobalVars.agent_01_mode_history.append(5)
	if GlobalVars.agent_incapacitated[2] == false :
		GlobalVars.agent_02_loc_history.append(GlobalVars.agent_location[2])
		GlobalVars.agent_02_mode_history.append(5)
	if GlobalVars.agent_incapacitated[3] == false :
		GlobalVars.agent_03_loc_history.append(GlobalVars.agent_location[3])
		GlobalVars.agent_03_mode_history.append(5)
	if GlobalVars.agent_incapacitated[4] == false :
		GlobalVars.agent_04_loc_history.append(GlobalVars.agent_location[4])
		GlobalVars.agent_04_mode_history.append(5)
	if GlobalVars.agent_incapacitated[5] == false :
		GlobalVars.agent_05_loc_history.append(GlobalVars.agent_location[5])
		GlobalVars.agent_05_mode_history.append(5)
	# debit from remaining sus special move ticket and double-moves available
	GlobalVars.tickets_remaining_sus00[3] -= 1
	GlobalVars.sus_num_2x_turns -= 1
	# additional turn for suspect win
	GlobalVars.turn_limit += 1
	# dialog for double-move
	var dialogue_resource = load("res://dialog/dl_dispatch.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue_resource, "doublemove")
	# signal to move again, back to main
	emit_signal("double_move")
	pass

## Actions taken when the suspect uses a concealed move
func _use_concealed_move(sus_moved_num: Variant, sus_mode_used: Variant, sus_moved_turn: Variant) -> void:
	# Add back the ticket for the mode used
	GlobalVars.tickets_remaining_sus00[sus_mode_used] += 1
	# Debit from special moves and concealed moves
	GlobalVars.tickets_remaining_sus00[3] -= 1
	GlobalVars.sus_num_concealed_moves -= 1
	# Remove the last mode history array value and add 'special'
	GlobalVars.sus_00_mode_history.remove_at(-1)
	GlobalVars.sus_00_mode_history.append(3)
	GlobalVars.sus_last_move_type = GlobalVars.travel_mode[sus_mode_used].to_lower()

## Define the suspect duress range, defined by the size of possible moves
func _sus_duress_level() -> void:
	if GlobalVars.sus_duress > 40 :
		GlobalVars.sus_duress_level = "feeling calm and carefree"
	elif GlobalVars.sus_duress > 25 and GlobalVars.sus_duress <= 40 :
		GlobalVars.sus_duress_level = "a little nervous but still confident"
	elif GlobalVars.sus_duress > 10 and GlobalVars.sus_duress <= 25 :
		GlobalVars.sus_duress_level = "feeling quite worried"
	else :
		GlobalVars.sus_duress_level = "freaking out"

func _on_main_stop_moves() -> void:
	_hide_move_buttons()

## Game restart tasks
func _on_main_game_restart() -> void:
	player_panel.visible = false
	player_location_ready.clear()
	_basic_setup()
	_reset_starting_tickets() 
	GlobalVars.turn_number = 0
	# Common agent functions
	for n in range (1,GlobalVars.agent_count + 1):
		button_start_agent[n].disabled = false
		button_start_agent[n].visible = true
		button_move_agent[n].disabled = true
		GlobalVars.agent_incapacitated[n] = false
	GlobalVars.agent_incapacitated[0] = true
	margin_container_tickets_01.visible = false
	margin_container_tickets_02.visible = false
	margin_container_tickets_03.visible = false
	margin_container_tickets_04.visible = false
	margin_container_tickets_05.visible = false
	# Other reset functions
	margin_container_turn.visible = false
	button_done.disabled = true
	v_box_container_tickest_s_00.visible = false
	_hide_move_buttons()
	var sprite_path : String
	# Set suspect button icon and label
	sprite_path = "res://art/player_sprites/select32.png"
	label_sus_00.text = "Suspect"
	button_sus_00.icon  = load(sprite_path)
	GlobalVars.sus_name = ""
	for n in range (1,GlobalVars.agent_count + 1):
		GlobalVars.agent_incapacitated[n] = false
	# Open the game start dialogue
	var dialogue_resource = load("res://dialog/dl_start.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue_resource, "SuspectList")

## Resets the starting number of tickets
func _reset_starting_tickets() -> void:
	# Clear the remaining tickets array
	GlobalVars.tickets_remaining_agent01.clear()
	GlobalVars.tickets_remaining_agent02.clear()
	GlobalVars.tickets_remaining_agent03.clear()
	GlobalVars.tickets_remaining_agent04.clear()
	GlobalVars.tickets_remaining_agent05.clear()
	GlobalVars.tickets_remaining_sus00.clear()
	GlobalVars.tickets_remaining_agent01.resize(4)
	GlobalVars.tickets_remaining_agent02.resize(4)
	GlobalVars.tickets_remaining_agent03.resize(4)
	GlobalVars.tickets_remaining_agent04.resize(4)
	GlobalVars.tickets_remaining_agent05.resize(4)
	GlobalVars.tickets_remaining_sus00.resize(4)
	# Reset the starting ticket values
	for n in 4:
		GlobalVars.tickets_remaining_agent01[n] = GlobalVars.travel_mode_start_number[n]
		GlobalVars.tickets_remaining_agent02[n] = GlobalVars.travel_mode_start_number[n]
		GlobalVars.tickets_remaining_agent03[n] = GlobalVars.travel_mode_start_number[n]
		GlobalVars.tickets_remaining_agent04[n] = GlobalVars.travel_mode_start_number[n]
		GlobalVars.tickets_remaining_agent05[n] = GlobalVars.travel_mode_start_number[n]
		GlobalVars.tickets_remaining_sus00[n] = GlobalVars.travel_mode_start_number_sus[n]
	_set_remaining_tickets() 

## This closes the panel container showing the suspect or agent location
func _on_button_view_close_pressed() -> void:
	panel_container_sus_player.visible = false
	button_view_close.visible = false

func _on_main_out_of_moves(player: Variant) -> void:
	button_move_agent[player].disabled = true
	player_location_ready[player] = true
	_enable_setup_done()

func _on_button_icon_dispatcher_pressed() -> void:
	_get_sus_recent_moves(GlobalVars.sus_last_location_index + 1)
	var dialogue_resource = load("res://dialog/dl_dispatch.dialogue")
	if setup_mode == true:
		DialogueManager.show_dialogue_balloon(dialogue_resource, "setuphelp")
	else:
		DialogueManager.show_dialogue_balloon(dialogue_resource, "gamehelp")
