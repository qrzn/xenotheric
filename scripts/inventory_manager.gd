extends Node

signal inventory_changed  # Signal to notify when inventory changes

var inventory : Dictionary = {}  # Initialize as an empty dictionary

func add_to_inventory(type : String, value : String):
	print("Adding to inventory:", type, "Value:", value)  # Debugging message
	inventory[type] = value  # Store the item
	emit_signal("inventory_changed")  # Emit signal for inventory change

func has_inventory_item(value : String) -> bool:
	if value == null:
		return false
	
	# Check if the value exists in the inventory dictionary
	for inventory_value in inventory.values():
		if inventory_value == value:
			return true
	
	return false

func remove_from_inventory(value : String) -> void:
	if inventory.has(value):
		inventory.erase(value)
		print("Key removed from inventory: ", value)
