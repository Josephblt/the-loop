class_name TransformRandomizer
extends RefCounted


## Generates an absolute transform state without mutating a scene node.
static func generate(
	authored_position: Vector3,
	authored_rotation: Vector3,
	profile: TransformRandomizationProfile,
	seed: int,
	identity: String
) -> TransformRandomizationState:
	var randomizer: RandomNumberGenerator = RandomNumberGenerator.new()
	randomizer.seed = hash([seed, identity])

	var position: Vector3 = authored_position
	var rotation: Vector3 = authored_rotation

	if profile.randomize_position:
		position += Vector3(
			randomizer.randf_range(
				-profile.position_variation.x,
				profile.position_variation.x
			),
			randomizer.randf_range(
				-profile.position_variation.y,
				profile.position_variation.y
			),
			randomizer.randf_range(
				-profile.position_variation.z,
				profile.position_variation.z
			)
		)

	if profile.randomize_rotation:
		rotation += Vector3(
			deg_to_rad(randomizer.randf_range(
				-profile.rotation_variation_degrees.x,
				profile.rotation_variation_degrees.x
			)),
			deg_to_rad(randomizer.randf_range(
				-profile.rotation_variation_degrees.y,
				profile.rotation_variation_degrees.y
			)),
			deg_to_rad(randomizer.randf_range(
				-profile.rotation_variation_degrees.z,
				profile.rotation_variation_degrees.z
			))
		)

	if profile.randomize_rotation_in_steps:
		rotation += Vector3(
			deg_to_rad(_get_random_rotation_step(
				randomizer,
				profile.rotation_step_degrees.x
			)),
			deg_to_rad(_get_random_rotation_step(
				randomizer,
				profile.rotation_step_degrees.y
			)),
			deg_to_rad(_get_random_rotation_step(
				randomizer,
				profile.rotation_step_degrees.z
			))
		)

	if (
		profile.randomize_inversion
		and randomizer.randi_range(0, 1) == 1
	):
		var rotation_before_inversion: Vector3 = rotation
		rotation += Vector3(
			deg_to_rad(profile.inversion_rotation_degrees.x),
			deg_to_rad(profile.inversion_rotation_degrees.y),
			deg_to_rad(profile.inversion_rotation_degrees.z)
		)
		position += _get_pivot_correction(
			rotation_before_inversion,
			rotation,
			profile.inversion_pivot
		)

	return TransformRandomizationState.new(position, rotation)


static func _get_random_rotation_step(
	randomizer: RandomNumberGenerator,
	step_degrees: float
) -> float:
	var step_magnitude: float = absf(step_degrees)
	if is_zero_approx(step_magnitude):
		return 0.0

	var step_count: int = maxi(1, ceili(360.0 / step_magnitude))
	var step_index: int = randomizer.randi_range(0, step_count - 1)
	return step_degrees * float(step_index)


static func _get_pivot_correction(
	rotation_before: Vector3,
	rotation_after: Vector3,
	pivot: Vector3
) -> Vector3:
	if pivot.is_zero_approx():
		return Vector3.ZERO

	var basis_before: Basis = Basis.from_euler(rotation_before)
	var basis_after: Basis = Basis.from_euler(rotation_after)
	return basis_before * pivot - basis_after * pivot
