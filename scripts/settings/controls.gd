extends Control

@export var input_row_scene: PackedScene = preload("res://scenes/settings/input_row.tscn")
@onready var action_list = $MarginContainer/ScrollContainer/ActionList

const REMAPPABLE_ACTIONS = ["move_left", "move_right", "move_up", "move_back", "jump", "interact", "sprint", "open_ui", "use_oxygen_boost"]
const SAVE_PATH = "user://keybinds.cfg"

var is_rebinding: bool = false
var current_action_to_rebind: String = ""
var current_button_to_update: Button = null

func _ready() -> void:
	load_keybinds()
	create_action_list()

func create_action_list() -> void:
	for child in action_list.get_children():
		child.queue_free()
	for action in REMAPPABLE_ACTIONS:
		var row = input_row_scene.instantiate()
		action_list.add_child(row)
		var events = InputMap.action_get_events(action)
		var current_key_text = "Unbound"
		if events.size() > 0:
			current_key_text = events[0].as_text().get_slice(" (", 0)
			
		row.set_action_data(action, current_key_text)
		row.rebind_requested.connect(_on_rebind_requested)

func _on_rebind_requested(action_name: String, button_ref: Button) -> void:
	if not is_rebinding:
		is_rebinding = true
		current_action_to_rebind = action_name
		current_button_to_update = button_ref
		button_ref.text = "Press any key..."

func _input(event: InputEvent) -> void:
	if not is_rebinding:
		return
	if event is InputEventKey or (event is InputEventMouseButton and event.is_pressed()):
		get_viewport().set_input_as_handled()
		InputMap.action_erase_events(current_action_to_rebind)
		InputMap.action_add_event(current_action_to_rebind, event)
		save_keybind(current_action_to_rebind, event)
		var new_text = event.as_text().get_slice(" (", 0)
		current_button_to_update.text = new_text
		is_rebinding = false
		current_action_to_rebind = ""
		current_button_to_update = null

func save_keybind(action_name: String, event: InputEvent) -> void:
	var config = ConfigFile.new()
	
	# Load the existing file first so we don't overwrite OTHER saved actions
	if config.load(SAVE_PATH) == OK:
		pass # Successfully loaded existing config to append to it
		
	# Store the event inside a "Controls" section
	config.set_value("Controls", action_name, event)
	
	# Write the file back to the user's device
	config.save(SAVE_PATH)

func load_keybinds() -> void:
	var config = ConfigFile.new()
	
	# Try to load the file. If it doesn't exist yet (first time booting), stop here.
	if config.load(SAVE_PATH) != OK:
		return 
		
	# Loop through our known actions and check if they exist in the file
	for action in REMAPPABLE_ACTIONS:
		if config.has_section_key("Controls", action):
			# Pull the saved InputEvent out of the file
			var saved_event = config.get_value("Controls", action)
			
			# Clear the default project setting and apply the loaded one
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, saved_event)
