extends Node

const Chunk = preload("res://Game/World/World_Parts/Chunk.tscn")
var Map_Generator = preload("res://Game/World/World_Generator/Map_Generator.gd")

#Werte_Variablen
#Weltgröße in Chunks
var world_length = 256
var world_width = 256

var renderdistance

#Referenzen
var mg
var game_world

var generation_thread
var render_thread
var mutex

var chunk_storage
var activ_chunks = {}

var outer_border_chunks = []
var inner_border_chunks = []

var markt_for_delete = []

var chunk_for_draw = null

var grafical_translation
var char_position

func _init(world, prepaird_chunks, actual_renderdistance):
	game_world = world
	renderdistance = actual_renderdistance
	chunk_storage = prepaird_chunks
	mg = Map_Generator.new()
	GD.map_generator = mg
	GD.world_generator = self
	
	mutex = Mutex.new()
	generation_thread = Thread.new()
	render_thread = Thread.new()



func set_start_position():
	var player_y = activ_chunks[player_position_to_grid(char_position)].get_y_at_center()
	game_world.set_player_position(Vector3(char_position.x, player_y, char_position.z))

#Hauptfunktionen
func start_render_loop():
	char_position = game_world.player_position
	init_chunk(player_position_to_grid(char_position))
	#check_neighboring_chunk(activ_chunks[player_position_to_grid(char_position)])
	
	generation_thread.start(self, "generation_loop")
	render_thread.start(self, "render_loop")
	

func generation_loop(args):
	while(true):
		markt_for_delete = []
		var not_outer_border_anymore = []
		var not_inner_border_anymore = []
		
		for i in range(outer_border_chunks.size()):
			var chunk = outer_border_chunks[i]
			if(chunk.initialised):
				if(in_render_distance(chunk.chunk_coordinates)):
					check_neighboring_chunk(chunk)
					if(chunk.direct_surrounded()):
						not_outer_border_anymore.append(chunk)
				else:
					check_for_new_border(chunk)
					markt_for_delete.append(chunk)
		
		for chunk in inner_border_chunks:
			if(chunk.full_surroundet()):
				not_inner_border_anymore.append(chunk)
				chunk.render_request = true
			
		for chunk in not_outer_border_anymore:
			inner_border_chunks.append(chunk)
			outer_border_chunks.erase(chunk)
			
		for chunk in not_inner_border_anymore:
			inner_border_chunks.erase(chunk)
		
		for chunk in markt_for_delete:
			outer_border_chunks.erase(chunk)
			
			mutex.lock()
			activ_chunks.erase(chunk.chunk_coordinates)
			chunk.markt_for_delete = true
			mutex.unlock()

			if(game_world.is_a_parent_of(chunk)):
				game_world.call_deferred("remove_chunk", chunk)
			chunk.clear_chunk()
			chunk_storage.append(chunk)

func render_loop(args):
	while(true):
		var chunks_for_draw = []

		mutex.lock()
		for key in activ_chunks.keys():
			if(activ_chunks[key].render_request):
				chunks_for_draw.append(activ_chunks[key])
		mutex.unlock()
		
		for chunk in chunks_for_draw:
			if(chunk != null):
				if(!chunk.vector_ready and !chunk.markt_for_delete):
					chunk.prepair_vector()
				elif(chunk.vector_full_ready()):
					chunk.create_mesh()
					chunk.visible = true
					if(chunk.get_parent() == null):
						game_world.call_deferred("add_chunk", chunk)

func in_render_distance(chunk_position):
	var dx = char_position.x - (chunk_position.x + 0.5) * 16
	var dz = char_position.z - (chunk_position.y + 0.5) * 16
	
	return (dx*dx + dz*dz) < renderdistance * renderdistance

