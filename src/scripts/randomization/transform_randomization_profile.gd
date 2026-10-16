class_name TransformRandomizationProfile
extends Resource


@export_group("Position")
@export var randomize_position: bool = false
@export var position_variation: Vector3 = Vector3.ZERO

@export_group("Rotation")
@export var randomize_rotation: bool = false
@export var rotation_variation_degrees: Vector3 = Vector3.ZERO

@export_group("Inversion")
@export var randomize_inversion: bool = false
@export var inversion_rotation_degrees: Vector3 = Vector3(0.0, 180.0, 0.0)
@export_range(0.0, 1.0, 0.01) var inversion_probability: float = 0.5
## Local-space point that remains fixed while inversion is applied.
@export var inversion_pivot: Vector3 = Vector3.ZERO
