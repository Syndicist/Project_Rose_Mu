extends "res://Objects/Actors/Player/Rose/AttackObjects/XAttack.gd"

func _physics_process(delta):
	displacey();
	print(host.vspd);

func _on_AttackTimer_timeout():
	._on_AttackTimer_timeout();
	host.vspd = 0;
	if(!host.on_floor()):
		attack_state.floating = true;
		attack_state.get_node("FloatTimer").wait_time = fl;
		attack_state.get_node("FloatTimer").start();
		host.vspd = -50;
	attack_state.get_node("RecoilTimer").wait_time = recoil;
	attack_state.get_node("RecoilTimer").start();
	attack_state.dashing = false;
	pass;


func _on_WindupTimer_timeout():
	._on_WindupTimer_timeout();
	attack_state.dashing = true;
	host.vspd = -speedy;
	host.hspd = 0;
	pass;
