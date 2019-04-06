extends "res://Objects/Actors/Player/Rose/AttackObjects/MoveAttack.gd"

func _ready():
	host.hspd = 0;

func _physics_process(delta):
	#impact();
	pass;

func impact():
	if(host.on_floor()):
		queue_free();
		#todo: create impact
		host.vspd = 0;
		attack_state.get_node("RecoilTimer").wait_time = recoil;
		attack_state.get_node("RecoilTimer").start();
		attack_state.attack_mid = false;
		attack_state.dashing = false;