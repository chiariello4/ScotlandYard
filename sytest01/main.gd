extends Node2D

@onready var player_piece: Sprite2D = $PlayerPiece
@export var map_locations : Array[Node]
var player : Sprite2D
var player_location : int
var player_icon : Texture2D

func _ready() -> void:
	#Set the player. This will be changed later.
	player = player_piece

#func _on_player_start_location_selected(location_choice: Variant) -> void:
	#player_location = location_choice
	#var player_move_start = create_tween()
	#player_move_start.tween_property(player, "position", map_locations[player_location].position, 1)

func move_player() -> void:
	pass
