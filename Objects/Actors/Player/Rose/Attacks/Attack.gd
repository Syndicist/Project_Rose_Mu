extends Node2D

var host;
var attack_state;

export(float) var wait = .1;
func _ready():
	$AttackTimer.wait_time = wait;
	$AttackTimer.start();
	host.hspd = 500 * host.Direction;
	pass;

func _on_AttackTimer_timeout():
	queue_free();
	host.hspd = 0;
	attack_state.get_node("InterruptTimer").wait_time = 1;
	attack_state.get_node("InterruptTimer").start();
	attack_state.mid = false;
	pass;
