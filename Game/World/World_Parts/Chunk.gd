extends MeshInstance

var Block = preload("res://Game/World/World_Generator/Block.gd")

signal chunk_ready
signal chunk_closed

var chunk_thread

var chunk_coordinates
var neighboring_chunk = [null, null, null, null]  #[Links,Rechts,Vorne,Hinten]

var chunk_blocks

var left_border_blocks
var right_border_blocks
var front_border_blocks
var back_border_blocks

var visible_blocks

var collision_array

var render_request = false
var surroundet = false
var full_surroundet = false
var neighbors_set = false
var vector_ready = false

var markt_for_delete = false
var cleard = true
var initialised = false

func _init():
	chunk_thread = Thread.new()
	visible = false

#Erstellen und Updaten des Chunks
func initialise_chunk(position):
	chunk_thread.start(self, "initialisation", position, Thread.PRIORITY_LOW)

func initialisation(position):
	initialised = false
	markt_for_delete = false
	vector_ready = false
	chunk_coordinates = position
	
	var chunk_data = GD.map_generator.init_chunk(self)
	left_border_blocks = chunk_data[0]
	right_border_blocks = chunk_data[1]
	front_border_blocks = chunk_data[2]
	back_border_blocks = chunk_data[3]
	
	visible_blocks = chunk_data[4]
	chunk_blocks = chunk_data[5]
	
	cleard = false
	emit_signal("chunk_ready")
	initialised = true

func prepair_vector():
	for block in visible_blocks:
		block.check_needet_vector()
	
	vector_ready = true

func vectors_ready():
	var ready = [false, false, false, false]
	
	if(neighboring_chunk[0] != null):
		ready[0] = neighboring_chunk[0].vector_ready
	if(neighboring_chunk[1] != null):
		ready[1] = neighboring_chunk[1].vector_ready
	if(neighboring_chunk[2] != null):
		ready[2] = neighboring_chunk[2].vector_ready
	if(neighboring_chunk[3] != null):
		ready[3] = neighboring_chunk[3].vector_ready
	
	return ready[0] and ready[1] and ready[2] and ready[3]

func vector_full_ready():
	var ready = [false, false, false, false]
	
	if(neighboring_chunk[0] != null):
		ready[0] = neighboring_chunk[0].vectors_ready()
	if(neighboring_chunk[1] != null):
		ready[1] = neighboring_chunk[1].vectors_ready()
	if(neighboring_chunk[2] != null):
		ready[2] = neighboring_chunk[2].vectors_ready()
	if(neighboring_chunk[3] != null):
		ready[3] = neighboring_chunk[3].vectors_ready()
	
	return ready[0] and ready[1] and ready[2] and ready[3]

#func create_mesh():
#	chunk_thread.start(self, "mesh_creation", null, Thread.PRIORITY_LOW)

func create_mesh():
	translation = Vector3(chunk_coordinates.x * 16, 0, chunk_coordinates.y * 16)
	var st = SurfaceTool.new()
	collision_array = PoolVector3Array()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var material = GD.block_material
	st.set_material(material)
	
	for block in visible_blocks:
		collision_array.append_array(block.generate_block(st))

	var collision_shape = ConcavePolygonShape.new()

	st.generate_normals()
	#st.generate_tangents()
	
	var new_mesh = st.commit()
	self.mesh = new_mesh
	
	check_for_map_border()
	collision_shape.set_faces(collision_array)
	
	$Chunk_Collision/CollisionShape.shape = collision_shape
	render_request = false

func clear_chunk():
	if(neighboring_chunk[0] != null):
		neighboring_chunk[0].neighboring_chunk[1] = null
		neighboring_chunk[0] = null
	
	if(neighboring_chunk[1] != null):
		neighboring_chunk[1].neighboring_chunk[0] = null
		neighboring_chunk[1] = null
	
	if(neighboring_chunk[2] != null):
		neighboring_chunk[2].neighboring_chunk[3] = null
		neighboring_chunk[2] = null
	
	if(neighboring_chunk[3] != null):
		neighboring_chunk[3].neighboring_chunk[2] = null
		neighboring_chunk[3] = null
	
	render_request = false
	surroundet = false
	full_surroundet = false
	neighbors_set = false
	vector_ready = false
	visible = false
	cleard = true

