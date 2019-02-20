extends "./Attack.gd"

#For horizontal X attacks that trigger a set displacement

func _ready():
	initialize();
	pass;
	
func initialize():
	speedx = host.mspd;
	pass;

func _physics_process(delta):
	displacex();

func _on_AttackTimer_timeout():
	queue_free();
	host.hspd = 0;
	if(!host.on_floor()):
		attack_state.floating = true;
		attack_state.get_node("FloatTimer").wait_time = fl;
		attack_state.get_node("FloatTimer").start();
		host.hspd = 50 * host.Direction;
	attack_state.get_node("RecoilTimer").wait_time = recoil;
	attack_state.get_node("RecoilTimer").start();
	attack_state.attack_mid = false;
	attack_state.dashing = false;
	attack_state.attack_end = true;
	print(attack_state.attack_end);
	pass;


func _on_WindupTimer_timeout():
	host.hspd = 0;
	._on_WindupTimer_timeout();
	attack_state.dashing = true;
	host.hspd += speedx * host.Direction;
	host.vspd = 0;
	pass;
