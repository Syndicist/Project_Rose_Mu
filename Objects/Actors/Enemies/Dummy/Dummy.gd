extends KinematicBody2D

var Direction = 1;
var hspd = 0;
var vspd = 0;
var gravity = 1200;
var friction = 10;
var velocity = Vector2(0,0);
var floor_normal = Vector2(0,-1);

func _physics_process(delta):
	#move across surfaces
	velocity.y = vspd;
	velocity.x = hspd;
	velocity = move_and_slide(velocity, floor_normal);
	
	#no gravity acceleration when on floor
	if(is_on_floor()):
		velocity.y = 0
		vspd = 0;
		friction = 10;
	
	vspd += gravity * delta;
	
	#cap gravity
	if(vspd > 450):
		vspd = 450;
	
	if(is_on_ceiling()):
		vspd = 0;
	
	if(hspd > 0):
		hspd -= friction;
	elif(hspd < 0):
		hspd += friction;
	if((hspd <= 44 && hspd > 0) || (hspd >= 44 && hspd < 0)):
		hspd = 0;
	pass;


func _on_Area2D_area_entered(area):
	if(area.host.global_position >= global_position):
		Direction = -1;
	else:
		Direction = 1;
	#hspd = area.speed * Direction; 
	gravity = 600;
	vspd = -area.knockback.y;
	var dir = 1;
	if(area.global_position.x > global_position.x):
		dir = -1;
	hspd = area.knockback.x * dir;
	friction = 0;
	pass;
