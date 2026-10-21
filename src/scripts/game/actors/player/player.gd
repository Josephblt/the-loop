class_name Player
extends CharacterBody3D


const RUN_SPEED: float = 7.5
const WALK_SPEED: float = 3.0
const SENSITIVITY: float = 0.1
const JUMP_VELOCITY: float = 10.0

@onready var camera: Camera3D = %Camera3D
@onready var raycast: RayCast3D = %RayCast3D
@onready var recticle: Control = %Recticle

var _active_interactable: Interactable
var _controls_locked: bool = false
var _interacting: bool = false
var _look_x: float = 0.0
var _look_y: float = 0.0
var _speed: float = RUN_SPEED


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED 
	_look_y = rotation_degrees.y


func _physics_process(_delta: float) -> void:
	if _controls_locked:
		return

	_handle_movement()
	_handle_gravity(_delta)

	move_and_slide()


func _input(event):
	if _controls_locked:
		return

	if event is InputEventMouseMotion:
		_handle_look(event.relative)
	
	_handle_speed()
	_handle_jump()
	_handle_interactables()


func _handle_gravity(delta: float):
	velocity += get_gravity() * 4.0 * delta


func _handle_jump() -> void:
	if Input.is_action_just_pressed("Jump"):
		velocity.y = JUMP_VELOCITY


func _handle_speed():
	if Input.is_action_pressed("Walk"):
		_speed = WALK_SPEED
	if Input.is_action_just_released("Walk"):
		_speed = RUN_SPEED


func _handle_movement():
	if is_on_floor() or !is_on_floor():
		var input_dir: Vector2 = Input.get_vector("Left", "Right", "Forward", "Back")
	
		var direction: Vector3 = (global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * _speed
			velocity.z = direction.z * _speed
		else:
			velocity.x = move_toward(velocity.x, 0, _speed)
			velocity.z = move_toward(velocity.z, 0, _speed)


func _handle_look(motion: Vector2):
	_look_y -= motion.x * SENSITIVITY
	_look_x -= motion.y * SENSITIVITY
	_look_x = clamp(_look_x, -80, 80) 
	rotation_degrees.y = _look_y 
	camera.rotation_degrees.x = _look_x	


func _handle_interactables():
	var interactable = null
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		interactable = collider.get_parent() as Interactable
		if interactable:
			var origin: Vector3 = raycast.to_global(Vector3.ZERO)
			var collision_point: Vector3 = raycast.get_collision_point()
			var origin2D: Vector2 = Vector2(origin.x, origin.z)
			var collision_point2D: Vector2 = Vector2(collision_point.x, collision_point.z)
			
			var collision_distance: float = origin2D.distance_to(collision_point2D)
			if collision_distance > interactable.interaction_distance:
				interactable = null

	if interactable:
		if interactable != _active_interactable:
			if _active_interactable:
				_active_interactable.disable_interaction()
			_active_interactable = interactable	
			_active_interactable.enable_interaction()
	else:
		if _active_interactable:
			_active_interactable.disable_interaction()
			_active_interactable = null

	if Input.is_action_just_pressed("Interact") and _active_interactable:
		_interacting = true
	
	if Input.is_action_just_released("Interact"):
		_interacting = false
		
	if _interacting and _active_interactable:
		_interacting = false
		_active_interactable.trigger_interaction()


func pause_controls():
	_controls_locked = true
	recticle.visible = false


func resume_controls():
	_controls_locked = false
	recticle.visible = true
