extends Node

signal movement_queue_updated(queue: Array[Vector3])
signal new_destination(position: Vector3)
signal queue_cleared()

var position_queue: Array[Vector3] = []


func _ready() -> void:
	# Add to group so entities can find this queue
	add_to_group("movement_queue")

	# Connect to the world_space_caster if it exists
	var caster = get_tree().get_first_node_in_group("world_caster")
	if caster and caster.has_signal("world_position_clicked"):
		caster.world_position_clicked.connect(_on_world_position_clicked)


func _on_world_position_clicked(position: Vector3, normal: Vector3, collider: Object) -> void:
	# Check if shift + right click is held (queue mode)
	if Input.is_action_pressed("right_click_shift"):
		# Add to queue
		position_queue.append(position)
		print("Queued position: ", position, " | Total in queue: ", position_queue.size())
	else:
		# Clear queue and set new destination
		position_queue.clear()
		position_queue.append(position)
		print("New destination (queue cleared): ", position)

	movement_queue_updated.emit(position_queue)
	new_destination.emit(position_queue[0])


func get_current_target() -> Vector3:
	if position_queue.is_empty():
		return Vector3.ZERO
	return position_queue[0]


func advance_queue() -> void:
	if not position_queue.is_empty():
		position_queue.pop_front()
		print("Advanced queue. Remaining: ", position_queue.size())
		movement_queue_updated.emit(position_queue)

		if not position_queue.is_empty():
			new_destination.emit(position_queue[0])
		else:
			queue_cleared.emit()


func clear_queue() -> void:
	position_queue.clear()
	print("Queue cleared")
	queue_cleared.emit()
	movement_queue_updated.emit(position_queue)


func get_queue() -> Array[Vector3]:
	return position_queue


func is_queue_empty() -> bool:
	return position_queue.is_empty()
