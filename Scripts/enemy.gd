extends CharacterBody3D

@export var SPEED = 10.0
const ATTACK_RANGE = 2.0

var player = null
var state_machine

@export var player_path : NodePath

@onready var navigation_agent = $NavigationAgent3D
@onready var animation_tree = $AnimationTree

func _ready():
	player = get_node(player_path)
	state_machine = animation_tree.get("parameters/playback")
	
func _process(delta):
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"Run":
			#region Navigation
			navigation_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = navigation_agent.get_next_path_position()
			velocity = (next_nav_point- global_transform.origin) * SPEED  
			look_at(Vector3(player.global_position.x + velocity.x , global_position.y, player.global_position.z + velocity.z), Vector3.UP)
			#endregionsasdw
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			

	#region Conditions
	animation_tree.set("parameters/conditions/attack", _target_in_range());
	animation_tree.set("parameters/conditions/run", !_target_in_range());
	#endregion
	
	
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

