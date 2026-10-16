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

	if (
		profile.randomize_inversion
		and randomizer.randf() < profile.inversion_probability
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
