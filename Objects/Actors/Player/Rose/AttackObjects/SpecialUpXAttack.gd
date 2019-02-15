extends "./Attack.gd"

func _physics_process(delta):
	displacey();
	print(host.vspd);

func _on_AttackTimer_timeout():
	queue_free();
	host.vspd = 0;
	if(!host.is_on_floor()):
		attack_state.floating = true;
		attack_state.get_node("FloatTimer").wait_time = fl;
		attack_state.get_node("FloatTimer").start();
		host.vspd = -50;
	attack_state.get_node("RecoilTimer").wait_time = recoil;
	attack_state.get_node("RecoilTimer").start();
	attack_state.attack_mid = false;
	attack_state.dashing = false;
	pass;


func _on_WindupTimer_timeout():
	._on_WindupTimer_timeout();
	attack_state.dashing = true;
	host.vspd = -speedy;
	host.hspd = 0;
	host.fspd = 0;
	pass;
