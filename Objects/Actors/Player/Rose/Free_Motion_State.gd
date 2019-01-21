extends "./State.gd"

func get_input_direction():
	var input_direction = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"));
	return input_direction;

func update_look_direction(direction):
	if(direction == 0):
		return;
	if(host.Direction != direction):
		if(host.Direction != 0):
			host.scale.x = host.scale.x * -1;
		host.Direction = direction;