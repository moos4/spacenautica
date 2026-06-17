extends Panel
class_name InventorySlot

# Pivot node inside your isolated viewport where items spawn
@onready var mesh_holder: Node3D = $SubViewportContainer/SubViewport/Node3D

func display_item(item_data: ItemData) -> void:
	for child in mesh_holder.get_children():
		child.queue_free()
	if item_data == null:
		return

	if item_data.model_scene:
		var instance = item_data.model_scene.instantiate()
		mesh_holder.add_child(instance)
	else:
		var mesh_instance = MeshInstance3D.new()
		if item_data.model:
			mesh_instance.mesh = item_data.model
		else:
			mesh_instance.mesh = SphereMesh.new()
		mesh_holder.add_child(mesh_instance)

func _process(delta: float) -> void:
	# Give the 3D item preview a nice slow presentation spin
	if mesh_holder.get_child_count() > 0:
		mesh_holder.rotate_y(delta * 0.6)
