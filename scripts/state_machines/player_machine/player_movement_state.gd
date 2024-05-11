class_name PlayerMovementState extends State

var PLAYER: Player
var WEAPON : WeaponController

func _ready() -> void:
	await owner.ready
	PLAYER = owner as Player
	WEAPON = PLAYER.WEAPON_CONTROLLER
	
func _process(_delta:float) -> void:
	pass 
