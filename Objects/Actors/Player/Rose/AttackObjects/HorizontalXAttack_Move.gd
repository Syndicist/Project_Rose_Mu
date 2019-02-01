extends "./Attack.gd"

#For X attacks that trigger a set displacement

func _physics_process(delta):
	displacex();

func _on_AttackTimer_timeout():
	queue_free();
	if(attack_state.hit && !host.is_on_floor()):
		attack_state.floating = true;
		attack_state.get_node("FloatTimer").wait_time = 1;
		attack_state.get_node("FloatTimer").start();
	host.hspd = 0;
	attack_state.get_node("RecoilTimer").wait_time = recoil;
	attack_state.get_node("RecoilTimer").start();
	attack_state.mid = false;
	attack_state.dashing = false;
	pass;


func _on_WindupTimer_timeout():
	host.hspd = 0;
	._on_WindupTimer_timeout();
	attack_state.dashing = true;
	host.hspd += speed * host.Direction;
	host.vspd = 0;
	host.fspd = 0;
	pass;
