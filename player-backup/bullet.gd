extends AnimatedSprite2D

var bullet_impact_effect = preload("res://player/bullet_impact_effect.tscn")

var speed : int = 600
var direction : int
var damage_amount : int = 1

func _physics_process(delta: float):
	move_local_x(direction * speed * delta)

func _on_timer_timeout():
	queue_free()


func _on_hitbox_area_entered(area: Area2D):
	print("Bullet area entered.")
	bullet_impact()


func _on_hitbox_body_entered(body: Node2D):
	print("Bullet body entered.")
	bullet_impact()

func get_damage_amount() -> int:
	return damage_amount

func bullet_impact():
	var bullet_impact_effect_instance = bullet_impact_effect.instantiate() as Node2D
	bullet_impact_effect_instance.global_position = global_position
	get_parent().add_child(bullet_impact_effect_instance)

	# If the root node of bullet_impact_effect.tscn is an AnimatedSprite2D, use "." to reference it
	var animated_sprite = bullet_impact_effect_instance as AnimatedSprite2D

	# If it's not the root node, use the correct path (e.g., $AnimatedSprite2D)
	# var animated_sprite = bullet_impact_effect_instance.get_node("AnimatedSprite2D")

	if animated_sprite:
		animated_sprite.play("impact")  # Replace with the name of your animation
		print("Animation played: impact")  # Confirm the animation is played
	else:
		print("Error: AnimatedSprite2D node not found in the impact effect.")

	print("Impact effect instantiated at position: ", bullet_impact_effect_instance.global_position)
	
	queue_free()
