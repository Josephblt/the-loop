class_name TransformRandomizationProfile
extends Resource


@export_group("Position")
@export var randomize_position: bool = false
@export var position_variation: Vector3 = Vector3.ZERO

@export_group("Rotation")
@export_subgroup("Continuous Variation")
@export var randomize_rotation: bool = false
@export var rotation_variation_degrees: Vector3 = Vector3.ZERO

@export_subgroup("Stepped Rotation")
@export var randomize_rotation_in_steps: bool = false
@export var rotation_step_degrees: Vector3 = Vector3.ZERO

@export_group("Inversion")
@export var randomize_inversion: bool = false
@export var inversion_rotation_degrees: Vector3 = Vector3(0.0, 0.0, 0.0)
@export var inversion_pivot: Vector3 = Vector3.ZERO
