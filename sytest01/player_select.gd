extends Control

# Add the buttons for each icon
@onready var player_select_button_01: Button = $PanelContainer/VBoxContainer/HBoxContainer/PlayerSelectButton01
@onready var player_select_button_02: Button = $PanelContainer/VBoxContainer/HBoxContainer/PlayerSelectButton02
@onready var player_select_button_03: Button = $PanelContainer/VBoxContainer/HBoxContainer/PlayerSelectButton03
@onready var player_select_button_04: Button = $PanelContainer/VBoxContainer/HBoxContainer2/PlayerSelectButton04
@onready var player_select_button_05: Button = $PanelContainer/VBoxContainer/HBoxContainer2/PlayerSelectButton05
@onready var player_select_button_06: Button = $PanelContainer/VBoxContainer/HBoxContainer2/PlayerSelectButton06

# Add other variables used in the functions
var player_texture: Texture2D

# Create a signal when a player icon is selected
signal set_player(selection)

# These are the functions for each of the icon buttons
func _on_player_select_button_01_pressed() -> void:
	player_texture = player_select_button_01.icon
	emit_signal("set_player",player_texture)
func _on_player_select_button_02_pressed() -> void:
	player_texture = player_select_button_02.icon
	emit_signal("set_player",player_texture)
func _on_player_select_button_03_pressed() -> void:
	player_texture = player_select_button_03.icon
	emit_signal("set_player",player_texture)
func _on_player_select_button_04_pressed() -> void:
	player_texture = player_select_button_04.icon
	emit_signal("set_player",player_texture)
func _on_player_select_button_05_pressed() -> void:
	player_texture = player_select_button_05.icon
	emit_signal("set_player",player_texture)
func _on_player_select_button_06_pressed() -> void:
	player_texture = player_select_button_06.icon
	emit_signal("set_player",player_texture)
