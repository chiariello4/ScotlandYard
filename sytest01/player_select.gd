extends Control

# Add the buttons for each icon
@onready var player_select_button_01: Button = $PanelContainer/VBoxContainer/HBoxContainer/PlayerSelectButton01
@onready var player_select_button_02: Button = $PanelContainer/VBoxContainer/HBoxContainer/PlayerSelectButton02
@onready var player_select_button_03: Button = $PanelContainer/VBoxContainer/HBoxContainer/PlayerSelectButton03
@onready var player_select_button_04: Button = $PanelContainer/VBoxContainer/HBoxContainer2/PlayerSelectButton04
@onready var player_select_button_05: Button = $PanelContainer/VBoxContainer/HBoxContainer2/PlayerSelectButton05
@onready var player_select_button_06: Button = $PanelContainer/VBoxContainer/HBoxContainer2/PlayerSelectButton06

# Add other variables used in the functions
var player_selected : String

# Create a signal when a player icon is selected
signal set_player(selection)

# These are the functions for each of the icon buttons
func _on_player_select_button_01_pressed() -> void:
	player_selected = "blue"
	emit_signal("set_player",player_selected)
func _on_player_select_button_02_pressed() -> void:
	player_selected = "green"
	emit_signal("set_player",player_selected)
func _on_player_select_button_03_pressed() -> void:
	player_selected = "pink"
	emit_signal("set_player",player_selected)
func _on_player_select_button_04_pressed() -> void:
	player_selected = "purple"
	emit_signal("set_player",player_selected)
func _on_player_select_button_05_pressed() -> void:
	player_selected = "white"
	emit_signal("set_player",player_selected)
func _on_player_select_button_06_pressed() -> void:
	player_selected = "yellow"
	emit_signal("set_player",player_selected)
