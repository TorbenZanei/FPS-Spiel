extends Node

const CUBE_CORNERS = [
	Vector3(0, 0, 0),
	Vector3(0, 0, 1),
	Vector3(0, 1, 0),
	Vector3(0, 1, 1),
	Vector3(1, 0, 0),
	Vector3(1, 0, 1),
	Vector3(1, 1, 0),
	Vector3(1, 1, 1)
]

const TERRAIN_POINTS = [
	Vector3(-0.5, 0, 0),			#0
	Vector3(-0.5, 0, 0.5),			#1
	Vector3(-0.5, 0, 1),			#2
	Vector3(-0.5, 0.5, 0),			#3
	Vector3(-0.5, 0.5, 1),			#4
	Vector3(-0.5, 1, 0),			#5
	Vector3(-0.5, 1, 0.5),			#6
	Vector3(-0.5, 1, 1),			#7
	Vector3(0, -0.5, 0),			#8
	Vector3(0, -0.5, 0.5),			#9
	Vector3(0, -0.5, 1),			#10
	Vector3(0, 0, -0.5),			#11
	Vector3(0, 0, 0),				#12
	Vector3(0, 0, 0.5),				#13
	Vector3(0, 0, 1),				#14
	Vector3(0, 0, 1.5),				#15
	Vector3(0, 0.5, -0.5),			#16
	Vector3(0, 0.5, 0),				#17
	Vector3(0, 0.5, 0.5),			#18
	Vector3(0, 0.5, 1),				#19
	Vector3(0, 0.5, 1.5),			#20
	Vector3(0, 1, -0.5),			#21
	Vector3(0, 1, 0),				#22
	Vector3(0, 1, 0.5),				#23
	Vector3(0, 1, 1),				#24
	Vector3(0, 1, 1.5),				#25
	Vector3(0, 1.5, 0),				#26
	Vector3(0, 1.5, 0.5),			#27
	Vector3(0, 1.5, 1),				#28
	Vector3(0.5, -0.5, 0),			#29
	Vector3(0.5, -0.5, 1),			#30
	Vector3(0.5, 0, -0.5),			#31
	Vector3(0.5, 0, 0),				#32
	Vector3(0.5, 0, 0.5),			#33
	Vector3(0.5, 0, 1),				#34
	Vector3(0.5, 0, 1.5),			#35
	Vector3(0.5, 0.5, 0),			#36
	Vector3(0.5, 0.5, 1),			#37
	Vector3(0.5, 1, -0.5),			#38
	Vector3(0.5, 1, 0),				#39
	Vector3(0.5, 1, 0.5),			#40
	Vector3(0.5, 1, 1),				#41
	Vector3(0.5, 1, 1.5),			#42
	Vector3(0.5, 1.5, 0),			#43
	Vector3(0.5, 1.5, 1),			#44
	Vector3(1, -0.5, 0),			#45
	Vector3(1, -0.5, 0.5),			#46
	Vector3(1, -0.5, 1),			#47
	Vector3(1, 0, -0.5),			#48
	Vector3(1, 0, 0),				#49
	Vector3(1, 0, 0.5),				#50
	Vector3(1, 0, 1),				#51
	Vector3(1, 0, 1.5),				#52
	Vector3(1, 0.5, -0.5),			#53
	Vector3(1, 0.5, 0),				#54
	Vector3(1, 0.5, 0.5),			#55
	Vector3(1, 0.5, 1),				#56
	Vector3(1, 0.5, 1.5),			#57
	Vector3(1, 1, -0.5),			#58
	Vector3(1, 1, 0),				#59
	Vector3(1, 1, 0.5),				#60
	Vector3(1, 1, 1),				#61
	Vector3(1, 1, 1.5),				#62
	Vector3(1, 1.5, 0),				#63
	Vector3(1, 1.5, 0.5),			#64
	Vector3(1, 1.5, 1),				#65
	Vector3(1.5, 0, 0),				#66
	Vector3(1.5, 0, 0.5),			#67
	Vector3(1.5, 0, 1),				#68
	Vector3(1.5, 0.5, 0),			#69
	Vector3(1.5, 0.5, 1),			#70
	Vector3(1.5, 1, 0),				#71
	Vector3(1.5, 1, 0.5),			#72
	Vector3(1.5, 1, 1),				#73
]

