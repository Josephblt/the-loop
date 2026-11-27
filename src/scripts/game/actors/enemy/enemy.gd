class_name Enemy
extends GPUParticles3D


@export var ai_behaviour: EnemyBehaviour

@onready var _navigation_agent: NavigationAgent3D = %NavigationAgent3D
@onready var _navigation_obstacle: NavigationObstacle3D = %NavigationObstacle3D

var _movement_delta: float = 0.0


func navigate_to(target: Vector3) -> void:
	var navigation_target: Vector3 = target
	navigation_target.y = global_position.y
	_navigation_agent.path_height_offset = -global_position.y
	_navigation_agent.target_position = navigation_target


func move_along_path(delta: float, speed: float) -> void:
	var next_position: Vector3 = _navigation_agent.get_next_path_position()
	if _navigation_agent.is_navigation_finished():
		_movement_delta = 0.0
		if _navigation_agent.avoidance_enabled:
			_navigation_agent.velocity = Vector3.ZERO
		return

	next_position.y = global_position.y
	if not _navigation_agent.avoidance_enabled:
		global_position = global_position.move_toward(next_position, speed * delta)
		return
	_movement_delta = delta
	_navigation_agent.max_speed = speed
	_navigation_agent.velocity = global_position.direction_to(next_position) * speed


func set_avoidance_center(player_position: Vector3) -> void:
	player_position.y = global_position.y
	_navigation_obstacle.global_position = player_position


func set_avoidance_radius(radius: float) -> void:
	_navigation_obstacle.radius = radius


func set_avoidance_enabled(enabled: bool) -> void:
	_navigation_obstacle.avoidance_enabled = enabled
	_navigation_agent.avoidance_enabled = enabled
	if enabled:
		_navigation_agent.neighbor_distance = maxf(_navigation_agent.neighbor_distance, _navigation_obstacle.radius + _navigation_agent.radius)
	else:
		_movement_delta = 0.0


func _on_navigation_agent_velocity_computed(safe_velocity: Vector3) -> void:
	var movement: Vector3 = safe_velocity * _movement_delta
	movement.y = 0.0
	global_position += movement


func appear() -> void:
	print("Enemy appearing:" + str(emitting))
	emitting = true
	print("Enemy appeared:" + str(emitting))


func disappear() -> void:
	print("Enemy disappearing:" + str(emitting))
	emitting = false
	print("Enemy disappeared:" + str(emitting))
