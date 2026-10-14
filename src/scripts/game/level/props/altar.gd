extends StaticBody3D


@onready var fire: Fire = %Fire


func ignite_fire() -> void:
	fire.ignite()


func extinguish_fire() -> void:
	fire.extinguish()