const TERRAIN_UV_POINTS = [
	Vector2(0, 0),			#0
	Vector2(0, 0.5),		#1
	Vector2(0, 1),			#2
	Vector2(0.5, 0),		#3
	Vector2(0.5, 0.5),		#4
	Vector2(0.5, 1),		#5
	Vector2(1, 0),			#6
	Vector2(1, 0.5),		#7
	Vector2(1, 1)			#8
]

const CUBE_MESH = [
	[0, 3, 1, 3, 0, 2],			#Links
	[5, 6, 4, 6, 5, 7],			#Rechts
	[3, 6, 7, 6, 3, 2],			#Oben
	[5, 0, 1, 0, 5, 4],			#Unten
	[4, 2, 0, 2, 4, 6],			#Vorne
	[1, 7, 5, 7, 1, 3] 			#Hinten
]

const TERRAIN_BLOCK_MESH = [
	[],#0
	[],#1
	[],#2
	[],#3
	[Vector3(0, 1, 0), Vector3(0.5, 1, 0), Vector3(1, 1, 0), Vector3(0, 1, 0.5), Vector3(0.5, 1, 0.5), Vector3(1, 1, 0.5), Vector3(0, 1, 1), Vector3(0.5, 1, 1), Vector3(1, 1, 1)], # 4
	[Vector3(0, 0.5, 0), Vector3(0.5, 1, 0), Vector3(1, 1, 0), Vector3(0, 0.5, 0.5), Vector3(0.5, 1, 0.5), Vector3(1, 1, 0.5), Vector3(0, 0.5, 1), Vector3(0.5, 1, 1), Vector3(1, 1, 1)],#5
	[Vector3(0, 1, 0), Vector3(0.5, 1, 0), Vector3(1, 0.5, 0), Vector3(0, 1, 0.5), Vector3(0.5, 1, 0.5), Vector3(1, 0.5, 0.5), Vector3(0, 1, 1), Vector3(0.5, 1, 1), Vector3(1, 0.5, 1)],#6
	[],#7
	[],#8
	[],#9
	[],#10
	[],#11
	[],#12
	[],#13
	[],#14
	[],#15
	[],#16
	[],#17
	[],#18
	[],#19
	[Vector3(0, 0.5, 0), Vector3(0.5, 0.5, 0), Vector3(1, 0.5, 0), Vector3(0, 1, 0.5), Vector3(0.5, 1, 0.5), Vector3(1, 1, 0.5), Vector3(0, 1, 1), Vector3(0.5, 1, 1), Vector3(1, 1, 1)],#20
	[Vector3(0, 0.5, 0), Vector3(0.5, 0.5, 0), Vector3(1, 0.5, 0), Vector3(0, 0.5, 0.5), Vector3(0.5, 1, 0.5), Vector3(1, 1, 0.5), Vector3(0, 0.5, 1), Vector3(0.5, 1, 1), Vector3(1, 1, 1)],#21
	[Vector3(0, 0.5, 0), Vector3(0.5, 0.5, 0), Vector3(1, 0.5, 0), Vector3(0, 1, 0.5), Vector3(0.5, 1, 0.5), Vector3(1, 0.5, 0.5), Vector3(0, 1, 1), Vector3(0.5, 1, 1), Vector3(1, 0.5, 1)],#22
	[Vector3(0, 0.5, 0), Vector3(0.5, 0.5, 0), Vector3(1, 0.5, 0), Vector3(0, 0.5, 0.5), Vector3(0.5, 1, 0.5), Vector3(1, 0.5, 0.5), Vector3(0, 0.5, 1), Vector3(0.5, 1, 1), Vector3(1, 0.5, 1)],#23
	[],#24
	[],#25
	[],#26
	[],#27
	[],#28
	[],#29
	[],#30
	[],#31
	[],#32
	[],#33
	[],#34
	[],#35
	[Vector3(0, 1, 0), Vector3(0.5, 1, 0), Vector3(1, 1, 0), Vector3(0, 1, 0.5), Vector3(0.5, 1, 0.5), Vector3(1, 1, 0.5), Vector3(0, 0.5, 1), Vector3(0.5, 0.5, 1), Vector3(1, 0.5, 1)],#36
	[Vector3(0, 0.5, 0), Vector3(0.5, 1, 0), Vector3(1, 1, 0), Vector3(0, 0.5, 0.5), Vector3(0.5, 1, 0.5), Vector3(1, 1, 0.5), Vector3(0, 0.5, 1), Vector3(0.5, 0.5, 1), Vector3(1, 0.5, 1)],#37
	[Vector3(0, 1, 0), Vector3(0.5, 1, 0), Vector3(1, 0.5, 0), Vector3(0, 1, 0.5), Vector3(0.5, 1, 0.5), Vector3(1, 0.5, 0.5), Vector3(0, 0.5, 1), Vector3(0.5, 0.5, 1), Vector3(1, 0.5, 1)],#38
	[Vector3(0, 0.5, 0), Vector3(0.5, 1, 0), Vector3(1, 0.5, 0), Vector3(0, 0.5, 0.5), Vector3(0.5, 1, 0.5), Vector3(1, 0.5, 0.5), Vector3(0, 0.5, 1), Vector3(0.5, 0.5, 1), Vector3(1, 0.5, 1)],#39
	[],#40
	[],#41
	[],#42
	[],#43
	[],#44
	[],#45
	[],#46
	[],#47
	[],#48
	[],#49
	[],#50
	[],#51
	[],#52 
	[Vector3(0, 0.5, 0), Vector3(0.5, 0.5, 0), Vector3(1, 0.5, 0), Vector3(0, 0.5, 0.5), Vector3(0.5, 1, 0.5), Vector3(1, 1, 0.5), Vector3(0, 0.5, 1), Vector3(0.5, 0.5, 1), Vector3(1, 0.5, 1)],#53
	[Vector3(0, 0.5, 0), Vector3(0.5, 0.5, 0), Vector3(1, 0.5, 0), Vector3(0, 1, 0.5), Vector3(0.5, 1, 0.5), Vector3(1, 0.5, 0.5), Vector3(0, 0.5, 1), Vector3(0.5, 0.5, 1), Vector3(1, 0.5, 1)],#54
	[],#55
	[],#56
	[],#57
	[],#58
	[],#59
	[],#60
	[],#61
	[],#62
	[],#63
	[] #64
]

