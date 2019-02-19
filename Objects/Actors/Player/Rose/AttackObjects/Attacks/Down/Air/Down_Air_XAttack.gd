extends "res://Objects/Actors/Player/Rose/AttackObjects/Attack.gd"

#For Down-Directional X Air Attacks
func _ready():
	attack_traversal.x = 32;
	attack_traversal.y = 16;
	speedx = host.mspd;
	speedy = host.jspd/2;
	pass;

func _physics_process(delta):
	displacex();
	displacex();
	pass;

func _on_AttackTimer_timeout():
	queue_free();
	attack_state.get_node("RecoilTimer").wait_time = recoil;
	attack_state.get_node("RecoilTimer").start();
	attack_state.attack_mid = false;
	attack_state.dashing = false;
	pass;


func _on_WindupTimer_timeout():
	._on_WindupTimer_timeout();
	pass;

func on_area_entered(area):
	.on_area_entered(area);
	host.hspd = speedx * host.Direction;
	host.vspd = -speedy;
	pass;