extends "./State.gd"

var combo_step = 0;
var first_attack = 'nil';
var second_attack = 'nil';
var third_attack = 'nil';
var combo_attack = 'nil';
var current_attack = 'nil';
var pierce_enabled = false;
var bash_enabled = false;
var start = false;
var mid = false;
var special = "";

func enter():
	host.state = 'attack';
	$InterruptTimer.wait_time = 1;
	$InterruptTimer.start();
	handleInput(Input);
	pass;

func handleInput(event):
	if(!$InterruptTimer.is_stopped()):
		if(event.is_action_pressed("special")):
			special = "Special";
		else:
			special = "";
		if(event.is_action_just_pressed("attack")):
			if(event.is_action_just_pressed("slash")):
				current_attack = 'X';
			elif(event.is_action_just_pressed("bash") && bash_enabled):
				current_attack = 'B';
			elif(event.is_action_just_pressed("pierce") && pierce_enabled):
				current_attack = 'Y';
			
			if(current_attack != 'nil'):
				$InterruptTimer.stop()
				start = true;
				combo_step += 1;
		elif(host.is_on_floor()):
			if(event.is_action_pressed("left") ||
			event.is_action_pressed("right") || 
			event.is_action_pressed("jump") || 
			event.is_action_pressed("down") ):
				exit('move_on_ground');
		else:
			if(event.is_action_pressed("left") || event.is_action_pressed("right")):
				exit('move_in_air');
	pass;

func execute(delta):
	attack();
	if(host.is_on_floor() && !mid):
		host.hspd = 0;
	if(!start && !mid && $InterruptTimer.is_stopped()):
		if(host.is_on_floor()):
			exit('move_on_ground');
		else:
			exit('move_in_air');
		return;
	pass;

func exit(state):
	$InterruptTimer.stop();
	combo_step = 0;
	first_attack = 'nil';
	second_attack = 'nil';
	third_attack = 'nil';
	combo_attack = 'nil';
	current_attack = 'nil';
	start = false;
	special = "";
	#$CooldownTimer.wait_time = .35;
	#$CooldownTimer.start();
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
			var path = "res://Objects/Actors/Player/Rose/Attacks/" + special + combo_attack + "Attack.tscn"
			special = ""
			current_attack = 'nil';
			var effect = load(path).instance();
			effect.host = host;
			effect.attack_state = self;
			host.add_child(effect);
	pass;