const TERRAIN_BLOCK_UV = [
	[[2, 0, 2 ,8], [2, 6, 8, 2]],
	
	[[2, 2, 0, 5], [2, 3, 5, 0], [2, 5, 3, 8], [2, 6, 8, 3]],
	
	[[2, 2, 0, 5], [2, 3, 5, 0], [2, 5, 3, 8], [2, 6, 8, 3]],
	
	[[2, 0, 2 ,8], [2, 6, 8, 2]],
	
	[[2, 2, 0, 5], [2, 4, 0, 2], [2, 4, 0, 7], [2, 6, 7, 0], [2, 5, 4, 8], [2, 7, 8, 4]],
	
	[[2, 2, 1, 8], [2, 4, 8, 1], [2, 8, 4, 6], [2, 3, 6, 4], [2, 1, 0, 4], [2, 3, 4, 0]],
	[[2, 2, 1, 5], [2, 4, 5, 1], [2, 4, 1, 6], [2, 0, 6, 1], [2, 3, 4, 8], [2, 7, 8, 4]],
	
	[[2, 2, 0, 5], [2, 3, 5, 0], [2, 4, 3, 7], [2, 6, 7, 3], [2, 5, 4, 8], [2, 5, 8, 4]],
	[[2, 2, 0, 5], [2, 3, 5, 0], [2, 5, 4, 8], [2, 7, 8, 4], [2, 4, 3, 6], [2, 6, 7, 4]],
	
	
	[[2, 2, 1, 5], [2, 4, 5, 1], [2, 5, 3, 8], [2, 6, 8, 3], [2, 1, 0, 4], [2, 3, 4, 0]],
	
	[[2, 2, 0, 4], [2, 2, 4, 8], [2, 7, 8, 4], [2, 4, 0, 7], [2, 6, 7, 0]],
	
	[[2, 1, 4, 2], [2, 5, 2, 4], [2, 1, 0, 4], [2, 3, 4, 0], [2, 5, 3, 8], [2, 6, 8, 3]]
]

