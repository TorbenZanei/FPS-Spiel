extends Node

const TEXTURE_SHEET_WIDTH = 8
const TEXTURE_TILE_SIZE = 1.0 / TEXTURE_SHEET_WIDTH

const BLOCK_TYP = [
	[0],					#Luft
	[1],					#Boden
	[2]						#Steinblock
]

var game_world
var map_generator
var world_generator

var block_texture_data = [[],[3, 3, 0, 2, 3, 3]] #[Links,Rechts, Oben, Unten,Vorne,Hinten]
var block_material = load("res://Game/World/World_Parts/test_material_1.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
