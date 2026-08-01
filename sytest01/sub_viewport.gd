extends SubViewport

@onready var main_viewport = get_viewport()
@onready var sub_viewport: SubViewport = $"."
@onready var camera_2d_sus_player: Camera2D = $"Camera2D_sus-player"
@onready var agent_01: Sprite2D = $"../../../../Players/agent01"
@onready var agent_02: Sprite2D = $"../../../../Players/agent02"
@onready var agent_03: Sprite2D = $"../../../../Players/agent03"
@onready var agent_04: Sprite2D = $"../../../../Players/agent04"
@onready var agent_05: Sprite2D = $"../../../../Players/agent05"
@onready var sus_00: Sprite2D = $"../../../../Players/sus00"

var sprite_focus : Sprite2D

func _ready():
	# Share the main world with the new viewport
	sub_viewport.world_2d = get_tree().current_scene.get_viewport().world_2d
	sprite_focus = sus_00

func _process(_delta: float) -> void:
	camera_2d_sus_player.global_position = sprite_focus.global_position

func _on_player_panel_viewport_focus(player: Variant) -> void:
	sprite_focus = player
