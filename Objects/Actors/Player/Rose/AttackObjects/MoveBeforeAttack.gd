extends "./MoveAttack.gd"

func initialize():
	.initialize();
	host.hspd = speedx * host.Direction;
	host.vspd = speedy * vDirection;
	pass;

