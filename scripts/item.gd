extends RigidBody3D
class_name Item

@export var item_data: ItemData

func _ready() -> void:
	if item_data and item_data.model_scene:
		var instance = item_data.model_scene.instantiate()
		add_child(instance)
		$MeshInstance3D.queue_free()
		var scene_collision = _find_collision_shape(instance)
		if scene_collision:
			# Duplicate the shape so it doesn't conflict with other instances
			$CollisionShape3D.shape = scene_collision.shape.duplicate()
			$CollisionShape3D.position = scene_collision.position
			# Free the collision shape inside the model so it doesn't double-collide
			scene_collision.queue_free()
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

func _find_collision_shape(node: Node) -> CollisionShape3D:
	if node is CollisionShape3D:
		return node
	for child in node.get_children():
		var result = _find_collision_shape(child)
		if result:
			return result
	return null
