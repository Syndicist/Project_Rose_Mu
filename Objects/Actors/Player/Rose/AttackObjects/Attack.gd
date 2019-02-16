extends Node2D

var host;
var attack_state;
onready var col = get_node("collider");
export(float) var wind = .1;
export(float) var attack = .1;
export(float) var recoil = .1;
export(float) var speedx = 200;
export(float) var speedy = 200;
export(float) var fl = .6;
var pos;
var displacement = Vector2(0,0);
var attack_traversal = Vector2(0,0);

func _ready():
	connect("area_entered", self, "on_area_entered");
	$WindupTimer.wait_time = wind;
	$WindupTimer.start();
	col.disabled = true;
	visible = false;
	pos = host.position
	attack_traversal.x = attack_state.distance_traversable;
	attack_traversal.y = attack_state.distance_traversable;
	pass;

func displacex():
	if(host.position.x > pos.x):
		displacement.x += host.position.x - pos.x;
		pos.x = host.position.x;
	elif(host.position.x < pos.x):
		displacement.x += pos.x - host.position.x;
		pos.x = host.position.x;
	if((abs(displacement.x) > attack_state.distance_traversable || abs(displacement.x) > attack_traversal.x) && attack_state.dashing):
		if(host.on_floor()):
			host.hspd = 0;
		elif(speedx > 0):
			host.hspd -= 25*host.Direction;
			speedx -= 25
		attack_state.dashing = false;
	pass;

func displacey():
	if(host.position.y > pos.y):
		displacement.y += host.position.y - pos.y;
		pos.y = host.position.y;
	elif(host.position.y < pos.y):
		displacement.y += pos.y - host.position.y;
		pos.y = host.position.y;
	if((abs(displacement.y) > attack_state.distance_traversable || abs(displacement.y) > attack_traversal.y) && attack_state.dashing):
		if(host.on_floor()):
			host.vspd = 0;
		elif(speedy > 0):
			host.vspd += 25;
			speedy -= 25
		attack_state.dashing = false;
	pass;

### All attacks need versions of these ###
func _on_AttackTimer_timeout():
	queue_free();
	if(attack_state.hit && !host.on_floor()):
		host.vspd = 0;
		host.velocity.y = 0;
		attack_state.floating = true;
		attack_state.get_node("FloatTimer").wait_time = fl;
		attack_state.get_node("FloatTimer").start();
	attack_state.get_node("RecoilTimer").wait_time = recoil;
	attack_state.get_node("RecoilTimer").start();
	attack_state.attack_mid = false;
	pass;


func _on_WindupTimer_timeout():
	col.disabled = false;
	visible = true;
	$AttackTimer.wait_time = attack;
	$AttackTimer.start();
	attack_state.attack_mid = true;
	attack_state.attack_start = false;
	pass;

func on_area_entered(area):
	attack_state.hit = true;
	attack_state.air_counter = 1;
	pass;