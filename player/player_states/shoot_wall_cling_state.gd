extends NodeState

var bullet = preload("res://player/bullet.tscn")
var shoot_sound = preload("res://sfx/Laser_3.wav")

@export var character_body_2d : CharacterBody2D
@export var animated_sprite_2d : AnimatedSprite2D
@export var muzzle : Marker2D

@onready var shoot: AudioStreamPlayer = $"../../SFX/Shoot"

var wall_cling_direction : Vector2
var muzzle_position : Vector2

func on_process(delta : float):
	pass

func on_physics_process(delta : float):
	character_body_2d.velocity.y = 0
	
	var direction : float = GameInputEvents.movement_input()
	
	if direction > 0 and wall_cling_direction == Vector2.ZERO:
		animated_sprite_2d.flip_h = true
		wall_cling_direction = Vector2.RIGHT
	
	if direction < 0 and wall_cling_direction == Vector2.ZERO:
		animated_sprite_2d.flip_h = false
		wall_cling_direction = Vector2.LEFT
	
	gun_muzzle_position()

	if GameInputEvents.shoot_input():
		gun_shooting()
	
	character_body_2d.move_and_slide()

	# transitioning states
	
	# jump state
	if GameInputEvents.jump_input():
		transition.emit("jump")
	
	# forced fall state
	if GameInputEvents.fall_input():
		transition.emit("fall")

func enter():
	#muzzle_position = muzzle.position
	muzzle_position = Vector2(21, -28)
	#muzzle_position = muzzle.position
	
	
	animated_sprite_2d.play("shoot_wall_cling")

func exit():
	wall_cling_direction = Vector2.ZERO
	animated_sprite_2d.stop()


func gun_muzzle_position():
	# Maintain the upward y-position and handle horizontal flipping
	muzzle.position.y = muzzle_position.y  # Keep the y-position for upward shooting

	# Flip muzzle horizontally based on character's facing direction
	if !animated_sprite_2d.flip_h:
		muzzle.position.x = muzzle_position.x  # Facing right
	else:
		muzzle.position.x = -muzzle_position.x  # Facing left

func gun_shooting():
	var direction : float = -1 if animated_sprite_2d.flip_h else 1
	
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
