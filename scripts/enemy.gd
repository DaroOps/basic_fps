extends CharacterBody3D

@export var initial_speed = 0.0 
@export var max_speed = 10.0
@export var acceleration_rate = 5.0

var current_speed = initial_speed

@export var health = 10

const ROTATION_SPEED = 9.0
const ATTACK_RANGE = 2.0
const DETECTION_RANGE = 6.0
const EXTRA_RANGE = 1.0

var player = null
var state_machine

#var player_path = null

@onready var navigation_agent = $NavigationAgent3D
@onready var animation_tree = $AnimationTree

func _ready():
	#player_path = 
	#print(player_path.get_path())
	player = get_tree().get_nodes_in_group("players")[0]
	state_machine = animation_tree.get("parameters/playback")
	
func _physics_process(delta):
	velocity = Vector3.ZERO
	
	
	
	match state_machine.get_current_node():
		"Scream":
			#look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			var target_pos = Vector3(player.global_position.x, global_position.y, player.global_position.z)
			var new_transform = transform.looking_at(target_pos, Vector3.UP)
			transform = transform.interpolate_with(new_transform , ROTATION_SPEED/2 * delta)
			
		#"IdleToRun":
			#rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * ROTATION_SPEED)
		"Run":
			#region Navigation
			var next_nav_point = navigation_agent.get_next_path_position()
			current_speed = min(current_speed + acceleration_rate, max_speed)
			navigation_agent.set_target_position(player.global_transform.origin)
			velocity = (next_nav_point - global_transform.origin).normalized() * current_speed
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * ROTATION_SPEED)
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

func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + EXTRA_RANGE:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)
	


func _on_area_3d_body_part_hit(dmg):
	health -= dmg
	print("hit area")
	print(health)
	if health <= 0:
		queue_free()
	


func _on_collision_shape_3d_visibility_changed():
	pass # Replace with function body.
