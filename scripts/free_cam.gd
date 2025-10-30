extends CharacterBody3D


const SPEED = 10.0
const SENSITIVITY = 0.003

var rotation_x := 0.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	# Toggle mouse mode
	if Input.is_action_just_pressed("cam_switch"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Mouse look
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * SENSITIVITY)
		rotation_x -= event.relative.y * SENSITIVITY
		rotation_x = clamp(rotation_x, -PI/2, PI/2)
		rotation.x = rotation_x


func _physics_process(_delta: float) -> void:
	# Get horizontal movement
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Get vertical movement (Q/E or Space/Ctrl)
	var vertical := 0.0
	if Input.is_action_pressed("jump"):  # Space
		vertical = 1.0
	if Input.is_action_pressed("crouch"):  # Escape (you might want to change this)
		vertical = -1.0

	# Apply movement
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	velocity.y = vertical * SPEED

	move_and_slide()
