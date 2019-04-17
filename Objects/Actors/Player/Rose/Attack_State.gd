extends "./Free_Motion_State.gd"

signal vault;

### temp inits ###
var combo_step = 0;
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
var attack_spawned = false;
var attack_is_saved = false;

### attack codes ###
var type = "slashing";
var dir = "horizontal";
var vdir = "";
var place = "_ground";
var magic = "";
var current_attack = 'nil';
var saved_attack = 'nil';
var attack_str = "";
var attack_idx = "";


### modifiable inits ###
var end = .5;
var interrupt = .5;
var distance_traversable = 80;
var air_counter = 1;
var cool = 1;
var base_cost = 15;
var spec_cost = 25;
var basic_cost = 15;
var cur_cost = 0;
var anim_start = true;
var cast_length = 75;
var val = .2;

### item_vars ###
var pierce_enabled = false;
var bash_enabled = false;

### debug_vars ###
var input_testing = false;

func enter():
	host.state = 'attack';
	track_input = true;
	saveInput(Input);
	pass;

func handleAnimation():
	if(!input_testing):
		if(attack_end):
			if(host.on_floor()):
				pass;
				#if(combo_attack.length()%2 == 1):
				#	host.new_anim = combo_attack.substr(combo_attack.length()-1,1) + "land";
				#else:
				#	host.new_anim = "-" + combo_attack.substr(combo_attack.length()-1,1) + "land";
		elif(attack_start):
			host.animate(attack_str + attack_idx, false);
	
	pass;

func saveInput(event):
	if(event.is_action_just_pressed("basic_attack") || event.is_action_just_pressed("special_attack")):
		if(event.is_action_just_pressed("basic_attack")):
			saved_attack = 'basic';
			cur_cost = basic_cost;
		elif(event.is_action_just_pressed("special_attack")):
			saved_attack = 'special';
			cur_cost = spec_cost;
			attack_idx = "";
			if(host.magic_bool):
				magic = "_magic";
			else:
				magic = "";
		if(saved_attack != 'nil'):
			attack_is_saved = true;
	pass;

func atk_left(event):
	return event.is_action_pressed("rleft") || host.mouse_l() || event.is_action_pressed("left");

func atk_right(event):
	return event.is_action_pressed("rright") || host.mouse_r() || event.is_action_pressed("right");

func atk_up(event):
	return event.is_action_pressed("rup") || host.mouse_u() || event.is_action_pressed("up");

func atk_down(event):
	return event.is_action_pressed("rdown") || host.mouse_d() || event.is_action_pressed("down");

func handleInput(event):
	if(attack_mid || attack_end):
		saveInput(event);
	if(track_input):
		if(host.resource < -10):
			exit_g_or_a();
			return;
		if(event.is_action_pressed("switchL") && event.is_action_pressed("switchR")):
			exit('block');
			return;
		elif(event.is_action_pressed("switchL")):
			type = "precision";
		elif(event.is_action_pressed("switchR")):
			type = "bashing";
		else:
			type = "slashing";
		
		if(atk_left(event)):
			dir = "horizontal"
			update_look_direction(-1);
		elif(atk_right(event)):
			dir = "horizontal";
			update_look_direction(1);
		elif(host.mouse_enabled):
			dir = "";
		
		if(atk_down(event) || atk_up(event)):
			if(!atk_left(event) && !atk_right(event)):
				dir = "";
			if(atk_up(event)):
				vdir = "_up";
			elif(atk_down(event)):
				vdir = "_down";
		else:
			vdir = "";
			dir = "horizontal"
		
		
		if(host.on_floor()):
			place = "_ground";
		else:
			place = "_air";
		#if an attack is triggered, commit to it
		if(event.is_action_just_pressed("basic_attack") || event.is_action_just_pressed("special_attack")):
			if(event.is_action_just_pressed("basic_attack")):
				current_attack = 'basic';
				cur_cost = basic_cost;
			elif(event.is_action_just_pressed("special_attack")):
				current_attack = 'special';
				cur_cost = spec_cost;
				attack_idx = "";
				if(host.magic_bool):
					magic = "_magic";
				else:
					magic = "";
			
			if(init_attack()):
				return;
		elif(attack_is_saved):
			current_attack = saved_attack;
			if(init_attack()):
				return;
		#cancel the combo
		elif(!attack_is_saved && 
			(!event.is_action_pressed("switchL") && 
			!event.is_action_pressed("switchR") && 
			!event.is_action_pressed("lock")) ):
			if(event.is_action_pressed("left") ||
				event.is_action_pressed("right")):
				exit_g_or_a();
				return;
		elif(!attack_is_saved && !event.is_action_pressed("lock")):
			if(event.is_action_just_pressed("jump")):
				exit_g_or_a();
				return;
	#combo timeout
	if(!attack_start && !attack_mid && combo_end && 
		(!event.is_action_pressed("switchL") && 
		!event.is_action_pressed("switchR") && 
		!event.is_action_pressed("lock"))):
		exit_g_or_a();
		return;
	pass;

