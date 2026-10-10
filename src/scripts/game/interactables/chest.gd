class_name Chest
extends Node3D

const CHEST_SCENE_PATH = "res://game/interactables/chest.tscn"

@onready var chest_animations = %ChestAnimations
@onready var interaction_animations = %InteractionAnimations
@onready var memory_animations = %MemoryAnimations

@onready var interaction_label = %LabelInteraction
@onready var memory_label = %LabelMemory

var memories_stack: MemoriesStack

var is_interactable: bool = true
var is_interaction_visible: bool = false

func _ready() -> void:
	memories_stack = MemoriesStack.new(GameManager.current_game_session.session_seed)
	memories_stack.load_grief_stack(GriefStagesStack.GriefStages.values().pick_random())
	

func _open_chest():
	chest_animations.play("open_chest")	
	

func _show_interaction():
	if is_interaction_visible:
		return
	interaction_animations.play("show_interaction")
	is_interaction_visible = true


func _hide_interaction():
	if not is_interaction_visible:
		return
	interaction_animations.play("hide_interaction")
	is_interaction_visible = false


func _show_memory():
	memory_label.text = memories_stack.pop()
	memory_animations.play("show_memory")


func _hide_memory():
	memory_animations.play("hide_memory")


func interact():
	if not is_interactable:
		return

	is_interactable = false
	_hide_interaction()
	_open_chest()
	_show_memory()


static func create(game_session: GameSession) -> Chest:
	var chest: Chest = preload(CHEST_SCENE_PATH).instantiate()
	chest.memories_stack = game_session._memories_stack
	return chest