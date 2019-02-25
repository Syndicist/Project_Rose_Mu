extends "./Free_Motion_State.gd"

var wasnt_wall = false;
var is_wall = false;

func enter():
	host.state = 'move_in_air';
	pass

func handleAnimation():
	if(host.vspd < 0):
		host.new_anim = "jump";
	elif(host.vspd > 0):
		host.new_anim = "fall";
	pass;

func handleInput(event):
	if(event.is_action_just_pressed("attack") && !attack.on_cooldown):
		exit('attack');
	elif(event.is_action_just_released("jump")):
		if(host.vspd < -1*host.jspd/3):
			host.vspd = -1*host.jspd/3;
	elif(host.on_floor()):
		exit('move_on_ground');
	elif(event.is_action_pressed("grab")):
		host.get_node("ledge_cast").enabled = true;
		if(!host.get_node("ledge_cast").is_colliding()):
			wasnt_wall = true;
		if(wasnt_wall && host.get_node("ledge_cast").is_colliding()):
			is_wall = true;
		if(host.vspd > 0 && wasnt_wall && is_wall):
			exit('ledge_grab');
	pass

func execute(delta):
	var input_direction = get_input_direction();
	update_look_direction(input_direction);
	if(input_direction != 0):
		host.hspd = host.mspd * host.Direction;
	else:
		host.hspd = 0;
	pass;

func exit(state):
	wasnt_wall = false;
	is_wall = false;
	.exit(state);
	pass
