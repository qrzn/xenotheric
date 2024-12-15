extends NodeState

var bullet = preload("res://player/bullet.tscn")
var shoot_sound = preload("res://sfx/Laser_3.wav")

@export var character_body_2d : CharacterBody2D
@export var animated_sprite_2d : AnimatedSprite2D
@export var muzzle : Marker2D
@export var hold_gun_time : float = 2.0

@onready var shoot: AudioStreamPlayer = $"../../SFX/Shoot"


var muzzle_position : Vector2

func on_process(delta : float):
	pass

func on_physics_process(delta : float):
	gun_muzzle_position()

	if GameInputEvents.shoot_input():
		gun_shooting()

	# transitioning states
	
	# run state
	var direction : float = GameInputEvents.movement_input()

	if direction and character_body_2d.is_on_floor():
		transition.emit("Run")
	
	# jump state
	if GameInputEvents.jump_input():
		transition.emit("Jump")

func enter():
	muzzle_position = muzzle.position
	muzzle_position = Vector2(16, -30)
	#muzzle_position = muzzle.position
	
	get_tree().create_timer(hold_gun_time).timeout.connect(on_hold_gun_timeout)
	
	animated_sprite_2d.play("shoot_stand")

func exit():
	animated_sprite_2d.stop()


func on_hold_gun_timeout():
	transition.emit("Idle")


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
