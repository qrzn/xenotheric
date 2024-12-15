extends Node2D

@export var key_id : String

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("Key picked up! ID:", key_id)  # Debug message
		InventoryManager.add_to_inventory("Key1", key_id)  # Adding key
		queue_free()
