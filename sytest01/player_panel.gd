extends Control

#Buttons for start locations
@onready var loc_button_001: Button = $"../../LocationButtons/LocButton001"
@onready var loc_button_002: Button = $"../../LocationButtons/LocButton002"
@onready var loc_button_003: Button = $"../../LocationButtons/LocButton003"
@onready var loc_button_004: Button = $"../../LocationButtons/LocButton004"
@onready var loc_button_005: Button = $"../../LocationButtons/LocButton005"

#Buttons to select agent icons
@onready var button_icon_agent_01: Button = $PanelContainer/VBoxContainer/MarginContainer_Agent01/VBoxContainer_Agent01/HBoxContainer_Agent01/ButtonIcon_Agent01
@onready var button_icon_agent_02: Button = $PanelContainer/VBoxContainer/MarginContainer_Agent01/VBoxContainer_Agent01/HBoxContainer_Agent02/ButtonIcon_Agent02
@onready var button_icon_agent_03: Button = $PanelContainer/VBoxContainer/MarginContainer_Agent01/VBoxContainer_Agent01/HBoxContainer_Agent03/ButtonIcon_Agent03

#DONT NEED THIS?
@onready var player_piece: Sprite2D = $"../../PlayerPiece"

#OTHER VARIABLES ON READY, mah remove?
@onready var texture_rect_agent_01: TextureRect = $PanelContainer/VBoxContainer/MarginContainer_Agent01/VBoxContainer_Agent01/HBoxContainer_Agent01/ButtonIcon_Agent01/TextureRect_Agent01

#Load icon textures
var texture_select_blue = preload("res://art/player_sprites/blue32.png")
var texture_select_green = preload("res://art/player_sprites/green32.png")
var texture_select_pink = preload("res://art/player_sprites/pink32.png")
var texture_select_purple = preload("res://art/player_sprites/purple32.png")
var texture_select_white = preload("res://art/player_sprites/white32.png")
var texture_select_yellow = preload("res://art/player_sprites/yellow32.png")
var button_change : Button

#OTHER VARIABLES
var player : Sprite2D

#When an agent button is selected, show the player select window and set the focus to that agent.
func _on_button_icon_agent_01_pressed() -> void:
	get_node("PlayerSelect").visible = true
	button_change = button_icon_agent_01

func _on_button_icon_agent_02_pressed() -> void:
	get_node("PlayerSelect").visible = true
	button_change = button_icon_agent_02

func _on_button_icon_agent_03_pressed() -> void:
	get_node("PlayerSelect").visible = true
	button_change = button_icon_agent_03

#Select icon, set the button texture to that icon, and hide
func _on_player_select_set_player(selection: Variant) -> void:
	match selection:
		#Not using the .texture line, may be able to remove
		"blue":
			button_change.icon = texture_select_blue
			texture_rect_agent_01.texture = texture_select_blue
		"green":
			button_change.icon = texture_select_green
			texture_rect_agent_01.texture = texture_select_green
		"pink":
			button_change.icon = texture_select_pink
			texture_rect_agent_01.texture = texture_select_pink
		"purple":
			button_change.icon = texture_select_purple
			texture_rect_agent_01.texture = texture_select_purple
		"white":
			button_change.icon = texture_select_white
			texture_rect_agent_01.texture = texture_select_white
		"yellow":
			button_change.icon = texture_select_yellow
			texture_rect_agent_01.texture = texture_select_yellow
	get_node("PlayerSelect").visible = false

func _on_button_start_agent_01_pressed() -> void:
	#enable start locations
	loc_button_001.disabled = false
	loc_button_004.disabled = false
	#get user input on start location
	
func _on_loc_button_001_pressed() -> void:
	player = player_piece
	var player_move_start = create_tween()
	player_move_start.tween_property(player, "position", loc_button_001.position, 1)

#Disable all of the map start location select buttons.
func _enable_all_buttons() -> void:
	loc_button_001.disabled = false
	loc_button_002.disabled = false
	loc_button_003.disabled = false
	loc_button_004.disabled = false
	loc_button_005.disabled = false
