extends "./Free_Motion_State.gd"

func enter():
	host.state = 'move_in_air';
	pass

func handleInput(event):
	if(event.is_action_just_pressed("attack") && !attack.on_cooldown):
		exit('attack');
	pass

func execute(delta):
	var input_direction = get_input_direction();
	update_look_direction(input_direction);
	if(input_direction != 0):
		host.hspd = host.mspd * host.Direction;
	else:
		host.hspd = 0;
	if(host.is_on_floor()):
		exit('move_on_ground');

func exit(state):
	.exit(state);
	pass
