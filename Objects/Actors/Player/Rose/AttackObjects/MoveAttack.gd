extends "./Attack.gd"

export(int) var vDirection = 1;
var post_move_threshold = 500;
var post_movement = 50;

#For horizontal X attacks that trigger a set displacement

func _ready():
	initialize();
	pass;
	
func initialize():
	pass;

func _physics_process(delta):
	displacex();
	displacey();

func _on_AttackTimer_timeout():
	._on_AttackTimer_timeout();
	host.hspd = 0;
	if(!host.on_floor()):
		attack_state.floating = true;
		attack_state.get_node("FloatTimer").wait_time = fl;
		attack_state.get_node("FloatTimer").start();
		if(speedy > 500):
			host.vspd = post_movement * vDirection;
		if(speedx > 500):
			host.hspd = post_movement * host.Direction;
	attack_state.get_node("RecoilTimer").wait_time = recoil;
	attack_state.get_node("RecoilTimer").start();
	attack_state.dashing = false;
	pass;


func _on_WindupTimer_timeout():
	host.hspd = 0;
	._on_WindupTimer_timeout();
	attack_state.dashing = true;
	if(!Input.is_action_pressed("lock") && speedx < 500):
		host.hspd += speedx * host.Direction;
	host.vspd += speedy * vDirection;
	pass;