const SIDE_VECTOR = [
	Vector3(-1,  0,  0),
	Vector3( 1,  0,  0),
	Vector3( 0,  1,  0),
	Vector3( 0, -1,  0),
	Vector3( 0,  0, -1),
	Vector3( 0,  0,  1),
]

const DIRECTION_VECTOR = [
	[Vector3(-0.5, 0, 0), Vector3(0, 0, 0), Vector3(0.5, 0, 0)],
	[Vector3(0.5, 0, 0), Vector3(0, 0, 0), Vector3(-0.5, 0, 0)],
	[Vector3(0, 0.5, 0), Vector3(0, 0, 0), Vector3(0, -0.5, 0)],
	[Vector3(0, -0.5, 0), Vector3(0, 0, 0), Vector3(0, 0.5, 0)],
	[Vector3(0, 0, -0.5), Vector3(0, 0, 0), Vector3(0, 0, 0.5)],
	[Vector3(0, 0, 0.5), Vector3(0, 0, 0), Vector3(0, 0, -0.5)]
]

const BASE_CORNERS = [
	Vector3(0, 1, 0),
	Vector3(0.5, 1, 0),
	Vector3(1, 1, 0),
	Vector3(0, 1, 0.5),
	Vector3(0.5, 1, 0.5),
	Vector3(1, 1, 0.5),
	Vector3(0, 1, 1),
	Vector3(0.5, 1, 1),
	Vector3(1, 1, 1),
	Vector3(0, 0.5, 0),
	Vector3(0.5, 0.5, 0),
	Vector3(1, 0.5, 0),
	Vector3(0, 0.5, 0.5),
	Vector3(1, 0.5, 0.5),
	Vector3(0, 0.5, 1),
	Vector3(0.5, 0.5, 1),
	Vector3(1, 0.5, 1),
	Vector3(0, 0, 0),
	Vector3(0.5, 0, 0),
	Vector3(1, 0, 0),
	Vector3(0, 0, 0.5),
	Vector3(0.5, 0, 0.5),
	Vector3(1, 0, 0.5),
	Vector3(0, 0, 1),
	Vector3(0.5, 0, 1),
	Vector3(1, 0, 1),
]

var neighboring_blocks
var mesh_triangles
var finalisd_vector

var mesh_id = 0
var mesh_points
var final_mesh
var final_uv_mesh


var block_id
var terrain_type
var parent_chunk
var position
var global_position
var rotation = 0

var mesh_ids

func set_neighbors(block_list):
	neighboring_blocks = [null, null, null, null, null, null]
	for i in range(6):
		if(block_list.has(global_position + SIDE_VECTOR[i])):
			neighboring_blocks[i] = block_list[global_position + SIDE_VECTOR[i]]

func set_left_neighbor_chunk_blocks(block_list):
	if(block_list.has(global_position + SIDE_VECTOR[0])):
		neighboring_blocks[0] = block_list[global_position + SIDE_VECTOR[0]]

func set_right_neighbor_chunk_blocks(block_list):
	if(block_list.has(global_position + SIDE_VECTOR[1])):
		neighboring_blocks[1] = block_list[global_position + SIDE_VECTOR[1]]

func set_front_neighbor_chunk_blocks(block_list):
	if(block_list.has(global_position + SIDE_VECTOR[4])):
		neighboring_blocks[4] = block_list[global_position + SIDE_VECTOR[4]]

func set_back_neighbor_chunk_blocks(block_list):
	if(block_list.has(global_position + SIDE_VECTOR[5])):
		neighboring_blocks[5] = block_list[global_position + SIDE_VECTOR[5]]

