extends "./Attack.gd"

func _physics_process(delta):
	displacey();

func _on_AttackTimer_timeout():
	queue_free();
	host.vspd = 0;
	attack_state.get_node("RecoilTimer").wait_time = recoil;
	attack_state.get_node("RecoilTimer").start();
	attack_state.mid = false;
	attack_state.dashing = false;
	pass;


func _on_WindupTimer_timeout():
	._on_WindupTimer_timeout();
	attack_state.dashing = true;
	host.vspd = -speed;
	host.hspd = 0;
	host.fspd = 0;
	pass;
