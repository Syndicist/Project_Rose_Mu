extends "./Free_Motion_State.gd"

### temp inits ###
var combo_step = 0;
var first_attack = 'nil';
var second_attack = 'nil';
var third_attack = 'nil';
var combo_attack = 'nil';
var current_attack = 'nil';
#starting the attack
var start = false;
#middle of the attack
var mid = false;
var special = "";
var dir = "";
var place = "";
var on_cooldown = false;
var dashing = false;
var combo_start = false;

### modifiable inits ###
var cont = .5;
var interrupt = .5;
var distance_traversable = 80;
var air_counter = 1;

### item_vars ###
var pierce_enabled = false;
var bash_enabled = false;

func enter():
	host.state = 'attack';
	combo_start = true;
	handleInput(Input);
	pass;

func handleInput(event):
	if(air_counter <= 0 && !$InterruptTimer.is_stopped()):
		if(host.is_on_floor()):
			exit('move_on_ground');
		else:
			exit('move_in_air');
		return;
	if(!$InterruptTimer.is_stopped() || combo_start || !$ContinueComboTimer.is_stopped()):
		if(event.is_action_pressed("left")):
			dir = "Horizontal"
			update_look_direction(-1);
		elif(event.is_action_pressed("right")):
			dir = "Horizontal";
			update_look_direction(1);
		elif(event.is_action_pressed("up")):
			dir = "Up";
		elif(event.is_action_pressed("down")):
			dir = "Down";
		if(event.is_action_pressed("special")):
			special = "Special";
		else:
			special = "";
			dir = "Horizontal";
		if(host.is_on_floor()):
			place = "Ground";
		else:
			place = "Air";
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
		elif(!$ContinueComboTimer.is_stopped() && !event.is_action_pressed("special")):
			if(host.is_on_floor() && (
			event.is_action_pressed("jump") ||
			event.is_action_pressed("left") ||
			event.is_action_pressed("right"))):
				exit('move_on_ground');
			elif(
			event.is_action_pressed("left") ||
			event.is_action_pressed("right")):
				exit('move_in_air');
	#combo timeout
	if(!start && !mid && $InterruptTimer.is_stopped() && ($RecoilTimer.is_stopped() || air_counter <= 0) && !combo_start):
		if(host.is_on_floor()):
			exit('move_on_ground');
		else:
			exit('move_in_air');
		return;
	pass;

func execute(delta):
	attack();
	#prevent player slipping
	if(host.is_on_floor() && !mid):
		host.hspd = 0;
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
	pierce_enabled = false;
	bash_enabled = false;
	start = false;
	mid = false;
	special = "";
	dir = "";
	place = "";
	on_cooldown = false;
	dashing = false;
	combo_start = false;
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
		if ((combo_step in [1,2,3]) && current_attack != 'nil'):
			if(place == "Air"):
				air_counter -= 1;
				if(dir == "Up"): #TODO: enable once double jump is unlocked
					special = "";
			var path = "res://Objects/Actors/Player/Rose/AttackObjects/" + special + "Attacks/" + dir + "/" + place + "/" + combo_attack + "Attack.tscn"
			special = "";
			dir = "";
			place = "";
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


func _on_InterruptTimer_timeout():
	$ContinueComboTimer.wait_time = cont;
	$ContinueComboTimer.start();
	pass;
