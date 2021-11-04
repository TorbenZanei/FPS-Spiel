extends Node

var Block = preload("res://Game/World/World_Generator/Block.gd")

var height_map 
var edited_blocks = {}

var corner_blocks = {}

var map_width = 4096
var map_length = 4096

func _init():
	var file = File.new()
	if(file.file_exists("user://height_map.png")):
		height_map = Image.new()
		height_map.load("user://height_map.png")
	else:
		height_map = generate_height_map()
	
	height_map.lock()

#Funktionen zur Laufzeit
func init_chunk(chunk):
	var visible_blocks = []
	var block_dictionary = {}
	
	var left_border_blocks = {}
	var right_border_blocks = {}
	var front_border_blocks = {}
	var back_border_blocks = {}
	
	var chunk_x = chunk.chunk_coordinates.x * 16
	var chunk_z = chunk.chunk_coordinates.y * 16
	#print(String(chunk_x) + " " + String(chunk_z))
	
	var phm = []					#processd_height_map: Die map die für diesen Chunk 
									#auß dem png erzeugt wurde
	
	#die height map des chunks aus der png erzeugen
	for x in range(- 1,17):
		var row = []
		for z in range(- 1,17):
			var noise_sample = height_map.get_pixel(x + chunk_x, z + chunk_z)[0]
			noise_sample = int(((noise_sample + 0.5)) * 64 + 64)
			row.append(noise_sample)
		phm.append(row)
	
	#die benötigten blöcke erzeugen
	for x in range(1,17):
		for z in range(1,17):
			var neighbors = [phm[x][z-1], phm[x + 1][z], phm[x][z+1], phm[x-1][z]]
			
			var upper_end
			var lower_end 
			
			if(neighbors.max() - phm[x][z] <= 0):
				upper_end = phm[x][z] + 2
			else:
				upper_end = neighbors.max() + 1
			 
			if(phm[x][z] - neighbors.min() <= 0):
				lower_end = phm[x][z]
			else:
				lower_end = neighbors.min() + 1
			
			var global_x = x + chunk_x - 1
			var global_y = z + chunk_z - 1
			
			var new_block
			
			#setzt  gebrauchte Blöcke und notiert sie als Chunkkante wenn nötigt
			for i in range(lower_end, upper_end):
				if(phm[x][z] < i):
					new_block = 0
				else:
					new_block = init_block(Vector3(x - 1, i, z - 1), Vector3(global_x, i, global_y), chunk, 1)
					visible_blocks.append(new_block)
				
				block_dictionary[Vector3(global_x, i, global_y)] = new_block
				
				if(x == 1):
					left_border_blocks[Vector3(global_x, i, global_y)] = new_block
				elif(x == 16):
					right_border_blocks[Vector3(global_x, i, global_y)] = new_block
				
				if(z == 1):
					front_border_blocks[Vector3(global_x, i, global_y)] = new_block
				elif(z == 16):
					back_border_blocks[Vector3(global_x, i, global_y)] = new_block
	
	#die Blocknachbarn setzen
	for block in visible_blocks:
		block.set_neighbors(block_dictionary)
	
	chunk.left_border_blocks = left_border_blocks
	chunk.right_border_blocks = right_border_blocks
	chunk.front_border_blocks = front_border_blocks
	chunk.back_border_blocks = back_border_blocks
	
	chunk.visible_blocks = visible_blocks
	chunk.chunk_blocks = block_dictionary
	
	return [left_border_blocks, right_border_blocks, front_border_blocks, back_border_blocks, visible_blocks, block_dictionary]

func init_block(position, global_position, chunk, block_id):
	
	var new_block = Block.new()
	new_block.block_id = block_id
	new_block.terrain_type = GD.BLOCK_TYP[block_id][0]
	new_block.position = position
	new_block.global_position = global_position
	new_block.parent_chunk = chunk
	
	return new_block

#benötigt update
func generate_block(chunk, position):
	
	var x = position.x
	var z = position.z
	var parent_chunk = chunk
	
	if(x == -1):
		x = 15
		parent_chunk = chunk.neighboring_chunk[0]
	elif(x == 16):
		x = 0
		parent_chunk = chunk.neighboring_chunk[1]
			
	if(z == -1):
		z = 15
		parent_chunk = chunk.neighboring_chunk[2]
	elif(z == 16):
		z = 0
		parent_chunk = chunk.neighboring_chunk[3]
	
	var chunk_x = parent_chunk.chunk_coordinates.x * 16
	var chunk_z = parent_chunk.chunk_coordinates.y * 16
	
	var new_block = null
	if(edited_blocks.has(Vector3(x + chunk_x, position.y, z + chunk_z))):
		new_block = edited_blocks[Vector3(x + chunk_x, position.y, z + chunk_z)]
		new_block = [new_block, new_block.get_global_position()]
	else:
		var noise_sample = height_map.get_pixel(x + chunk_x, z + chunk_z)[0]
		noise_sample = int(((noise_sample + 0.5)) * 64 + 64)
		new_block = Block.new()
		new_block.parent_chunk = parent_chunk
		new_block.position = Vector3(x, position.y, z)
		if(position.y <= noise_sample):
			new_block.block_id = 1
		else:
			new_block.block_id = 0
		new_block.terrain_type = GD.BLOCK_TYP[new_block.block_id][0]
		
		edited_blocks[Vector3(x + chunk_x, position.y, z + chunk_z)] = new_block
		new_block = [new_block, Vector3(x + chunk_x, position.y, z + chunk_z)]
			
	return new_block

