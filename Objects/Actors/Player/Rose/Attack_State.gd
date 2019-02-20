extends "./Free_Motion_State.gd"

### temp inits ###
var combo_step = 0;
var first_attack = 'nil';
var second_attack = 'nil';
var third_attack = 'nil';
var combo_attack = 'nil';
var current_attack = 'nil';
var on_cooldown = false;
var dashing = false;
var combo_end = false;
var track_input = false;
var hit = false;
var floating = false;
#starting the attack
var attack_start = false;
#middle of the attack
var attack_mid = false;
#end of the attack
var attack_end = false;
var animate = false;

### attack codes ###
var special = "";
var dir = "Horizontal";
var place = "Ground";


### modifiable inits ###
var end = .5;
var interrupt = .5;
var distance_traversable = 80;
var air_counter = 1;
var cool = .25;

### item_vars ###
var pierce_enabled = false;
var bash_enabled = false;

func enter():
	host.state = 'attack';
	if(on_cooldown):
		if(host.on_floor()):
			exit('move_on_ground');
		else:
			exit('move_in_air');
		return;
	track_input = true;
	handleInput(Input);
	pass;

func handleAnimation():
	print(attack_end);
	if(attack_end):
		print("!!!");
		if(host.on_floor()):
			if(combo_attack.length()%2 == 1):
				host.new_anim = combo_attack.substr(combo_attack.length()-1,1) + "land";
			else:
				host.new_anim = "-" + combo_attack.substr(combo_attack.length()-1,1) + "land";
			print(host.new_anim);
	pass;

func handleInput(event):
	if(air_counter <= 0 && track_input):
		if(host.on_floor()):
			exit('move_on_ground');
		else:
			exit('move_in_air');
		return;
	if(track_input):
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
		else:
			dir = "Horizontal";
		if(event.is_action_pressed("special")):
			special = "Special";
		else:
			special = "";
		if(host.on_floor()):
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
				stopTimers();
				attack_start = true;
				combo_step += 1;
				attack_end = false;
		#cancel the combo
		elif(track_input && event.is_action_pressed("end_combo")):
			if(host.on_floor() && (
			event.is_action_pressed("jump") ||
			event.is_action_pressed("left") ||
			event.is_action_pressed("right"))):
				exit('move_on_ground');
			elif(
			event.is_action_pressed("left") ||
			event.is_action_pressed("right")):
				exit('move_in_air');
	#combo timeout
	if(!attack_start && !attack_mid && combo_end):
		if(host.on_floor()):
			exit('move_on_ground');
		else:
			exit('move_in_air');
		return;
	pass;

func execute(delta):
	attack();
	#prevent player slipping
	if(host.on_floor() && !attack_mid):
		host.hspd = 0;
	pass;

func exit(state):
	#reset
	$CooldownTimer.wait_time = cool;
	$CooldownTimer.start();
	stopTimers();
	combo_step = 0;
	first_attack = 'nil';
	second_attack = 'nil';
	third_attack = 'nil';
	combo_attack = 'nil';
	current_attack = 'nil';
	attack_start = false;
	attack_mid = false;
	attack_end = false;
	special = "";
	dir = "";
	place = "";
	on_cooldown = true;
	dashing = false;
	hit = false;
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
				if(host.on_floor()):
					exit('move_on_ground');
				else:
					exit('move_in_air');
				return;
		if ((combo_step in [1,2,3]) && current_attack != 'nil'):
			animate = true;
			if(place == "Air"):
				air_counter -= 1;
				if(dir == "Up"): #TODO: enable once double jump is unlocked
					special = "";
			host.new_anim = special+dir+place+combo_attack;
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

func stopTimers():
	$InterruptTimer.stop();
	$RecoilTimer.stop();
	$EndComboTimer.stop();
	$FloatTimer.stop();
	track_input = false;
	floating = false;
	combo_end = false;
	pass;

func _on_CooldownTimer_timeout():
	on_cooldown = false;
	pass;


func _on_RecoilTimer_timeout():
	$InterruptTimer.wait_time = interrupt;
	$InterruptTimer.start();
	track_input = true;
	pass;


func _on_InterruptTimer_timeout():
	$EndComboTimer.wait_time = end;
	$EndComboTimer.start();
	track_input = false;
	pass;


func _on_FloatTimer_timeout():
	floating = false;
	pass;


func _on_EndComboTimer_timeout():
	combo_end = true;
	pass;