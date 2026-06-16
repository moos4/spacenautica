extends Area3D
class_name Interactable

# A signal that parent nodes (like your Item or Door) can listen to
signal interacted

func interact() -> void:
	# Trigger the signal when the player interacts with this component
	interacted.emit()
