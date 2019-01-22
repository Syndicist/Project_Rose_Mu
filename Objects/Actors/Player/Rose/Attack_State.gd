extends "./Free_Motion_State.gd"

var combo_step = 0;
var first_attack = 'nil';
var second_attack = 'nil';
var third_attack = 'nil';
var combo_attack = 'nil';
var current_attack = 'nil';
var pierce_enabled = false;
var bash_enabled = false;
#starting the attack
var start = false;
#middle of the attack
var mid = false;
var special = "";
var dir = "";
var on_cooldown = false;
var interrupt = 1;
var distance_traversable = 80;
var dashing = false;
var combo_start = false;

func enter():
	host.state = 'attack';
	combo_start = true;
	handleInput(Input);
	pass;

func handleInput(event):
	if(!$InterruptTimer.is_stopped() || combo_start):
		if(event.is_action_pressed("special") && (event.is_action_pressed("left") || event.is_action_pressed("up") || event.is_action_pressed("right"))):
			special = "Special";
			if(event.is_action_pressed("left")):
				dir = "Horizontal"
				update_look_direction(-1);
			elif(event.is_action_pressed("right")):
				dir = "Horizontal";
				update_look_direction(1);
			elif(event.is_action_pressed("up")):
				dir = "Vertical";
			else:
				special = "";
		else:
			special = "";
			dir = "";
		#if an attack is triggered, commit to it
		if(event.is_action_pressed("attack")):
			if(event.is_action_just_pressed("slash")):
				current_attack = 'X';
			elif(event.is_action_just_pressed("bash") && bash_enabled):
				current_attack = 'B';
			elif(event.is_action_just_pressed("pierce") && pierce_enabled):
				current_attack = 'Y';
			
			if(current_attack != 'nil'):
				combo_start = false;
				$InterruptTimer.stop()
				start = true;
				combo_step += 1;
		#cancel the combo
		elif(host.is_on_floor() && !event.is_action_pressed("special")):
			if(event.is_action_pressed("left") ||
			event.is_action_pressed("right") || 
			event.is_action_pressed("jump") || 
			event.is_action_pressed("down") ):
				exit('move_on_ground');
		elif(!event.is_action_pressed("special")):
			if(event.is_action_pressed("left") || event.is_action_pressed("right")):
				exit('move_in_air');
	pass;

func execute(delta):
	attack();
	#prevent player slipping
	if(host.is_on_floor() && !mid):
		host.hspd = 0;
	#combo timeout
	if(!start && !mid && $InterruptTimer.is_stopped() && $RecoilTimer.is_stopped() && !combo_start):
		if(host.is_on_floor()):
			exit('move_on_ground');
		else:
			exit('move_in_air');
		return;
	pass;

func exit(state):
	#reset
	$InterruptTimer.stop();
	combo_step = 0;
	first_attack = 'nil';
	second_attack = 'nil';
	third_attack = 'nil';
	combo_attack = 'nil';
	current_attack = 'nil';
	start = false;
	special = "";
	$CooldownTimer.wait_time = .35;
	$CooldownTimer.start();
	on_cooldown = true;
	interrupt = 1;
	distance_traversable = 80;
	dashing = false;
	.exit(state);
	pass;
	
func attack():
	if(current_attack != 'nil'):
		match(combo_step):
			1:
				first_attack = current_attack;
				combo_attack = first_attack;
			2:
				second_attack = first_attack + current_attack;
				combo_attack = second_attack;
			3:
				third_attack = second_attack + current_attack;
				combo_attack = third_attack;
			4:
				if(host.is_on_floor()):
					exit('move_on_ground');
				else:
					exit('move_in_air');
				return;
		if ((combo_step in [1,2,3]) && start):
			print(special + combo_attack);
			start = false;
			mid = true;
			var path = "res://Objects/Actors/Player/Rose/Attacks/" + special + dir + combo_attack + "Attack.tscn"
			special = "";
			dir = "";
			current_attack = 'nil';
			var effect = load(path).instance();
			effect.host = host;
			effect.attack_state = self;
			host.add_child(effect);
	pass;

func _on_CooldownTimer_timeout():
	on_cooldown = false;
	pass;


func _on_RecoilTimer_timeout():
	$InterruptTimer.wait_time = interrupt;
	$InterruptTimer.start();
	pass;
