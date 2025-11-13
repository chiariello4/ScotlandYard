extends Sprite2D

var texture_blue = preload("res://art/blue_piece.png")
var texture_pink = preload("res://art/pink_piece.png")
var player_icon : String

func _ready() -> void:
	texture = texture_pink

func _on_player_start_icon_selected(icon_choice: Variant) -> void:
	player_icon = icon_choice
	match player_icon:
		"blue":
			texture = texture_blue
		"pink":
			texture = texture_pink
