extends CharacterBody2D

var enemy_death_effect = preload("res://enemies/enemy_death_effect.tscn")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer  # Ensure the Timer node is named 'Timer'
@export var patrol_points: Node
@export var speed : int = 1500
@export var wait_time : int = 3
@export var health_amount : int = 3
@export var damage_amount : int = 10


const GRAVITY = 1000


enum State { Idle, Walk, Wait }  # Added Wait state
var current_state: State
var direction: Vector2 = Vector2.LEFT
var number_of_points: int
var point_positions: Array[Vector2] = []  # Initialize the array
var current_point: Vector2
var current_point_position: int = 0  # Initialize position index
var moving_forward: bool = true  # Track whether the enemy is moving forward
var can_walk: bool = false  # Start with the enemy unable to walk


func _ready():
	if patrol_points != null:
		number_of_points = patrol_points.get_children().size()
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
		current_point = point_positions[current_point_position]
	else:
		print("No patrol points")

	timer.wait_time = wait_time
	current_state = State.Wait  # Start in wait state

	# Timer setup
	if timer:  # Make sure timer is not null
		timer.wait_time = wait_time  # Set the wait time for the timer
		timer.one_shot = true  # Make the timer one-shot
		timer.connect("timeout", Callable(self, "_on_timer_timeout"))  # Correct usage of connect
		timer.start()  # Start the timer initially

func _physics_process(delta: float):
	enemy_gravity(delta)

	match current_state:
		State.Wait:
			enemy_idle()  # Stay idle while waiting
		State.Walk:
			enemy_walk(delta)

	move_and_slide()
	enemy_animations()

func enemy_gravity(delta: float):
	velocity.y += GRAVITY * delta

func enemy_idle():
	velocity.x = 0  # Stop moving while waiting

func enemy_walk(delta: float):
	if !can_walk:
		return

	if abs(position.x - current_point.x) > 0.5:  # Check if the enemy is close to the current point
		velocity.x = direction.x * speed * delta
		current_state = State.Walk
	else:
		# Start the timer to wait at the current point
		can_walk = false
		current_state = State.Wait
		timer.start()  # Start the timer again when reaching the patrol point

		# Update current point position
		if moving_forward:
			current_point_position += 1
			if current_point_position >= point_positions.size():
				current_point_position = point_positions.size() - 1  # Stay at last point
				moving_forward = false  # Start moving backward
		else:
			current_point_position -= 1
			if current_point_position < 0:
				current_point_position = 0  # Stay at first point
				moving_forward = true  # Start moving forward

		# Update the current_point safely
		if current_point_position >= 0 and current_point_position < point_positions.size():  # Bounds check
			current_point = point_positions[current_point_position]

	# Update direction based on current point position
	if current_point.x > position.x:
		direction = Vector2.RIGHT
		animated_sprite_2d.flip_h = true  # Face right
	else:
		direction = Vector2.LEFT
		animated_sprite_2d.flip_h = false  # Face left

func enemy_animations():
	if current_state == State.Idle:
		animated_sprite_2d.play("idle")
	elif current_state == State.Walk:
		animated_sprite_2d.play("walk")
	elif current_state == State.Wait:
		animated_sprite_2d.play("idle")  # Set to idle animation while waiting

func _on_timer_timeout() -> void:
	can_walk = true
	current_state = State.Walk  # Change state to Walk after waiting


func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("Hurtbox area entered.")
	if area.get_parent().has_method("get_damage_amount"):
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount
		print("Health amount: ", health_amount)
		if health_amount <= 0:
			var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
			enemy_death_effect_instance.global_position = global_position
			get_parent().add_child(enemy_death_effect_instance)
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
