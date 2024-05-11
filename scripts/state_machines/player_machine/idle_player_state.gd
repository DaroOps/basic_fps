class_name IdlePlayerState extends PlayerMovementState

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input()
	PLAYER.update_velocity()
	
	WEAPON.sway_weapon(delta, true)
	
	
	if PLAYER.velocity.length() > 0.0 and PLAYER.is_on_floor():
		transition.emit("WalkingPlayerState")

	if Input.is_action_just_pressed("shoot"):
		WEAPON._shoot()
	
