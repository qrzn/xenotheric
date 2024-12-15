extends CharacterBody2D

var enemy_death_effect = preload("res://enemies/enemy_death_effect.tscn")
var key_scene = preload("res://levels/keys/key.tscn")  # Preload your key scene

@export var health_amount : int = 10
@export var damage_amount : int = 1
@export var key_id : String = ""  # Assign a key ID for this enemy to drop

func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("Hurtbox area entered.")
	if area.get_parent().has_method("get_damage_amount"):
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount
		print("Health amount: ", health_amount)
		if health_amount <= 0:
			enemy_death()
			queue_free()

func enemy_death():
	# Play death effect
	var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
	enemy_death_effect_instance.global_position = global_position
	get_parent().add_child(enemy_death_effect_instance)

	# Drop the key
	var key_instance = key_scene.instantiate() as Node2D
	key_instance.global_position = global_position
	key_instance.key_id = key_id  # Set the key ID in the key instance
	get_parent().add_child(key_instance)
