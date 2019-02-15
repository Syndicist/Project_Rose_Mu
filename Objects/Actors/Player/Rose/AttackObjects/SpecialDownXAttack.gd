extends "./Attack.gd"

func _ready():
	host.hspd = 0;

func _physics_process(delta):
	impact();

func impact():
	if(host.is_on_floor()):
		queue_free();
		#todo: create impact
		host.vspd = 0;
		attack_state.get_node("RecoilTimer").wait_time = recoil;
		attack_state.get_node("RecoilTimer").start();
		attack_state.attack_mid = false;
		attack_state.attack_dashing = false;

func _on_WindupTimer_timeout():
	._on_WindupTimer_timeout();
	$AttackTimer.pause();
	col.disabled = false;
	visible = true;
	attack_state.dashing = true;
	host.vspd = speed;
	
	pass;