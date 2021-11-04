extends KinematicBody

export var speed = 10
export var acceleration = 5
export var gravity = 0.98
export var jump_power = 30
export var mouse_sensitivity = 0.3

onready var head = $Head
onready var camera = $Head/Camera
onready var gm_rayCast = $Head/Camera/Ground_Mesh_RayCast
onready var sm_rayCast = $Head/Camera/Select_Marker_RayCast
onready var select_marker 

var select_marker_visible = false

var pause_menue = false
var velocity = Vector3()
var camera_x_rotation = 0

var current_selection = null
var player_grid_position = [6,127,127]

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	if(Input.is_action_just_pressed("ui_cancel")):
		if(pause_menue):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			pause_menue = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			pause_menue = true
	elif(Input.is_action_just_pressed("Left_Mouse_Action")):
		if(gm_rayCast.is_colliding()):
			#print(current_selection.sorounding + " " + String(current_selection.position) + " " + String(current_selection.neighboring_blocks))
			print(current_selection.mesh_id)
#			print(current_selection.parent_chunk)
			#print(current_selection.neighboring_blocks)
			#print(current_selection.parent_chunk.chunk_coordinates)
			#gm_rayCast.get_collider().get_parent().create_new_block(gm_rayCast.get_collision_point(), current_selection)
#			current_selection = null
#			select_marker.visible = false
	elif(Input.is_action_just_pressed("Right_Mouse_Action")):
		if(gm_rayCast.is_colliding()):
			gm_rayCast.get_collider().get_parent().remove_block(current_selection)
			current_selection = null
			select_marker.visible = false

func _input(event):
	if event is InputEventMouseMotion && !pause_menue:
		head.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		
		var x_delta = event.relative.y * mouse_sensitivity
		if(camera_x_rotation + x_delta > -90 and camera_x_rotation + x_delta < 90):
			camera.rotate_x(deg2rad((-x_delta)))
			camera_x_rotation += x_delta
		
		selection_detection()

func selection_detection():
	if(gm_rayCast.is_colliding()):
		select_marker.visible = true
		var direction = self.translation + Vector3(0, 0.5, 0)
		direction = direction.direction_to(gm_rayCast.get_collision_point())
		direction.normalized()
		var block = gm_rayCast.get_collider().get_parent().get_block(gm_rayCast.get_collision_point(), direction)
		if(block != null):
			current_selection = block[1]
			select_marker.global_transform.origin = block[0] + Vector3(0.5, 0.5, 0.5)
		else:
			current_selection = null
			select_marker.visible = false
	else:
		current_selection = null
		select_marker.visible = false

func _physics_process(delta):
	var head_basis = head.get_global_transform().basis
	
	var direction = Vector3()
	if Input.is_action_pressed("move_forward"):
		direction -= head_basis.z
	elif Input.is_action_pressed("move_backward"):
		direction += head_basis.z
	
	if Input.is_action_pressed("move_left"):
		direction -= head_basis.x
	elif Input.is_action_pressed("move_right"):
		direction += head_basis.x
	
	if Input.is_action_pressed("crouch"):
		direction -= head_basis.y
	elif Input.is_action_pressed("jump"):
		direction += head_basis.y
	
	direction = direction.normalized()
	
	
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	
	if(!is_on_floor()):
		pass
		#velocity.y -= gravity
	
	#if Input.is_action_just_pressed("jump") and is_on_floor():
	#	velocity.y += jump_power
	
	velocity = move_and_slide(velocity, Vector3.UP)
	selection_detection()
	send_position()
	
	
	$Head/Camera/Label_x.text = String(self.translation)
	$Head/Camera/Label_y.text = String(Engine.get_frames_per_second())
	#$Head/Camera/Label_z.text = String(position.z)
	
func send_position():
	get_parent().charakter_moved(self.translation)
	
