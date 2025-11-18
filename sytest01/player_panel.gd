extends Control

# Players
@onready var agent_01: Sprite2D = $"../../Players/Agent01"
@onready var agent_02: Sprite2D = $"../../Players/Agent02"
@onready var agent_03: Sprite2D = $"../../Players/Agent03"

#Buttons to select agent icons
@onready var button_icon_agent_01: Button = $PanelContainer/VBoxContainer/MarginContainer_Agent01/VBoxContainer_Agent01/HBoxContainer_Agent01/ButtonIcon_Agent01
@onready var button_icon_agent_02: Button = $PanelContainer/VBoxContainer/MarginContainer_Agent01/VBoxContainer_Agent01/HBoxContainer_Agent02/ButtonIcon_Agent02
@onready var button_icon_agent_03: Button = $PanelContainer/VBoxContainer/MarginContainer_Agent01/VBoxContainer_Agent01/HBoxContainer_Agent03/ButtonIcon_Agent03

#Load icon textures
var texture_select_blue = preload("res://art/player_sprites/blue32.png")
var texture_select_green = preload("res://art/player_sprites/green32.png")
var texture_select_pink = preload("res://art/player_sprites/pink32.png")
var texture_select_purple = preload("res://art/player_sprites/purple32.png")
var texture_select_white = preload("res://art/player_sprites/white32.png")
var texture_select_yellow = preload("res://art/player_sprites/yellow32.png")

#OTHER VARIABLES
var button_change : Button
var player : Sprite2D
var player_number : int

# For the player start location, emit a signal when a player is selected
signal set_start_location(player,player_number)

#When an agent button is selected, show the player select window and set the focus to that agent.
func _on_button_icon_agent_01_pressed() -> void:
	get_node("PlayerSelect").visible = true
	button_change = button_icon_agent_01
	player = agent_01
func _on_button_icon_agent_02_pressed() -> void:
	get_node("PlayerSelect").visible = true
	button_change = button_icon_agent_02
	player = agent_02
func _on_button_icon_agent_03_pressed() -> void:
	get_node("PlayerSelect").visible = true
	button_change = button_icon_agent_03
	player = agent_03

# When an icon is selected (receiving the signal), set the button and player textures to that icon, and hide
func _on_player_select_set_player(selection: Variant) -> void:
	match selection:
		"blue":
			button_change.icon = texture_select_blue
			player.texture = texture_select_blue
		"green":
			button_change.icon = texture_select_green
			player.texture = texture_select_green
		"pink":
			button_change.icon = texture_select_pink
			player.texture = texture_select_pink
		"purple":
			button_change.icon = texture_select_purple
			player.texture = texture_select_purple
		"white":
			button_change.icon = texture_select_white
			player.texture = texture_select_white
		"yellow":
			button_change.icon = texture_select_yellow
			player.texture = texture_select_yellow
	get_node("PlayerSelect").visible = false

# Code for setting the player being moved
func _on_button_start_agent_01_pressed() -> void:
	player = agent_01
	player_number = 1
	emit_signal("set_start_location",player,player_number)
func _on_button_start_agent_02_pressed() -> void:
	player = agent_02
	player_number = 2
	emit_signal("set_start_location",player,player_number)
func _on_button_start_agent_03_pressed() -> void:
	player = agent_03
	player_number = 3
	emit_signal("set_start_location",player,player_number)
