class_name BuildNumber
extends Node

const BUILD_METADATA_PATH: String = "res://data/build_metadata.json"
const LOCAL_BUILD_NUMBER: String = "Local"

@onready var build_number_label: Label = %BuildNumber


func _ready() -> void:
	build_number_label.text = "Build " + _get_build_number()


func _get_build_number() -> String:
	if not FileAccess.file_exists(BUILD_METADATA_PATH):
		return LOCAL_BUILD_NUMBER

	var metadata_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(BUILD_METADATA_PATH))
	if not metadata_value is Dictionary:
		return LOCAL_BUILD_NUMBER

	var metadata: Dictionary = metadata_value as Dictionary
	var run_number: String = str(metadata.get("run_number", "")).strip_edges()
	if run_number.is_empty() or run_number == "Unavailable":
		return LOCAL_BUILD_NUMBER
	return "#" + run_number
