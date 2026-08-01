extends BaseDialogueTestScene

# This script diverts the dialogue manager to this custom dialogue
# instead of the out-of-the-box test dialogue.

func _ready() -> void:
	var balloon = load("res://dialog/balloon.tscn").instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(resource, title)
