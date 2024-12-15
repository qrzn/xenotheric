class_name NodeFiniteStateMachine
extends Node

@export var initial_node_state: NodeState

var node_states: Dictionary = {}
var current_node_state: NodeState
var current_node_state_name: String


func _ready() -> void:
	# Populate the dictionary with node states
	for child in get_children():
		if child is NodeState:
			# Add the state to the dictionary using the lowercase name as the key
			node_states[child.name.to_lower()] = child
			child.transition.connect(transition_to)
	
	# Set the initial state
	if initial_node_state:
		initial_node_state.enter()
		current_node_state = initial_node_state
		current_node_state_name = initial_node_state.name.to_lower()

func _process(delta: float) -> void:
	if current_node_state:
		current_node_state.on_process(delta)
	

func _physics_process(delta: float) -> void:
	if current_node_state:
		current_node_state.on_physics_process(delta)
	
	#print("Current State: ", current_node_state_name)

func transition_to(node_state_name: String) -> void:
	# Check if the state is the same as the current one
	if node_state_name == current_node_state_name:
		return
	
	# Get the new state from the dictionary
	var new_node_state = node_states.get(node_state_name.to_lower())
	
	# If the new state does not exist, do nothing
	if !new_node_state:
		return
	
	# Exit the current state, if applicable
	if current_node_state:
		current_node_state.exit()
	
	# Enter the new state
	new_node_state.enter()
	
	# Update current state
	current_node_state = new_node_state
	current_node_state_name = current_node_state.name.to_lower()
