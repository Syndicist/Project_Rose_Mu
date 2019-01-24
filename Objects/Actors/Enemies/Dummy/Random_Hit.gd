extends Area2D

var dir = Vector2(1,1);

func _ready():
	connect("area_entered", self, "on_area_entered");
	pass

func on_area_entered(area):
	if(area.global_position.x > global_position.x):
		dir.x = -1;
	if(area.global_position.x < global_position.x):
		dir.x = 1;
	if(area.global_position.y < global_position.y):
		dir.y = -1;
	if(area.global_position.y > global_position.y):
		dir.y = 1;
	get_parent().apply_impulse(get_parent().position,Vector2(25 * dir.x, 25 * dir.y));
	pass;