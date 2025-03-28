extends Node2D

@export var pickup_amount : int = 10

func _on_health_pickup_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		HealthManager.increase_health(pickup_amount)
		queue_free()
