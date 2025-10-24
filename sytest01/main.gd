extends Node2D

@onready var player : Sprite2D
@onready var start_location : Marker2D
@onready var end_location : Marker2D

func _ready() -> void:
	player = $Cop
	start_location = $MapLocation/MapLocation001
	end_location = $MapLocation/MapLocation008
	var player_tween = create_tween()
	player_tween.tween_property(player, "position", end_location.position, 1)
	
