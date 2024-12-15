extends NodeState

var bullet = preload("res://player/bullet.tscn")
var shoot_sound = preload("res://sfx/Laser_3.wav")

@export var character_body_2d : CharacterBody2D
@export var animated_sprite_2d : AnimatedSprite2D
@export var muzzle : Marker2D

@export_category("Run State")
@export var speed : int = 1000
@export var max_horizontal_speed : int = 300

@onready var shoot: AudioStreamPlayer = $"../../SFX/Shoot"

var muzzle_position : Vector2

func on_process(delta : float):
	pass

func on_physics_process(delta : float):
	
	var direction : float = GameInputEvents.movement_input()
	
	gun_muzzle_position(direction)
	
	if direction:
		character_body_2d.velocity.x += direction * speed
		character_body_2d.velocity.x = clamp(character_body_2d.velocity.x, -max_horizontal_speed, max_horizontal_speed)
	
	if direction != 0:
		animated_sprite_2d.flip_h = false if direction > 0 else true

	if GameInputEvents.shoot_input():
		gun_shooting(direction)
	
	character_body_2d.move_and_slide()

	# transitioning states
	
	# fall state
	if !character_body_2d.is_on_floor():
		transition.emit("fall")
	
	# idle state
	if direction == 0:
		transition.emit("idle")
	
	# jump state
	if GameInputEvents.jump_input():
		transition.emit("jump")

func enter():
	muzzle_position = muzzle.position
	muzzle_position = Vector2(16, -30)
	#muzzle_position = muzzle.position
	
	
	animated_sprite_2d.play("shoot_run")

func exit():
	animated_sprite_2d.stop()


func gun_muzzle_position(direction : float):
	# Maintain the upward y-position and handle horizontal flipping
	muzzle.position.y = muzzle_position.y  # Keep the y-position for upward shooting

	# Flip muzzle horizontally based on character's facing direction
	if direction > 0:
		muzzle.position.x = muzzle_position.x  # Facing right
	elif direction < 0:
		muzzle.position.x = -muzzle_position.x  # Facing left

func gun_shooting(direction : float):
	
	var bullet_instance = bullet.instantiate() as Node2D
	# Set bullet direction based on player's facing direction
	bullet_instance.direction = direction
	bullet_instance.move_x_direction = true
	
	# Set the bullet's position to the muzzle's global position
	bullet_instance.global_position = muzzle.global_position
	
	get_parent().add_child(bullet_instance)
	# Play the shooting sound
	if shoot:
		shoot.stream = shoot_sound  # Set the stream to the shoot sound
		shoot.play()  # Play the sound
	else:
		print("AudioStreamPlayer is null!")
