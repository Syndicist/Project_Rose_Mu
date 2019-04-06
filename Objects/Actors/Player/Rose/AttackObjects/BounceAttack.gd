extends "res://Objects/Actors/Player/Rose/AttackObjects/DontMoveAttack.gd"

func _ready():
	attack_traversal.x = 32;
	attack_traversal.y = 16;
	pass;

func _physics_process(delta):
	displacex();
	displacey();
	pass;

func _on_AttackTimer_timeout():
	._on_AttackTimer_timeout();
	attack_state.get_node("RecoilTimer").wait_time = recoil;
	attack_state.get_node("RecoilTimer").start();
	attack_state.dashing = false;
	pass;

func on_area_entered(area):
	.on_area_entered(area);
	host.hspd = speedx * host.Direction * mDir;
	host.vspd = -speedy;
	pass;