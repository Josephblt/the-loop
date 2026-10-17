class_name TransformRandomizer
extends RefCounted


static func generate(authored_position: Vector3, authored_rotation: Vector3, profile: TransformRandomizationProfile, seed: int, identity: String ) -> TransformRandomizationState:
	var randomizer: RandomNumberGenerator = RandomNumberGenerator.new()
	randomizer.seed = hash([seed, identity])

	var position: Vector3 = authored_position
	var rotation: Vector3 = authored_rotation

	if profile.randomize_position:
		var pos_x: float = randomizer.randf_range(-profile.position_variation.x, profile.position_variation.x)
		var pos_y: float = randomizer.randf_range(-profile.position_variation.y, profile.position_variation.y)
		var pos_z: float = randomizer.randf_range(-profile.position_variation.z, profile.position_variation.z)
		position += Vector3(pos_x, pos_y, pos_z)

	if profile.randomize_rotation:
		var rot_x: float = deg_to_rad(randomizer.randf_range(-profile.rotation_variation_degrees.x, profile.rotation_variation_degrees.x))
		var rot_y: float = deg_to_rad(randomizer.randf_range(-profile.rotation_variation_degrees.y, profile.rotation_variation_degrees.y))
		var rot_z: float = deg_to_rad(randomizer.randf_range(-profile.rotation_variation_degrees.z, profile.rotation_variation_degrees.z))
		rotation += Vector3(rot_x, rot_y, rot_z)

	if profile.randomize_rotation_in_steps:
		var step_rot_x: float = deg_to_rad(_get_random_rotation_step(randomizer, profile.rotation_step_degrees.x))
		var step_rot_y: float = deg_to_rad(_get_random_rotation_step(randomizer, profile.rotation_step_degrees.y))
		var step_rot_z: float = deg_to_rad(_get_random_rotation_step(randomizer, profile.rotation_step_degrees.z))
		rotation += Vector3(step_rot_x, step_rot_y, step_rot_z)

	if (profile.randomize_inversion and randomizer.randi_range(0, 1) == 1):
		var rotation_before_inversion: Vector3 = rotation
		var rad_x: float = deg_to_rad(profile.inversion_rotation_degrees.x)
		var rad_y: float = deg_to_rad(profile.inversion_rotation_degrees.y)
		var rad_z: float = deg_to_rad(profile.inversion_rotation_degrees.z)
		rotation += Vector3(rad_x, rad_y, rad_z)
		position += _get_pivot_correction(rotation_before_inversion, rotation, profile.inversion_pivot)

	return TransformRandomizationState.new(position, rotation)


static func recover_base(randomized_position: Vector3, randomized_rotation: Vector3, profile: TransformRandomizationProfile, seed: int, identity: String) -> TransformRandomizationState:
	var zero_state: TransformRandomizationState = generate(Vector3.ZERO, Vector3.ZERO, profile, seed, identity)
	var base_rotation: Vector3 = randomized_rotation - zero_state.rotation
	var offset_state: TransformRandomizationState = generate(Vector3.ZERO, base_rotation, profile, seed, identity)
	return TransformRandomizationState.new(randomized_position - offset_state.position, base_rotation)


static func _get_random_rotation_step(randomizer: RandomNumberGenerator, step_degrees: float) -> float:
	var step_magnitude: float = absf(step_degrees)
	if is_zero_approx(step_magnitude):
		return 0.0

	var step_count: int = maxi(1, ceili(360.0 / step_magnitude))
	var step_index: int = randomizer.randi_range(0, step_count - 1)
	return step_degrees * float(step_index)


static func _get_pivot_correction(rotation_before: Vector3,rotation_after: Vector3,pivot: Vector3) -> Vector3:
	if pivot.is_zero_approx():
		return Vector3.ZERO

	var basis_before: Basis = Basis.from_euler(rotation_before)
	var basis_after: Basis = Basis.from_euler(rotation_after)
	return basis_before * pivot - basis_after * pivot
