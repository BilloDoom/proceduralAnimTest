extends Node3D

signal world_position_clicked(position: Vector3, normal: Vector3, collider: Object)

@export var camera: Camera3D
@export var ray_length: float = 1000.0


func _ready() -> void:
	add_to_group("world_caster")
	if not camera:
		camera = get_viewport().get_camera_3d()


func _input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CONFINED:
		return

	if event is InputEventMouseButton:
		# Right click for setting destinations
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			_perform_raycast(event.position)


func _perform_raycast(screen_pos: Vector2) -> void:
	if not camera:
		return

	var from = camera.project_ray_origin(screen_pos)
	var to = from + camera.project_ray_normal(screen_pos) * ray_length

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)

	if result:
		print("Hit position: ", result.position)
		world_position_clicked.emit(result.position, result.normal, result.collider)
