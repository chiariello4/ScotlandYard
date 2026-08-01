extends Node

var json_path = "res://json_files/json_location_file_v12sm.txt"
var location_variables = {}

func _ready() -> void:
	_load_json_data()

	# Loading JSON data into location_variables
func _load_json_data():
	# Open the file in READ mode
	var dataFile = FileAccess.open(json_path, FileAccess.READ)
	# Read the content of the file as text
	var json = dataFile.get_as_text()
	var json_object = JSON.new()
	# Parse the JSON text
	json_object.parse(json)
	location_variables = json_object.data
