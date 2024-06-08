extends Node

@export var wave_noise_speed : float = 1.0
@export var wave_noise_amplitude = 1.0
@export var wave_noise : FastNoiseLite
@onready var maze : Maze = $"../Water"
@onready var maze_start_pos : Vector2 = maze.position
@onready var camera : Camera2D = $"../world_cam"

var t : float
var buf : int = 0

func _ready():
	randomize()
	wave_noise.seed = randi()
	maze.position.y = maze_start_pos.y + wave_noise.get_noise_1d(t) * wave_noise_amplitude
	$"../player".position.y = maze.position.y + 150

func _physics_process(delta: float) -> void:
	#maze.position.x = lerp(maze.position.x, camera.position.x - 90, 0.1)
	if buf > 0:
		buf -= 1
	else:
		var watercells : Array[Vector2i]
		watercells.append_array(maze.get_used_cells_by_id(0, maze.tid2coord(1)))
		watercells.append_array(maze.get_used_cells_by_id(0, maze.tid2coord(2)))
		for cell in watercells:
			maze.set_cell_tid(cell, randi()%2+1)
		buf = 20

	t += delta * wave_noise_speed
	maze.position.y = maze_start_pos.y + wave_noise.get_noise_1d(t) * wave_noise_amplitude
