extends CharacterBody3D


const SPEED = 5.0

# Node references
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var interaction_shape: CollisionShape3D = $InteractionArea/InteractionShape
@onready var interaction_area: Area3D = $InteractionArea
@onready var movement_queue: Node = $MovementQueue

# State
var is_selected: bool = false


func _ready() -> void:
	# Find and connect to movement queue
	if movement_queue:
		movement_queue.new_destination.connect(_on_new_destination)
		movement_queue.queue_cleared.connect(_on_queue_cleared)

	# Setup navigation agent
	navigation_agent_3d.path_desired_distance = 0.5
	navigation_agent_3d.target_desired_distance = 1.0

	# Enable avoidance if using velocity_computed
	# For now, we'll use direct movement without avoidance
	# navigation_agent_3d.velocity_computed.connect(_on_velocity_computed)
	# navigation_agent_3d.avoidance_enabled = true

	# Setup interaction area for selection detection
	interaction_area.input_event.connect(_on_interaction_area_input)

	# Wait for navigation to be ready (one frame delay)
	call_deferred("_actor_setup")


func _actor_setup() -> void:
	# Wait for first physics frame so NavigationServer can sync
	await get_tree().physics_frame


func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Only move if selected and navigation agent has a target
	if is_selected and not navigation_agent_3d.is_navigation_finished():
		var next_position = navigation_agent_3d.get_next_path_position()
		var distance_to_target = navigation_agent_3d.distance_to_target()

		var direction = (next_position - global_position).normalized()

		# Slow down as we approach the final destination (not waypoints)
		if distance_to_target < navigation_agent_3d.target_desired_distance * 2.0:
			# Near destination - slow down for smooth arrival
			var speed_multiplier = clamp(distance_to_target / navigation_agent_3d.target_desired_distance, 0.2, 1.0)
			velocity.x = direction.x * SPEED * speed_multiplier
			velocity.z = direction.z * SPEED * speed_multiplier
		else:
			# Far from destination - full speed through waypoints
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		# Apply friction when not moving
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	# Check if we reached the target and advance queue
	if is_selected and navigation_agent_3d.is_navigation_finished():
		if movement_queue and not movement_queue.is_queue_empty():
			movement_queue.advance_queue()


func _on_new_destination(position: Vector3) -> void:
	# Only respond if this entity is selected
	if is_selected:
		navigation_agent_3d.target_position = position


func _on_queue_cleared() -> void:
	# Stop movement when queue is cleared
	if is_selected:
		navigation_agent_3d.target_position = global_position


func _on_interaction_area_input(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	# Handle entity selection via mouse click on interaction area
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			select()


func select() -> void:
	is_selected = true
	print("Entity selected: ", name)
	# TODO: Add visual feedback (outline, highlight, etc.)


func deselect() -> void:
	is_selected = false
	print("Entity deselected: ", name)
	# TODO: Remove visual feedback