func remove_block(chunk, block):
	var chunk_x = chunk.chunk_coordinates.x * 16
	var chunk_z = chunk.chunk_coordinates.y * 16
	edited_blocks[Vector3(block.position.x + chunk_x, block.position.y, block.position.z + chunk_z)] = 0
	
	var new_needet_blocks = [null, null, null, null, null, null]
	
	if(block.neighboring_blocks[0] == null):
		new_needet_blocks[0] = generate_block(chunk, block.position + Vector3(-1, 0, 0))
	if(block.neighboring_blocks[1] == null):
		new_needet_blocks[1] = generate_block(chunk, block.position + Vector3(1, 0, 0))
	if(block.neighboring_blocks[2] == null):
		new_needet_blocks[2] = generate_block(chunk, block.position + Vector3(0, 1, 0))
	if(block.neighboring_blocks[3] == null):
		new_needet_blocks[3] = generate_block(chunk, block.position + Vector3(0, -1, 0))
	if(block.neighboring_blocks[4] == null):
		new_needet_blocks[4] = generate_block(chunk, block.position + Vector3(0, 0, -1))
	if(block.neighboring_blocks[5] == null):
		new_needet_blocks[5] = generate_block(chunk, block.position + Vector3(0, 0, 1))
	
	return new_needet_blocks

func add_block(chunk, position):
	
	var x = position.x
	var z = position.z
	var parent_chunk = chunk
	
	if(x == -1):
		x = 15
		parent_chunk = chunk.neighboring_chunk[0]
	elif(x == 16):
		x = 0
		parent_chunk = chunk.neighboring_chunk[1]
			
	if(z == -1):
		z = 15
		parent_chunk = chunk.neighboring_chunk[2]
	elif(z == 16):
		z = 0
		parent_chunk = chunk.neighboring_chunk[3]
	
	var chunk_x = parent_chunk.chunk_coordinates.x * 16
	var chunk_z = parent_chunk.chunk_coordinates.y * 16
	
	var new_block = null
	new_block = Block.new()
	new_block.block_id = 0
	new_block.terrain_type = GD.BLOCK_TYP[2][0]
	new_block.parent_chunk = parent_chunk
	
	new_block.position = Vector3(x, position.y, z)
	edited_blocks[Vector3(x + chunk_x, position.y, z + chunk_z)] = new_block
	
	new_block = [new_block, Vector3(x + chunk_x, position.y, z + chunk_z)]
	return new_block

func generate_needet_neighbors(chunk, block):
	var chunk_x = chunk.chunk_coordinates.x * 16
	var chunk_z = chunk.chunk_coordinates.y * 16
	
	var new_needet_blocks = [null, null, null, null, null, null]
	
	if(block.neighboring_blocks[0] == null):
		new_needet_blocks[0] = generate_block(chunk, block.position + Vector3(-1, 0, 0))
	if(block.neighboring_blocks[1] == null):
		new_needet_blocks[1] = generate_block(chunk, block.position + Vector3(1, 0, 0))
	if(block.neighboring_blocks[2] == null):
		new_needet_blocks[2] = generate_block(chunk, block.position + Vector3(0, 1, 0))
	if(block.neighboring_blocks[3] == null):
		new_needet_blocks[3] = generate_block(chunk, block.position + Vector3(0, -1, 0))
	if(block.neighboring_blocks[4] == null):
		new_needet_blocks[4] = generate_block(chunk, block.position + Vector3(0, 0, -1))
	if(block.neighboring_blocks[5] == null):
		new_needet_blocks[5] = generate_block(chunk, block.position + Vector3(0, 0, 1))
	
	return new_needet_blocks

#Funktionen zur Map generierung
func generate_height_map():
	var open_simplex_noise = OpenSimplexNoise.new()
	open_simplex_noise.seed = 15896478546
	
	open_simplex_noise.octaves = 4
	open_simplex_noise.period = 64
	open_simplex_noise.lacunarity = 1.5
	open_simplex_noise.persistence = 0.75
	
	var image = open_simplex_noise.get_image(map_width, map_length)
	image.save_png("user://height_map.png")
	
	return image
