class_name WalkingPlayerState extends PlayerMovementState

@export var WEAPON_BOB_SPEED : float = 6.0
@export var WEAPON_BOB_H : float = 2.0
@export var WEAPON_BOB_V : float = 1.0

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input()
	PLAYER.update_velocity()
	
	WEAPON.sway_weapon(delta, false)
	WEAPON._weapon_bob(delta, WEAPON_BOB_SPEED,  WEAPON_BOB_H, WEAPON_BOB_V)
	
	if PLAYER.velocity.length() == 0:
		transition.emit("IdlePlayerState")
	
	if Input.is_action_pressed("sprint") and PLAYER.velocity.length() > 0.0:
		transition.emit("SprintingPlayerState")

#func _input(event):
	#
