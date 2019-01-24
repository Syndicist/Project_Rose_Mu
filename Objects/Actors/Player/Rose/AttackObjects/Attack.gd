extends Node2D

var host;
var attack_state;
onready var col = get_node("collider");
export(float) var wind = .2;
export(float) var attack = .1;
export(float) var recoil = .1;
export(float) var speed = 200;
onready var pos = host.position;
var displacement = Vector2(0,0);

func _ready():
	$WindupTimer.wait_time = wind;
	$WindupTimer.start();
	col.disabled = true;
	visible = false;
	pass;

func displacex():
	if(host.position.x > pos.x):
		displacement.x += host.position.x - pos.x;
		pos.x = host.position.x;
	elif(host.position.x < pos.x):
		displacement.x += pos.x - host.position.x;
		pos.x = host.position.x;
	if(abs(displacement.x) > attack_state.distance_traversable):
		if(host.is_on_floor()):
			host.hspd = 0;
		elif(speed > 0):
			host.hspd -= 25*host.Direction;
			speed -= 25
		attack_state.dashing = false;
	pass;

func displacey():
	if(host.position.y > pos.y):
		displacement.y += host.position.y - pos.y;
		pos.y = host.position.y;
	elif(host.position.y < pos.y):
		displacement.y += pos.y - host.position.y;
		pos.y = host.position.y;
	if(abs(displacement.y) > attack_state.distance_traversable):
		if(host.is_on_floor()):
			host.vspd = 0;
		elif(speed > 0):
			host.vspd += 25;
			speed -= 25
		attack_state.dashing = false;
	pass;

### All attacks need versions of these ###
func _on_AttackTimer_timeout():
	queue_free();
	attack_state.get_node("RecoilTimer").wait_time = recoil;
	attack_state.get_node("RecoilTimer").start();
	attack_state.mid = false;
	pass;


func _on_WindupTimer_timeout():
	col.disabled = false;
	visible = true;
	$AttackTimer.wait_time = attack;
	$AttackTimer.start();
	attack_state.mid = true;
	attack_state.start = false;
	pass;