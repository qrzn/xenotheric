extends NodeState

var jump_sound = preload("res://sfx/Jump_3.wav")
@onready var jump_player: AudioStreamPlayer = $"../../SFX/Jump"



@export var character_body_2d : CharacterBody2D
@export var animated_sprite_2d : AnimatedSprite2D


@export_category("Jump State")
@export var jump_height : int = -400
@export var jump_horizontal_speed : int = 500
@export var max_jump_horizontal_speed : int = 300
@export var max_jump_count : int = 1
@export var jump_gravity : int = 1000

var current_jump_count : int
var coyote_jump : bool

func on_process(delta : float):
	pass

func on_physics_process(delta : float):
	# Apply gravity to the character
	character_body_2d.velocity.y += jump_gravity * delta
	
	if character_body_2d.is_on_floor():
		current_jump_count = 0
		character_body_2d.velocity.y = jump_height
		coyote_jump = false
		current_jump_count += 1
		play_jump_sound()
	
	if coyote_jump:
		character_body_2d.velocity.y = jump_height
		coyote_jump = false
		current_jump_count += 1
		play_jump_sound()
	
	# Handle multiple jumps
	if !character_body_2d.is_on_floor() and GameInputEvents.jump_input() and current_jump_count != max_jump_count:
		character_body_2d.velocity.y = jump_height
		current_jump_count += 1
	
	# Play the jump sound when jumping
		play_jump_sound()
	
	var direction : float = GameInputEvents.movement_input()
	
	# Update horizontal velocity while in the air
	if !character_body_2d.is_on_floor():
		character_body_2d.velocity.x += direction * jump_horizontal_speed
		character_body_2d.velocity.x = clamp(character_body_2d.velocity.x, -max_jump_horizontal_speed, max_jump_horizontal_speed)
		
		# Flip sprite based on movement direction
		if direction != 0:
			animated_sprite_2d.flip_h = direction < 0

	# Move the character
	character_body_2d.move_and_slide()
	
	# Transitioning states
	
	# idle state
	if character_body_2d.is_on_floor():
		transition.emit("Idle")
	
	# wall cling state
	if GameInputEvents.wall_cling_input() and character_body_2d.is_on_wall():
		transition.emit("ShootWallCling")

func enter():
	coyote_jump = true
	animated_sprite_2d.play("jump")
	

func exit():
	coyote_jump = false
	animated_sprite_2d.stop()

func play_jump_sound():
	if jump_player:
		jump_player.stream = jump_sound  # Set the stream to the jump sound
		jump_player.play()  # Play the sound
	else:
		print("AudioStreamPlayer is null!")
