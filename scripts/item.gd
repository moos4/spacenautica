extends RigidBody3D
class_name Interactable # This lets the player script identify it easily

@export var item_name: String = "Generic Item"

func collect():
	print("Picked up: ", item_name)
	queue_free() # Removes the item from the world
