extends HBoxContainer

signal rebind_requested(action_name, button_reference)

@onready var action_label = $ActionLabel
@onready var change_button = $ChangeButton

var action_key: String = ""

# Setup the row with the action name and its current key text
func set_action_data(action_name: String, event_text: String) -> void:
	action_key = action_name
	# Cleans up "move_left" to look like "Move Left"
	action_label.text = action_name.replace("_", " ").capitalize() 
	change_button.text = event_text

func _on_change_button_pressed() -> void:
	# Tell the main menu we want to change this specific action
	rebind_requested.emit(action_key, change_button)
