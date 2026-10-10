class_name Player
extends CharacterBody3D


const RUN_SPEED: float = 10.0
const WALK_SPEED: float = 3.0
const SENSITIVITY: float = 0.05
const JUMP_VELOCITY: float = 10.0

@onready var camera: Camera3D = %Camera3D
@onready var raycast: RayCast3D = %RayCast3D

var look_x: float = 0.0 
var look_y: float = 0.0 
var speed: float = RUN_SPEED
var collided_interactable: Area3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED 
	look_y = rotation_degrees.y


func _physics_process(_delta: float) -> void:
	_handle_movement()
	_handle_gravity(_delta)

	move_and_slide()
	
	if position.y < 0:
		position.y = 0
	

func _input(event):
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
		speed = WALK_SPEED
	if Input.is_action_just_released("Walk"):
		speed = RUN_SPEED


func _handle_movement():
	if is_on_floor() or !is_on_floor():
		var input_dir: Vector2 = Input.get_vector("Left", "Right", "Forward", "Back")
	
		var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)


func _handle_look(motion: Vector2):
	look_y -= motion.x * SENSITIVITY
	look_x -= motion.y * SENSITIVITY
	look_x = clamp(look_x, -80, 80) 
	rotation_degrees.y = look_y 
	camera.rotation_degrees.x = look_x

	if raycast.is_colliding():		
		var collider = raycast.get_collider()
		if collider.is_in_group("chest") or collider.is_in_group("altar"):
			collided_interactable = collider
			if collided_interactable.is_interactable:
				collided_interactable._show_interaction()
	else:
		if collided_interactable:
			collided_interactable._hide_interaction()
			collided_interactable = null


func _handle_interactables():
	if Input.is_action_just_pressed("Interact") and collided_interactable:
		collided_interactable.interact()
