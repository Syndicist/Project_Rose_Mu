extends KinematicBody2D

###physics vars###
var air_time = 0;
var hspd = 0;
var vspd = 0;
var fspd = 0;
var mspd = 350;
var jspd = 500;
var Direction = 1;
var gravity = 1200;
var velocity = Vector2(0,0);
var floor_normal = Vector2(0,-1);

###states###
#TODO: hurt_state
onready var states = {
	'move_on_ground' : $States/Move_On_Ground,
	'move_in_air' : $States/Move_In_Air,
	'attack' : $States/Attack
}
var state = 'move_on_ground';
###hitbox detection###
#var targettableHitboxes = [];


###camera control###
onready var cam = get_node("Camera2D");

func _ready():
	$Camera2D.current = true;
	pass;

func _physics_process(delta):
	#state machine
	states[state].handleInput(Input);
	states[state].execute(delta);
	
	#count time in air
	air_time += delta;
	
	#move across surfaces
	velocity.y = vspd + fspd;
	velocity.x = hspd;
	velocity = move_and_slide(velocity, floor_normal);
	
	#no gravity acceleration when on floor
	if(is_on_floor()):
		air_time = 0;
		velocity.y = 0
		vspd = 0;
		fspd = 0;
	
	if(!states['attack'].dashing):
		fspd += gravity * delta;
	
	#cap gravity
	if(fspd > 900):
		fspd = 900;
	
	if(is_on_ceiling()):
		fspd = 500;
	pass;

"""
func _on_DetectHitboxArea_area_entered(area):
	if(!targettableHitboxes.has(area)):
		targettableHitboxes.push_back(area);
	pass;
func _on_DetectHitboxArea_area_exited(area):
	if(targettableHitboxes.has(area)):
		targettableHitboxes.erase(area);
	pass;

func hitboxLoop():
	var space_state = get_world_2d().direct_space_state;
	for item in targettableHitboxes:
		var slash = nextRay(self,item,11,space_state);
		var bash = nextRay(self,item,12,space_state);
		var pierce = nextRay(self,item,13,space_state);
		if(slash || bash || pierce):
			item.hittable = true;
		else:
			item.hittable = false;
	pass;

func nextRay(origin,dest,col_layer,spc):
	if(!itemTrace.has(origin)):
		itemTrace.push_back(origin);
	var result = spc.intersect_ray(origin.global_position, dest.global_position, itemTrace, $RayCastCollision.collision_mask);
	if(result.empty()):
		itemTrace.clear();
		return true;
	elif(result.collider.get_collision_layer_bit(col_layer)):
		if(result.collider != dest):
			return nextRay(result.collider,dest,col_layer,spc);
		else:
			itemTrace.clear();
			return true;
	else:
		itemTrace.clear();
		return false;
"""