func check_neighboring_chunk(chunk):	#[Links,Rechts,Vorne,Hinten]
	var n_chunks = chunk.neighboring_chunk
	var threads = [null, null, null, null]
	if(n_chunks[0] == null and in_render_distance(chunk.chunk_coordinates + Vector2(-1, 0)) and chunk.chunk_coordinates.x > 0):
		threads[0] = init_chunk(chunk.chunk_coordinates + Vector2(-1, 0))
	
	if(n_chunks[2] == null and in_render_distance(chunk.chunk_coordinates + Vector2(0, -1)) and chunk.chunk_coordinates.y > 0):
		threads[2] = init_chunk(chunk.chunk_coordinates + Vector2(0, -1))
	
	if(n_chunks[1] == null and in_render_distance(chunk.chunk_coordinates + Vector2(1, 0)) and chunk.chunk_coordinates.x < world_width - 1):
		threads[1] = init_chunk(chunk.chunk_coordinates + Vector2(1, 0))
	
	if(n_chunks[3] == null and in_render_distance(chunk.chunk_coordinates + Vector2(0, 1)) and chunk.chunk_coordinates.x < world_length - 1):
		threads[3] = init_chunk(chunk.chunk_coordinates + Vector2(0, 1))
	
	update_chunk_neighbors(chunk)

#Hilfsfunktionen
func check_for_new_border(chunk):
	var n_chunks = chunk.neighboring_chunk
	if(n_chunks[0] != null and inner_border_chunks.has(n_chunks[0])):
		n_chunks[0].update_neighbors(outer_border_chunks, inner_border_chunks)
		n_chunks[0].surroundet = false
		inner_border_chunks.erase(n_chunks[0])
		outer_border_chunks.append(n_chunks[0])
	
	if(n_chunks[2] != null and inner_border_chunks.has(n_chunks[2])):
		n_chunks[2].update_neighbors(outer_border_chunks, inner_border_chunks)
		n_chunks[2].surroundet = false
		inner_border_chunks.erase(n_chunks[2])
		outer_border_chunks.append(n_chunks[2])

	if(n_chunks[1] != null and inner_border_chunks.has(n_chunks[1])):
		n_chunks[1].update_neighbors(outer_border_chunks, inner_border_chunks)
		n_chunks[1].surroundet = false
		inner_border_chunks.erase(n_chunks[1])
		outer_border_chunks.append(n_chunks[1])

	if(n_chunks[3] != null and inner_border_chunks.has(n_chunks[3])):
		n_chunks[3].update_neighbors(outer_border_chunks, inner_border_chunks)
		n_chunks[3].surroundet = false
		inner_border_chunks.erase(n_chunks[3])
		outer_border_chunks.append(n_chunks[3])

func init_chunk(position):
	if(!activ_chunks.has(position)):
		var new_chunk = chunk_storage.pop_back()
#		new_chunk.markt_for_delete = false
#		new_chunk.vector_ready = false
#		new_chunk.chunk_coordinates = Vector2(position.x, position.y)
#		mg.init_chunk(new_chunk)
		new_chunk.initialise_chunk(Vector2(position.x, position.y))
		
		mutex.lock()
		activ_chunks[Vector2(position.x, position.y)] = new_chunk
		mutex.unlock()
		
		outer_border_chunks.append(new_chunk)

func update_chunk_neighbors(chunk):
	var chunk_coord = chunk.chunk_coordinates
	
	var neighbors = [null, null, null, null] #[Links,Rechts,Vorne,Hinten]
	
	if(activ_chunks.has(Vector2(chunk_coord.x - 1, chunk_coord.y))):
		neighbors[0] = activ_chunks[Vector2(chunk_coord.x - 1, chunk_coord.y)]
		neighbors[0].neighboring_chunk[1] = chunk
	
	if(activ_chunks.has(Vector2(chunk_coord.x + 1, chunk_coord.y))):
		neighbors[1] = activ_chunks[Vector2(chunk_coord.x + 1, chunk_coord.y)]
		neighbors[1].neighboring_chunk[0] = chunk
	
	if(activ_chunks.has(Vector2(chunk_coord.x, chunk_coord.y - 1))):
		neighbors[2] = activ_chunks[Vector2(chunk_coord.x, chunk_coord.y - 1)]
		neighbors[2].neighboring_chunk[3] = chunk
		
	if(activ_chunks.has(Vector2(chunk_coord.x, chunk_coord.y + 1))):
		neighbors[3] = activ_chunks[Vector2(chunk_coord.x, chunk_coord.y + 1)]
		neighbors[3].neighboring_chunk[2] = chunk
	
	chunk.neighboring_chunk = neighbors 

func player_position_to_grid(position):
	var grid_x = floor(position.x / 16)
	var grid_z = floor(position.z / 16)
	return Vector2(grid_x, grid_z)

func get_chunk_of_player():
	return activ_chunks[player_position_to_grid(char_position)]

func player_moved(position):
	char_position = position