#braucht update
func update_neighbors(block_list):
	if(block_list.has(global_position + Vector3(-1, 0, 0))):
		neighboring_blocks[0] = block_list[global_position + Vector3(-1, 0, 0)]
		neighboring_blocks[0].neighboring_blocks[1] = self
	if(block_list.has(global_position + Vector3(1, 0, 0))):
		neighboring_blocks[1] = block_list[global_position + Vector3(1, 0, 0)]
		neighboring_blocks[1].neighboring_blocks[0] = self
	if(block_list.has(global_position + Vector3(0, 1, 0))):
		neighboring_blocks[2] = block_list[global_position + Vector3(0, 1, 0)]
		neighboring_blocks[2].neighboring_blocks[3] = self
	if(block_list.has(global_position + Vector3(0, -1, 0))):
		neighboring_blocks[3] = block_list[global_position + Vector3(0, -1, 0)]
		neighboring_blocks[3].neighboring_blocks[2] = self
	if(block_list.has(global_position + Vector3(0, 0, -1))):
		neighboring_blocks[4] = block_list[global_position + Vector3(0, 0, -1)]
		neighboring_blocks[4].neighboring_blocks[5] = self
	if(block_list.has(global_position + Vector3(0, 0, 1))):
		neighboring_blocks[5] = block_list[global_position + Vector3(0, 0, 1)]
		neighboring_blocks[5].neighboring_blocks[4] = self

func check_needet_vector():
	mesh_id = 0
	mesh_points = [1, 1, 1, 1, 1, 1]
	var final_check = []
	
	for i in range(neighboring_blocks.size()):
		if(typeof(neighboring_blocks[i]) == 2):
			mesh_id += pow(2,i)
			mesh_points[i] = 2
		elif(neighboring_blocks[i] == null):
			mesh_points[i] = 3
		else:
			final_check.append(i)
	
	mesh_id = int(mesh_id)
	
	match(mesh_id):
		4:
			for side in final_check:
				if(typeof(neighboring_blocks[side].neighboring_blocks[2]) != 2):
					mesh_points[side] = 3

func generate_block(st):
	if(terrain_type == 1):
		return generate_cube_mesh(st)

		#return generate_terrain_mesh(st)
	elif(terrain_type == 2):
		return generate_cube_mesh(st)

func generate_cube_mesh(st):
	var collision_array = PoolVector3Array()
	for i in range(6):
		if(typeof(neighboring_blocks[i]) == 2):
			var uv = get_cube_uv(GD.block_texture_data[block_id][i])
			for j in CUBE_MESH[i].size():
				st.add_uv(uv[j])
				st.add_vertex(position + CUBE_CORNERS[CUBE_MESH[i][j]])
				collision_array.append(position + CUBE_CORNERS[CUBE_MESH[i][j]])
	return collision_array

func get_cube_collision():
	var collision_array = PoolVector3Array()
	if(typeof(neighboring_blocks[0]) == 2):
		for j in CUBE_MESH[0].size():
			collision_array.append(position + CUBE_CORNERS[CUBE_MESH[0][j]])
	
	if(typeof(neighboring_blocks[1]) == 2):
		for j in CUBE_MESH[1].size():
			collision_array.append(position + CUBE_CORNERS[CUBE_MESH[1][j]])
	
	if(typeof(neighboring_blocks[2]) == 2):
		for j in CUBE_MESH[2].size():
			collision_array.append(position + CUBE_CORNERS[CUBE_MESH[2][j]])
	
	if(typeof(neighboring_blocks[3]) == 2):
		for j in CUBE_MESH[3].size():
			collision_array.append(position + CUBE_CORNERS[CUBE_MESH[3][j]])
	
	if(typeof(neighboring_blocks[4]) == 2):
		for j in CUBE_MESH[4].size():
			collision_array.append(position + CUBE_CORNERS[CUBE_MESH[4][j]])
	
	if(typeof(neighboring_blocks[5]) == 2):
		for j in CUBE_MESH[5].size():
			collision_array.append(position + CUBE_CORNERS[CUBE_MESH[5][j]])
	
	return collision_array

