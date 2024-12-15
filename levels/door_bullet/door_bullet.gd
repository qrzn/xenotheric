extends Node2D

@export var next_scene : String
@export var key_id : String

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var activate_door_area_2d: Area2D = $ActivateDoorArea2D


var door_open : bool

func _ready() -> void:
	# Connect the Area2D's body_entered signal to the door script
	activate_door_area_2d.connect("body_entered", Callable(self, "_on_activate_door_area_2d_body_entered"))

func _on_exit_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var player = body as CharacterBody2D
		player.queue_free()
	
	
	await get_tree().create_timer(3.0).timeout
	print("scene transition")
	SceneManager.transition_to_scene(next_scene)


func _on_activate_door_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Bullet"):  # Check if the body is a bullet
		print("Bullet detected, opening door")
		
		if !door_open:
			animated_sprite_2d.play("open")
			door_open = true
			collision_shape_2d.set_deferred("disabled", true)
			body.queue_free()  # Remove the bullet after it hits the door
	else:
		print("Non-bullet body entered: ", body)
