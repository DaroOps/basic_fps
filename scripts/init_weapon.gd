@tool

class_name WeaponController extends Node3D

@export var WEAPON_TYPE : Weapons
	#set(value):
		#if WEAPON_TYPE:
			#WEAPON_TYPE = value
			#load_weapon()

@onready var weapon_mesh : MeshInstance3D = %WeaponMesh


@export var sway_noise : NoiseTexture2D
@export var sway_speed : float = 1.2
@export var reset : bool = false:
	set(value):
		reset = value
		if(Engine.is_editor_hint()):
			load_weapon()

@onready var mouse_movement : Vector2

var random_sway_x
var random_sway_y

var random_sway_amount : float
var time : float = 0.0
var idle_sway_adjustment
var idle_sway_rotation_strength

var weapon_bob_amount : Vector2 = Vector2(0,0) 

var decal = preload ("res://scenes/decal.tscn")

func _input(event):
	if event is InputEventMouseMotion:
		mouse_movement = event.relative

func _ready() -> void:
	load_weapon()

func load_weapon() -> void:
	if WEAPON_TYPE:
		weapon_mesh.mesh = WEAPON_TYPE.mesh
		position = WEAPON_TYPE.position
		rotation_degrees = WEAPON_TYPE.rotation
		
		idle_sway_adjustment = WEAPON_TYPE.idle_sway_adjustement
		idle_sway_rotation_strength = WEAPON_TYPE.idle_sway_rotation_strength
		random_sway_amount = WEAPON_TYPE.random_sway_amount

func sway_weapon(delta, isIdle : bool) -> void:

	if WEAPON_TYPE :
		mouse_movement = mouse_movement.clamp(WEAPON_TYPE.sway_min, WEAPON_TYPE.sway_max)
		
		if isIdle:
			var sway_random : float = get_sway_noise()
			var sway_random_adjusted : float = sway_random * idle_sway_adjustment
			
			time += delta * (sway_speed + sway_random)
			random_sway_x = sin(time * 1.5 + sway_random_adjusted) / random_sway_amount
			random_sway_y = sin(time - sway_random_adjusted) / random_sway_amount
			
			#region Position Lerp
			position.x = lerp(position.x, WEAPON_TYPE.position.x - (mouse_movement.x * 
			WEAPON_TYPE.sway_amount_position + random_sway_x) * delta, WEAPON_TYPE.sway_speed_position)
			
			position.y = lerp(position.y, WEAPON_TYPE.position.y - (mouse_movement.y * 
			WEAPON_TYPE.sway_amount_position+ random_sway_y) * delta, WEAPON_TYPE.sway_speed_position)
			#endregion
			
			#region Rotation Lerp
			rotation_degrees.y = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y + (mouse_movement.x *
			WEAPON_TYPE.sway_amount_rotation + (random_sway_y * idle_sway_rotation_strength)) * delta, WEAPON_TYPE.sway_speed_rotation)
			
			rotation_degrees.x = lerp(rotation_degrees.x, WEAPON_TYPE.rotation.x + (mouse_movement.y *
			WEAPON_TYPE.sway_amount_rotation+ (random_sway_x * idle_sway_rotation_strength)) * delta, WEAPON_TYPE.sway_speed_rotation)
			#endregion
		else:
			#region Position Lerp
			position.x = lerp(position.x, WEAPON_TYPE.position.x - (mouse_movement.x * 
			WEAPON_TYPE.sway_amount_position + weapon_bob_amount.x) * delta, WEAPON_TYPE.sway_speed_position)
			
			position.y = lerp(position.y, WEAPON_TYPE.position.y - (mouse_movement.y * 
			WEAPON_TYPE.sway_amount_position + weapon_bob_amount.y) * delta, WEAPON_TYPE.sway_speed_position)
			#endregion
			
			#region Rotation Lerp
			rotation_degrees.y = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y + (mouse_movement.x *
			WEAPON_TYPE.sway_amount_rotation ) * delta, WEAPON_TYPE.sway_speed_rotation)
			
			rotation_degrees.x = lerp(rotation_degrees.x, WEAPON_TYPE.rotation.x + (mouse_movement.y *
			WEAPON_TYPE.sway_amount_rotation) * delta, WEAPON_TYPE.sway_speed_rotation)
			#endregion

func get_sway_noise() -> float:
	var player_position : Vector3 = Vector3(0,0,0)
	
	if not Engine.is_editor_hint():
		player_position = Global.player.global_position
	
	var noise_location : float = sway_noise.noise.get_noise_2d(player_position.x, player_position.y)
	
	return noise_location

func _weapon_bob(delta, bob_speed: float, h_bob_amount: float, v_bob_amount: float) -> void:
	if time:
		time += delta
		
		weapon_bob_amount.x = sin(time*bob_speed) * h_bob_amount
		weapon_bob_amount.y = abs(cos(time*bob_speed) * v_bob_amount)
	

func _shoot() -> void:
	var camera = Global.player.CAMERA_CONTROLLER
	var space_state = camera.get_world_3d().direct_space_state
	var scree_center  = get_viewport().size / 2
	var origin  = camera.project_ray_origin(scree_center)
	var end = origin + camera.project_ray_normal(scree_center) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	
	query.collide_with_bodies = true

	#intersect ray need to be modified if the object its too large
	var result = space_state.intersect_ray(query)
	print(result)
	if result:
		_test_raycat(result.get("position"))
	
func _test_raycat(pos: Vector3) -> void:
	var instance = decal.instantiate()
	
	get_tree().root.add_child(instance)
	instance.global_position = pos
	await get_tree().create_timer(3.0).timeout
	instance.queue_free()
