extends Spatial

const World_Generator = preload("res://Game/World/World_Generator/World_Generator.gd")
const Chunk = preload("res://Game/World/World_Parts/Chunk.tscn")


var world_generator

signal new_chunk_ready

#Absolute größe in Blöcken
var map_height_b = 128
var sky_height_b = 64
var map_length_b = 4096
var map_width_b = 4096

var map_start_vector
var world_width = 256
var world_length = 256
var world_height = 8
var world_sky_height = 4

var renderdistance = 175

var chunk_dictionary = {}

var player_position

var prepaird_chunk  
var chunks_ready = 0
var world_ready = false
#var grafical_translation

onready var select_marker = $Select_Marker

# Called when the node enters the scene tree for the first time.
func _ready():
	var needet_chunks = []
	var amount = int(floor(pow((renderdistance * 2) / 16, 2)))
	for i in range(amount):
		var new_chunk = Chunk.instance()
		new_chunk.connect("chunk_ready", self, "world_ready")
		needet_chunks.append(new_chunk)
		
	
	world_generator = World_Generator.new(self, needet_chunks, renderdistance)
	GD.game_world = self
	add_child(world_generator)
	player_position = Vector3(2032,128,2032)
	start_world()
	
	$Charakter.select_marker = select_marker
	
	#player_position = Vector3(player_position.x, y_position, player_position.z)
	
	
	#$Charakter.translation = player_position

func start_world():
	world_generator.start_render_loop()
	
func world_ready():
	if(!world_ready):
		if(chunks_ready < 5):
			chunks_ready += 1
		else:
			world_ready = true
			world_generator.set_start_position()
			

func add_chunk(chunk):
	add_child(chunk)

func remove_chunk(chunk):
	remove_child(chunk)

func set_player_position(position):
	$Charakter.translation = position

func update_chunks_needet():
	world_generator.char_moved(Vector3(player_position[2],player_position[0], player_position[1]))

func charakter_moved(position):
	if(world_ready):
		player_position = position
		world_generator.player_moved(position)
