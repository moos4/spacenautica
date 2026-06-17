extends CanvasLayer
class_name PlayerInventory

@export var max_slots: int = 6
@export var slot_scene_fallback: PackedScene = preload("res://scenes/Inventory/inventory_ui_slot.tscn")

# Find the GridContainer inside your UI layout tree
@onready var grid_container: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/GridContainer

# The actual backend array holding item items
var slots: Array[ItemData] = []

func _ready() -> void:
	slots.resize(max_slots)
	setup_slots()
	# Start hidden by default
	hide() 

func setup_slots() -> void:
	# Clear out any dummy testing elements in the editor grid
	for child in grid_container.get_children():
		child.queue_free()
		
	# Instantiate our visual grid slots
	for i in range(max_slots):
		var slot_instance = slot_scene_fallback.instantiate()
		grid_container.add_child(slot_instance)
		
	refresh_ui()

func try_add_item(item_data: ItemData) -> bool:
	if item_data == null:
		return false
		
	# Find the first vacant layout slot
	for i in range(slots.size()):
		if slots[i] == null:
			slots[i] = item_data
			refresh_ui()
			return true
	
	print("Cannot add item: Inventory is full!")
	return false

func refresh_ui() -> void:
	var visual_slots = grid_container.get_children()
	for i in range(slots.size()):
		if i < visual_slots.size():
			if visual_slots[i] is InventorySlot:
				visual_slots[i].display_item(slots[i])