func get_cube_uv(texture_id):
	# This method only supports square texture sheets.
	var row = texture_id / GD.TEXTURE_SHEET_WIDTH
	var col = texture_id % GD.TEXTURE_SHEET_WIDTH
	
	return [
		GD.TEXTURE_TILE_SIZE * Vector2(col, row + 1),
		GD.TEXTURE_TILE_SIZE * Vector2(col + 1, row),
		GD.TEXTURE_TILE_SIZE * Vector2(col + 1, row + 1),
		GD.TEXTURE_TILE_SIZE * Vector2(col + 1, row),
		GD.TEXTURE_TILE_SIZE * Vector2(col, row + 1),
		GD.TEXTURE_TILE_SIZE * Vector2(col, row)
	]

func generate_terrain_mesh(st):
	final_mesh = []
	final_uv_mesh = []
	match(mesh_id):
		4:
			pass
	
	var collision_array = PoolVector3Array()
	for i in final_mesh.size():
		var uv_shift = get_terrain_uv_shift(final_uv_mesh[i][0])
		st.add_uv(GD.TEXTURE_TILE_SIZE * (uv_shift + final_uv_mesh[i][1]))
		st.add_vertex(position + final_mesh[i])
		
		collision_array.append(position + final_mesh[i])

				
	return get_cube_collision()

func get_meshpoint(side, view):
	if(typeof(neighboring_blocks[side]) == 2):
		return 0
	elif(neighboring_blocks[side] == null or typeof(neighboring_blocks[side].neighboring_blocks[view]) != 2):
		return 1
	elif(neighboring_blocks[side].mesh_points[view] == 2):
		return 2

func free_side(side):
	return typeof(neighboring_blocks[side]) == 2

func blockt_side(side, view):
	return neighboring_blocks[side] == null or (typeof(neighboring_blocks[side]) != 2 and typeof(neighboring_blocks[side].neighboring_blocks[view]) != 2)

func get_terrain_uv_shift(side):
	var texture_ids = GD.block_texture_data[block_id]
	
	var row = texture_ids[side] / GD.TEXTURE_SHEET_WIDTH
	var col = texture_ids[side] % GD.TEXTURE_SHEET_WIDTH
	return (Vector2(col, row))

func array_to_int(connections_array:Array):
	return (
		connections_array[0] + connections_array[1] * 2 + connections_array[2] * 4 +
		connections_array[3] * 8 + connections_array[4] * 16 + connections_array[5] * 32
	)

func check_side_of_collision(collision:Vector3):
	var block_center = position + Vector3(0.5, 0.5, 0.5)
	var direction = collision.direction_to(block_center)
	direction.normalized()
	
	var absolut_values = [abs(direction.x), abs(direction.y), abs(direction.z)]
	var maximum = absolut_values.max()
	
	var direction_vector	#0 = Oben 1 = Unten 2 = Links 3 = Rechts 4 = Vorne 5 = Hinten
	
	if(maximum == absolut_values[0]):
		if(direction.x < 0):
			direction_vector = Vector3.RIGHT
		else:
			direction_vector = Vector3.LEFT
	if(maximum == absolut_values[1]):
		if(direction.y < 0):
			direction_vector = Vector3.UP
		else:
			direction_vector = Vector3.DOWN
	if(maximum == absolut_values[2]):
		if(direction.z < 0):
			direction_vector = Vector3.BACK
		else:
			direction_vector = Vector3.FORWARD
	
	return direction_vector

func is_accesable():
	return (
		neighboring_blocks[0].terrain_type == 0 or neighboring_blocks[1].terrain_type == 0 or 
		neighboring_blocks[2].terrain_type == 0 or neighboring_blocks[3].terrain_type == 0 or
		neighboring_blocks[4].terrain_type == 0 or neighboring_blocks[5].terrain_type == 0
	)
 
func delete_block():
	neighboring_blocks[0].neighboring_blocks[1] = null
	neighboring_blocks[1].neighboring_blocks[0] = null
	neighboring_blocks[2].neighboring_blocks[3] = null
	neighboring_blocks[3].neighboring_blocks[2] = null
	neighboring_blocks[4].neighboring_blocks[5] = null
	neighboring_blocks[5].neighboring_blocks[4] = null
	queue_free()
