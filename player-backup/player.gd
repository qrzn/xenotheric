extends CharacterBody2D

var bullet = preload("res://player/bullet.tscn")
var player_death_effect = preload("res://player/player_death_effect/player_death_effect.tscn")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Marker2D = $Muzzle
@onready var hit_animation_player: AnimationPlayer = $HitAnimationPlayer

const GRAVITY = 1000
@export var speed: int = 1000
@export var max_horizontal_speed: int = 300
@export var slow_down_speed: int = 1700

@export var jump: int = -400
@export var jump_horizontal_speed: int = 1000
@export var max_jump_horizontal_speed: int = 300
@export var jump_count : int = 1

enum State { Idle, Run, Jump, Shoot }

var current_state

var muzzle_position 

var current_jump_count : int

var attack_duration: float = 0.5  # Duration of the attack animation
var attack_timer: float = 0.0  # Timer to track the attack animation
var is_shooting: bool = false  # Track if the player is currently shooting

func _ready():
	current_state = State.Idle
	muzzle_position = muzzle.position

func _physics_process(delta):
	player_falling(delta)
	player_run(delta)
	player_jump(delta)
	player_shooting(delta)
	player_muzzle_position()
	move_and_slide()
	player_animations(delta)

func input_movement() -> float:
	# Returns the direction based on player input
	var direction: float = Input.get_axis("move_left", "move_right")
	return direction

func player_falling(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta
		if current_state != State.Jump:
			current_state = State.Jump
	elif current_state == State.Jump:
		current_state = State.Idle

func player_idle():
	if is_on_floor() and velocity.x == 0 and !is_shooting:
		current_state = State.Idle

func player_run(delta):
	var direction = input_movement()  # Use the input_movement function here
	
	if direction != 0:
		velocity.x += direction * speed * delta
		velocity.x = clamp(velocity.x, -max_horizontal_speed, max_horizontal_speed)
		if is_on_floor():
			if current_state != State.Shoot:  # Do not change state if shooting
				current_state = State.Run
		animated_sprite_2d.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, slow_down_speed * delta)
		if is_on_floor() and current_state != State.Shoot:  # Do not change to idle if shooting
			player_idle()

func player_jump(delta):
	var jump_input : bool = Input.is_action_just_pressed("jump")
	
	if jump_input and is_on_floor():
		current_jump_count = 0
		velocity.y = jump
		current_jump_count += 1
		current_state = State.Jump
	
	if !is_on_floor() and jump_input and current_jump_count < jump_count:
		velocity.y = jump
		current_jump_count += 1
		current_state = State.Jump
		
	if !is_on_floor() and current_state == State.Jump:
		var direction = input_movement()  # Use the input_movement function here
		velocity.x += direction * jump_horizontal_speed * delta
		velocity.x = clamp(velocity.x, -max_jump_horizontal_speed, max_jump_horizontal_speed)

func player_shooting(delta):
	var direction = input_movement()
	
	if Input.is_action_just_pressed("shoot"):
		if direction != 0:  # Player is moving
			player_run_shoot()
		else:  # Player is standing still
			stand_shoot()

func player_run_shoot():
	var bullet_instance = bullet.instantiate() as Node2D
	bullet_instance.global_position = muzzle.global_position
	
	# Set bullet direction based on player facing direction
	var bullet_direction = 1  # Default to right
	if animated_sprite_2d.flip_h:
		bullet_direction = -1  # Shoot to the left if flipped
	
	bullet_instance.direction = bullet_direction
	get_parent().add_child(bullet_instance)
	current_state = State.Shoot
	attack_timer = attack_duration  # Reset attack timer to the duration of the attack

func stand_shoot():
	var bullet_instance = bullet.instantiate() as Node2D
	bullet_instance.global_position = muzzle.global_position
	
	# Set bullet direction based on player facing direction
	var bullet_direction = 1  # Default to right
	if animated_sprite_2d.flip_h:
		bullet_direction = -1  # Shoot to the left if flipped
	
	bullet_instance.direction = bullet_direction
	get_parent().add_child(bullet_instance)
	current_state = State.Shoot
	attack_timer = attack_duration  # Reset attack timer to the duration of the attack

func player_muzzle_position():
	var direction: int
	if animated_sprite_2d.flip_h:
		direction = -1
	else:
		direction = 1

	muzzle.position.x = abs(muzzle.position.x) * direction

func player_animations(delta):
	# When shooting, blend the shoot animation over the running animation.
	if current_state == State.Shoot:
		attack_timer -= delta
		if attack_timer > 0:
			if velocity.x != 0:
				animated_sprite_2d.play("run_shoot")
			else:
				animated_sprite_2d.play("stand_shoot")
		else:
			if velocity.x != 0:
				current_state = State.Run
			else:
				current_state = State.Idle
	elif current_state == State.Idle:
		animated_sprite_2d.play("idle")
	elif current_state == State.Run:
		animated_sprite_2d.play("run")
	elif current_state == State.Jump:
		animated_sprite_2d.play("jump")

func player_death():
	var player_death_effect_instance = player_death_effect.instantiate() as Node2D
	player_death_effect_instance.global_position = global_position
	get_parent().add_child(player_death_effect_instance)
	queue_free()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		print("Enemy entered. ", body.damage_amount)
		hit_animation_player.play("hit")
		HealthManager.decrease_health(body.damage_amount)
	
	if HealthManager.current_health == 0:
		player_death()
