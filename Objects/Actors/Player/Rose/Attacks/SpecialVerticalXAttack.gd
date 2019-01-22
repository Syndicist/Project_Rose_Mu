extends "./Attack.gd"

func _ready():
	$WindupTimer.wait_time = wind;
	$WindupTimer.start();
	col.disabled = true;
	visible = false;
	pass;

func _physics_process(delta):
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

func _on_AttackTimer_timeout():
	queue_free();
	host.vspd = 0;
	attack_state.get_node("RecoilTimer").wait_time = recoil;
	attack_state.get_node("RecoilTimer").start();
	attack_state.mid = false;
	attack_state.dashing = false;
	pass;


func _on_WindupTimer_timeout():
	col.disabled = false;
	visible = true;
	$AttackTimer.wait_time = attack;
	$AttackTimer.start();
	attack_state.dashing = true;
	host.vspd = -speed;
	host.hspd = 0;
	host.fspd = 0;
	pass;
