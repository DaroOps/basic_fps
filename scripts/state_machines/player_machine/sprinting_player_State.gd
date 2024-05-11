class_name SprintingPlayerState extends PlayerMovementState

@export var WEAPON_BOB_SPEED : float = 8.0
@export var WEAPON_BOB_H : float = 3.0
@export var WEAPON_BOB_V : float = 2.0

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input()
	PLAYER.update_velocity()
	
	WEAPON.sway_weapon(delta, false)
	WEAPON._weapon_bob(delta, WEAPON_BOB_SPEED,  WEAPON_BOB_H, WEAPON_BOB_V)
	
	if Input.is_action_just_released("sprint"):
		transition.emit("WalkingPlayerState")


#func _input(event):
	#
