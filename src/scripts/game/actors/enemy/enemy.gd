class_name Enemy
extends GPUParticles3D


func appear() -> void:
	print("Enemy appearing:" + str(emitting))
	emitting = true
	print("Enemy appeared:" + str(emitting))


func disappear() -> void:
	print("Enemy disappearing:" + str(emitting))
	emitting = false
	print("Enemy disappeared:" + str(emitting))