#Aktionen auf dem Chunk
func get_block(coordinate:Vector3, direction:Vector3):
	
	var mondified = [abs(coordinate.x - round(coordinate.x)), abs(coordinate.y - round(coordinate.y)), abs(coordinate.z - round(coordinate.z))]
	var side = mondified.min()
	var block_position = [coordinate.x, coordinate.y, coordinate.z]
	
	if(side == mondified[0]):
		if(direction.x < 0):
			block_position[0] -= 0.001
		else:
			block_position[0] += 0.001
	if(side == mondified[1]):
		if(direction.y < 0):
			block_position[1] -= 0.001
		else:
			block_position[1] += 0.001
	if(side == mondified[2]):
		if(direction.z < 0):
			block_position[2] -= 0.001
		else:
			block_position[2] += 0.001
	
	block_position = [int(block_position[0]) ,int(block_position[1]), int(block_position[2])]
	
	if(chunk_blocks.has(Vector3(block_position[0], block_position[1], block_position[2]))):
		var block = chunk_blocks[Vector3(block_position[0], block_position[1], block_position[2])]
		return [Vector3(block_position[0], block_position[1], block_position[2]), block]
	else:
		return null

func create_new_block(coordinate:Vector3, block):
	var direction_vector
	if(block != null and block.position.y < 256):
		var local = to_local(coordinate)
		direction_vector = block.check_side_of_collision(local)
		var block_position = block.position + direction_vector
		
		var new_block = GD.map_generator.add_block(self, block_position)
		new_block[0].parent_chunk.add_block(new_block)

func set_neighbors():
	if(neighboring_chunk[0] != null):
		for block in left_border_blocks.keys():
			if(typeof(left_border_blocks[block]) != 2):
				left_border_blocks[block].set_left_neighbor_chunk_blocks(neighboring_chunk[0].right_border_blocks)
	if(neighboring_chunk[1] != null):
		for block in right_border_blocks.keys():
			if(typeof(right_border_blocks[block]) != 2):
				right_border_blocks[block].set_right_neighbor_chunk_blocks(neighboring_chunk[1].left_border_blocks)
	if(neighboring_chunk[2] != null):
		for block in front_border_blocks.keys():
			if(typeof(front_border_blocks[block]) != 2):
				front_border_blocks[block].set_front_neighbor_chunk_blocks(neighboring_chunk[2].back_border_blocks)
	if(neighboring_chunk[3] != null):
		for block in back_border_blocks.keys():
			if(typeof(back_border_blocks[block]) != 2):
				back_border_blocks[block].set_back_neighbor_chunk_blocks(neighboring_chunk[3].front_border_blocks)
	
	neighbors_set = true

