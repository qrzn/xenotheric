extends AnimatedSprite2D

var bullet_impact_effect = preload("res://player/bullet_impact_effect.tscn")
var bullet_impact_effect_sound = preload("res://sfx/impact.wav")

var speed : int = 600
var direction : int
var damage_amount : int = 1
var move_x_direction : bool

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	add_to_group("Bullet")

func _physics_process(delta: float):
	if move_x_direction:
		move_local_x(direction * speed * delta)
	else:
		move_local_y(direction * speed * delta)

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
	# Instantiate the bullet impact effect
	var bullet_impact_effect_instance = bullet_impact_effect.instantiate() as Node2D
	bullet_impact_effect_instance.global_position = global_position
	get_parent().add_child(bullet_impact_effect_instance)

	# Play the impact sound
	play_sound()

	# Check if the animated sprite exists in the impact effect instance
	var animated_sprite = bullet_impact_effect_instance.get_node("AnimatedSprite2D")  # Use the correct path

	if animated_sprite:
		animated_sprite.play("impact")  # Replace with the name of your animation
		print("Animation played: impact")  # Confirm the animation is played
	else:
		print("Error: AnimatedSprite2D node not found in the impact effect.")

	print("Impact effect instantiated at position: ", bullet_impact_effect_instance.global_position)
	
	queue_free()

func play_sound():
	# Play the impact effect sound
	if audio_stream_player:
		audio_stream_player.stream = bullet_impact_effect_sound  # Set the sound stream
		audio_stream_player.play()  # Play the sound
	else:
		print("AudioStreamPlayer is null!")
