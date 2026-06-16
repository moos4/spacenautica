extends RigidBody3D
class_name Item

@export var item_data: ItemData

func _ready() -> void:
	if item_data and item_data.model_scene:
		var instance = item_data.model_scene.instantiate()
		add_child(instance)
		$MeshInstance3D.queue_free()
	elif item_data and item_data.model:
		$MeshInstance3D.mesh = item_data.model
		var convex_shape = item_data.model.create_convex_shape()
		$CollisionShape3D.shape = convex_shape
	if has_node("Interactable"):
		$Interactable.interacted.connect(_on_interacted)

func _on_interacted() -> void:
	if item_data:
		print("Picked up data for: ", item_data.name)
	queue_free()
