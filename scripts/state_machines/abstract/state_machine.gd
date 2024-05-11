class_name StateMachine extends Node

@export var CURRENT_STATE : State
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition.connect(on_child_transistion)
		else:
			push_warning("State machine contains incompatible child node")
	await owner.ready
	CURRENT_STATE.enter()

func _process(delta):
	CURRENT_STATE.update(delta)
	Global.debug.add_property("Current Player State", CURRENT_STATE.name, 2)

func _physics_process(delta):
	CURRENT_STATE.physics_update(delta)
	
func on_child_transistion(new_state_name: StringName) -> void:
	var new_state = states.get(new_state_name)
	if new_state:
		if new_state != CURRENT_STATE:
			CURRENT_STATE.exit()
			new_state.enter()
			CURRENT_STATE = new_state
	else:
		push_warning("State doesn't exist")

