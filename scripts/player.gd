class_name  Player extends CharacterBody3D

@export var WEAPON_CONTROLLER : WeaponController
@export var CAMERA_CONTROLLER : Camera3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.8
const SENSITIVITY = 0.004
const  HIT_STAGER = 8.0
const ACCELERAION : float = 0.1
const DECELRATION : float = 0.25

#bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

#signal
signal player_hit

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D
#@onready var gun_anim =$Head/Camera3D/WeaponRig/Weapon/AnimationPlayer
@onready var weapon_barrel = $Head/Camera3D/WeaponRig/Weapon

var bullet = load("res://scenes/bullet.tscn")
var instance 


func _ready():
	Global.player = self
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _unhandled_input(event):
	
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func update_velocity() -> void:
	Global.debug.add_property("Current Velocity" , velocity.length(), 2)
	move_and_slide()

func update_gravity(delta) -> void:
		velocity.y -= gravity * delta


func update_input() -> void:
	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = lerp(velocity.x, direction.x * speed, ACCELERAION)
			velocity.z = lerp(velocity.z, direction.z * speed, ACCELERAION)
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, DECELRATION)
			velocity.z = lerp(velocity.z, direction.z * speed, DECELRATION)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, DECELRATION)
		velocity.z = lerp(velocity.z, direction.z * speed, DECELRATION)
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		pass
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	#Shooting
	if Input.is_action_pressed("shoot"):
		pass
		#if  !gun_anim.is_playing():
			#gun_anim.play("Shoot")
			#instance = bullet.instantiate()
			#instance.position = weapon_barrel.global_position
			#instance.transform.basis = weapon_barrel.global_transform.basis
			#get_parent().add_child(instance)
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func hit(dir):
	emit_signal("player_hit")
	velocity =+ dir * HIT_STAGER
	velocity.y = 0