func execute(delta):
	if(!input_testing):
		attack();
	#prevent player slipping
	if(host.on_floor() && !attack_mid && !dashing):
		host.hspd = 0;
	pass;

func exit(state):
	#reset
	stopTimers();
	reset_strings();
	combo_step = 0;
	attack_start = false;
	attack_mid = false;
	attack_end = false;
	
	dashing = false;
	hit = false;
	attack_spawned = false;
	attack_is_saved = false;
	
	
	.exit(state);
	pass;

func attack():
	#if current_attack has a value, the attack hasn't actually triggered yet, and we're calling the attack to be triggered...
	if(current_attack != 'nil' && !attack_spawned && attack_start):
		#TODO: put this signal in the attacks instead
		host.emit_signal("consume_resource", cur_cost);
		animate = true;
		attack_spawned = true;
		
		construct_attack_str();
		
		var path = "res://Objects/Actors/Player/Rose/AttackObjects/" + type + "/" + current_attack + "/";
		#Ignore certain string combinations that result in existing attacks
		if(current_attack == "basic"):
			if(attack_idx == "_1"):
				attack_idx = "_2";
			else:
				attack_idx = "_1";
			magic = "";
			if(dir == "horizontal"):
				if(!atk_up(Input) && !atk_down(Input)):
					vdir = "";
					place = "";
				elif(!atk_down(Input)):
					place = "";
			elif(atk_up(Input)):
				place = "";
			
			path += dir+vdir+place+"_attack.tscn";
		
		
		if(current_attack == "special"):
			if(type == "slashing" || type == "bashing"):
				if(dir == "horizontal"):
					if(!atk_up(Input) && !atk_down(Input)):
						vdir = "";
						place = "";
					elif(!atk_down(Input) || type == "bashing"):
						place = "";
				elif(atk_up(Input)):
					place = "";
					
			
			path += dir+vdir+place+magic+"_attack.tscn";
		
		var true_length = cast_length;
		if((atk_down(Input) || atk_up(Input)) && (atk_right(Input) || atk_left(Input))):
			true_length = true_length / sqrt(2);
		if(atk_down(Input)):
			host.get_node("vault_cast").cast_to.y = true_length;
		elif(atk_up(Input)):
			host.get_node("vault_cast").cast_to.y = -true_length;
		else:
			host.get_node("vault_cast").cast_to.y = 0;
		if(atk_right(Input)):
			host.get_node("vault_cast").cast_to.x = true_length;
		elif(atk_left(Input)):
			host.get_node("vault_cast").cast_to.x = -true_length;
		else:
			host.get_node("vault_cast").cast_to.x = 0;
		
		var effect = load(path).instance();
		effect.host = host;
		effect.attack_state = self;
		host.add_child(effect);
	pass;

func init_attack():
	
	if(input_testing):
		construct_attack_str();
		attack_is_saved = false;
		return true;
	else:
		if(current_attack != 'nil'):
			stopTimers();
			attack_start = true;
			combo_step += 1;
			attack_end = false;
			attack_is_saved = false;
			saved_attack = 'nil'
			return true;
		return false;
	pass;

func construct_attack_str():
	var tdir = dir;
	var tvdir = vdir;
	var tcurrent_attack = "";
	if(dir != ""):
		tdir = "_" + dir;
	tcurrent_attack = "_" + current_attack;
	
	attack_str = type+tdir+tvdir+place+magic+tcurrent_attack;
	print(attack_str);
	pass;

func reset_strings():
	type = "slashing";
	dir = "horizontal";
	vdir = "";
	place = "_ground";
	magic = "";
	current_attack = 'nil';
	saved_attack = 'nil';
	attack_str = "";

func stopTimers():
	$InterruptTimer.stop();
	$RecoilTimer.stop();
	$FloatTimer.stop();
	track_input = false;
	floating = false;
	combo_end = false;
	pass;

func _on_RecoilTimer_timeout():
	$InterruptTimer.wait_time = interrupt;
	$InterruptTimer.start();
	reset_strings();
	track_input = true;
	pass;


func _on_InterruptTimer_timeout():
	if(Input.is_action_pressed("attack")):
		track_input = false;
	combo_end = true;
	pass;


func _on_FloatTimer_timeout():
	floating = false;
	pass;

func _on_Attack_vault():
	host.get_node("vault_cast").cast_to = Vector2(0, cast_length);
	if(dir == "horizontal" && current_attack == "basic"):
		host.animate("vault_lift");
		host.hspd = 500 * host.Direction;
		host.vspd = -200;
		
		$VaultTimer.wait_time = val;
	else:
		host.animate("vault_still");
		$VaultTimer.wait_time = 0.1;
	$VaultTimer.start();
	pass;


func _on_VaultTimer_timeout():
	host.hspd = 0;
	host.vspd = 0;
	
	exit("vault");
	pass;
