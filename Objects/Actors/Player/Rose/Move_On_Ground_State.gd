extends "./Free_Motion_State.gd"

func enter():
	host.state = 'move_on_ground';
	pass

func handleAnimation():
	if(host.hspd > 0 || host.hspd < 0):
		host.new_anim = "run";
	else: 
		host.new_anim = "idle";
	pass;

func handleInput(event):
	if(event.is_action_just_pressed("attack") && !attack.on_cooldown):
		exit('attack');
	if(event.is_action_pressed("jump")):
		host.vspd = -host.jspd;
		exit('move_in_air');
	pass

func execute(delta):
	var input_direction = get_input_direction();
	update_look_direction(input_direction);
	if(input_direction != 0):
		host.hspd = host.mspd * host.Direction;
	else:
		host.hspd = 0;
	if(!host.on_floor()):
		exit('move_in_air');

func exit(state):
	host.hspd = 0;
	.exit(state);
	pass