func add_block(block):
	set_new_block(block)
	var new_needet_blocks = GD.map_generator.generate_needet_neighbors(self, block[0])
		
	for i in range(new_needet_blocks.size()):
		if(new_needet_blocks[i] != null):
			var for_neighbor = false
			if(new_needet_blocks[i][1].x - (chunk_coordinates.x * 16) == -1):
				neighboring_chunk[0].set_new_block_at_neighbor([new_needet_blocks[i][0], new_needet_blocks[i][1]], left_border_blocks)
				for_neighbor = true
			elif(new_needet_blocks[i][1].x - (chunk_coordinates.x * 16) == 16):
				neighboring_chunk[1].set_new_block_at_neighbor([new_needet_blocks[i][0], new_needet_blocks[i][1]], right_border_blocks)
				for_neighbor = true
			if(new_needet_blocks[i][1].z - (chunk_coordinates.y * 16) == -1):
				neighboring_chunk[2].set_new_block_at_neighbor([new_needet_blocks[i][0], new_needet_blocks[i][1]], front_border_blocks)
				for_neighbor = true
			elif(new_needet_blocks[i][1].z - (chunk_coordinates.y * 16) == 16):
				neighboring_chunk[3].set_new_block_at_neighbor([new_needet_blocks[i][0], new_needet_blocks[i][1]], back_border_blocks)
				for_neighbor = true
				
			if(!for_neighbor):
				set_new_block(new_needet_blocks[i])
		else:
			if(typeof(block[0].neighboring_blocks[i]) != 2):
				block[0].neighboring_blocks[i].set_neighbors(chunk_blocks)
				if(block[0].parent_chunk != block[0].neighboring_blocks[i].parent_chunk):
					block[0].neighboring_blocks[i].set_neighbors(block[0].neighboring_blocks[i].parent_chunk.chunk_blocks)
					#if(block[0].neighboring_blocks[i].is_accesable()):
					block[0].neighboring_blocks[i].parent_chunk.create_mesh()
	block[0].update_neighbors(chunk_blocks)

	if(to_local(block[1]).x == 0):
		block[0].update_neighbors(neighboring_chunk[1].right_border_blocks)
	elif(to_local(block[1]).x == 15):
		block[0].update_neighbors(neighboring_chunk[0].left_border_blocks)

	if(to_local(block[1]).z == 0):
		block[0].update_neighbors(neighboring_chunk[3].back_border_blocks)
	elif(to_local(block[1]).z == 15):
		block[0].update_neighbors(neighboring_chunk[2].front_border_blocks)
		
	create_mesh()

func set_new_block(block):
	if(typeof(block[0]) == 2):
		chunk_blocks[block[1]] = 0
		if(to_local(block[1]).x == 0):
			left_border_blocks[block[1]] = block[0]
		elif(to_local(block[1]).x == 15):
			right_border_blocks[block[1]] = block[0]
	
		if(to_local(block[1]).z == 0):
			front_border_blocks[block[1]] = block[0]
		elif(to_local(block[1]).z == 15):
			back_border_blocks[block[1]] = block[0]
	else:
		chunk_blocks[block[1]] = block[0]
		visible_blocks.append(block[0])
		block[0].update_neighbors(chunk_blocks)
		
		if(to_local(block[1]).x == 0):
			left_border_blocks[block[1]] = block[0]
			block[0].update_neighbors(neighboring_chunk[1].right_border_blocks)
		elif(to_local(block[1]).x == 15):
			right_border_blocks[block[1]] = block[0]
			block[0].update_neighbors(neighboring_chunk[0].left_border_blocks)
	
		if(to_local(block[1]).z == 0):
			front_border_blocks[block[1]] = block[0]
			block[0].update_neighbors(neighboring_chunk[3].back_border_blocks)
		elif(to_local(block[1]).z == 15):
			back_border_blocks[block[1]] = block[0]
			block[0].update_neighbors(neighboring_chunk[2].front_border_blocks)

func set_new_block_at_neighbor(block, block_list):
	set_new_block(block)
	if(typeof(block[0]) != 2):
		block[0].update_neighbors(block_list)
	create_mesh()

func remove_block(block):
	if(block != null):
		set_new_block([0, block.global_position])
		visible_blocks.erase(block)
		var new_needet_blocks = GD.map_generator.remove_block(self, block)
		for i in range(new_needet_blocks.size()):
			if(new_needet_blocks[i] != null):
				
				var for_neighbor = null
				if(new_needet_blocks[i][1].x - (chunk_coordinates.x * 16) == -1):
					neighboring_chunk[0].set_new_block_at_neighbor([new_needet_blocks[i][0], new_needet_blocks[i][1]], left_border_blocks)
					for_neighbor = 0
				elif(new_needet_blocks[i][1].x - (chunk_coordinates.x * 16) == 16):
					neighboring_chunk[1].set_new_block_at_neighbor([new_needet_blocks[i][0], new_needet_blocks[i][1]], right_border_blocks)
					for_neighbor = 1
				if(new_needet_blocks[i][1].z - (chunk_coordinates.y * 16) == -1):
					neighboring_chunk[2].set_new_block_at_neighbor([new_needet_blocks[i][0], new_needet_blocks[i][1]], front_border_blocks)
					for_neighbor = 2
				elif(new_needet_blocks[i][1].z - (chunk_coordinates.y * 16) == 16):
					neighboring_chunk[3].set_new_block_at_neighbor([new_needet_blocks[i][0], new_needet_blocks[i][1]], back_border_blocks)
					for_neighbor = 3
				
				if(for_neighbor == null):
					set_new_block(new_needet_blocks[i])
			else:
				if(typeof(block.neighboring_blocks[i]) != 2):
					block.neighboring_blocks[i].set_neighbors(chunk_blocks)
					if(block.parent_chunk != block.neighboring_blocks[i].parent_chunk):
						block.neighboring_blocks[i].set_neighbors(block.neighboring_blocks[i].parent_chunk.chunk_blocks)
						block.neighboring_blocks[i].parent_chunk.create_mesh()
		block.queue_free()
		create_mesh()

