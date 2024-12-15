extends CanvasLayer

@onready var collectible_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/CollectibleLabel
@onready var key_yes_texture: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer3/Control/KeyYesTextureRect
@onready var key_no_texture: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer3/Control/KeyNoTextureRect

var key_id : String  # The key ID you want to check

func _ready() -> void:
	# Connect the inventory_changed signal
	InventoryManager.connect("inventory_changed", Callable(self, "_on_inventory_changed"))

	# Connect to the signal for collectible changes
	# Update the key display when the game starts

func _on_inventory_changed():
	print("Inventory changed! Updating key display...")  # Debugging message

func _on_pause_texture_button_pressed() -> void:
	GameManager.pause_game()
