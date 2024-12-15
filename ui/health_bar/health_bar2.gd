extends Label

@onready var health_label: Label = $"."

func _ready() -> void:
	HealthManager.on_health_changed.connect(on_player_health_changed)
	update_health_display(HealthManager.current_health)  # Initialize the display

func on_player_health_changed(player_current_health: int):
	update_health_display(player_current_health)

func update_health_display(current_health: int):
	# Clamp the health value between 0 and 99
	current_health = clamp(current_health, 0, 99)
	health_label.text = str(current_health)  # Update the label text