func get_y_at_center():
	for block in visible_blocks:
		if(block.position.x == 7 and block.position.z == 7):
			return block.position.y + 20
			
func direct_surrounded():
	surroundet = (
		(neighboring_chunk[0] != null or chunk_coordinates.x == 0) and 
		(neighboring_chunk[1] != null or chunk_coordinates.x == 255) and 
		(neighboring_chunk[2] != null or chunk_coordinates.y == 0) and 
		(neighboring_chunk[3] != null or chunk_coordinates.y == 255)
	)
	
	return surroundet

func full_surroundet():
	
	var full_surroundet = (
		(neighboring_chunk[0] == null or neighboring_chunk[0].surroundet) and 
		(neighboring_chunk[1] == null or neighboring_chunk[1].surroundet) and 
		(neighboring_chunk[2] == null or neighboring_chunk[2].surroundet) and 
		(neighboring_chunk[3] == null or neighboring_chunk[3].surroundet)
	)
	
	if(full_surroundet):
		set_neighbors()
	
	return full_surroundet

func update_neighbors(outer_border, inner_border):
	for chunk in neighboring_chunk:
		if(inner_border.find(chunk) == -1 and outer_border.find(chunk) == -1):
			if(chunk.get_parent() == GD.game_world):
				GD.game_world.call_deferred("remove_chunk", chunk)
			inner_border.append(chunk)

func to_local(coordinate:Vector3):
	var local_position = Vector3(coordinate.x - chunk_coordinates.x * 16, coordinate.y, coordinate.z - chunk_coordinates.y * 16)
	return local_position

func check_for_map_border():
	if(neighboring_chunk[0] == null):
		collision_array.append(Vector3(0, 0, 0))
		collision_array.append(Vector3(0, 256, 16))
		collision_array.append(Vector3(0, 0, 16))
		collision_array.append(Vector3(0, 256, 16))
		collision_array.append(Vector3(0, 0, 0))
		collision_array.append(Vector3(0, 256, 0))
	if(neighboring_chunk[1] == null):
		collision_array.append(Vector3(16, 0, 16))
		collision_array.append(Vector3(16, 256, 0))
		collision_array.append(Vector3(16, 0, 0))
		collision_array.append(Vector3(16, 256, 0))
		collision_array.append(Vector3(16, 0, 16))
		collision_array.append(Vector3(16, 256, 16))
	if(neighboring_chunk[2] == null):
		collision_array.append(Vector3(16, 0, 0))
		collision_array.append(Vector3(0, 256, 0))
		collision_array.append(Vector3(0, 0, 0))
		collision_array.append(Vector3(0, 256, 0))
		collision_array.append(Vector3(16, 0, 0))
		collision_array.append(Vector3(16, 256, 0))
	if(neighboring_chunk[3] == null):
		collision_array.append(Vector3(0, 0, 16))
		collision_array.append(Vector3(16, 256, 16))
		collision_array.append(Vector3(16, 0, 16))
		collision_array.append(Vector3(16, 256, 16))
		collision_array.append(Vector3(0, 0, 16))
		collision_array.append(Vector3(0, 256, 16))
