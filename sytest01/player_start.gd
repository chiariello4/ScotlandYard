extends Control

@onready var label_player_selected : Label = $PanelContainer/VBoxContainer/MarginContainerType/HBoxContainer/LabelPlayerSelected
@onready var label_start_loc_selected : Label = $PanelContainer/VBoxContainer/MarginContainerLoc/HBoxContainer2/LabelStartLocSelected
@onready var button_done : Button = $PanelContainer/VBoxContainer/MarginContainerDone/ButtonDone
var start_icon_selected : String
var start_loc_selected : int
signal location_selected(location_choice)
signal icon_selected(icon_choice)

# Set the player type
func _on_button_player_type_01_pressed() -> void:
	label_player_selected.text = "Blue"
	start_icon_selected = "blue"
	emit_signal("icon_selected",start_icon_selected)
	check_if_done()

func _on_button_player_type_2_pressed() -> void:
	label_player_selected.text = "Pink"
	start_icon_selected = "pink"
	emit_signal("icon_selected",start_icon_selected)
	check_if_done()
#
# Set the start location
func _on_button_loc_1_pressed() -> void:
	start_loc_selected = 1
	label_start_loc_selected.text = "1"
	emit_signal("location_selected",start_loc_selected)
	check_if_done()

func _on_button_loc_8_pressed() -> void:
	start_loc_selected = 8
	label_start_loc_selected.text = "8"
	emit_signal("location_selected",start_loc_selected)
	check_if_done()

func check_if_done() -> void:
	if label_player_selected.text != "Select an Icon" and label_start_loc_selected.text != "Select a Location":
		button_done.disabled = false
		#startLocation.emit()

#func _on_button_done_pressed() -> void:
	#Events.emit_signal("playerTypeSelected", playerType)
	#Events.emit_signal("startLocationSelected", startLocation)
	#StartNow.emit()
	#queue_free()
	#hide()
