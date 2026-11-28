class_name Enemy
extends GPUParticles3D


@export var ai_behaviour: EnemyBehaviour

@onready var _navigation_agent: NavigationAgent3D = %NavigationAgent3D


func navigate_to(target: Vector3) -> void:
	var navigation_target: Vector3 = target
	navigation_target.y = global_position.y
	_navigation_agent.path_height_offset = -global_position.y
	_navigation_agent.target_position = navigation_target


func move_along_path(delta: float, speed: float) -> void:
	var next_position: Vector3 = _navigation_agent.get_next_path_position()
	if _navigation_agent.is_navigation_finished():
		return

	next_position.y = global_position.y
	global_position = global_position.move_toward(next_position, speed * delta)


func appear() -> void:
	print("Enemy appearing:" + str(emitting))
	emitting = true
	print("Enemy appeared:" + str(emitting))


func disappear() -> void:
	print("Enemy disappearing:" + str(emitting))
	emitting = false
	print("Enemy disappeared:" + str(emitting))
