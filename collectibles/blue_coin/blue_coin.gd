extends Node2D

@export var award_amount: int = 1
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label

var collected: bool = false  # To prevent multiple pickups

func _ready() -> void:
	label.hide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not collected:
		collected = true  # Mark as collected to prevent further triggers
		
		print(award_amount)
		
		animated_sprite_2d.hide()
		
		label.text = "%s" % award_amount
		CollectibleManager.give_pickup_award(award_amount)
		
		label.show()
		
		var tween = get_tree().create_tween()
		tween.tween_property(label, "position", Vector2(label.position.x, label.position.y + -10), 0.5).from_current()
		tween.tween_callback(queue_free)
