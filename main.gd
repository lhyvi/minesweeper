extends Node2D

var rows: int = 16
var cols: int = 16
var mine_count: int = 40

@onready var grid = $CanvasLayer/Grid
@export var tile_scene: PackedScene

## tiles[y][x]
var tiles: Array
var mines: Array


func _ready():
	instantiate_board()
			
func _tile_pressed(position: Vector2i):
	var tile = get_tile(position)
	if tile.is_flag:
		return
	if tile.is_bomb:
		trigger_lose()
		return
	if tile.num == 0:
		reveal_neighbours(position)
	
	tile.update()
	tile.disable_button()
	if check_win():
		trigger_win()
	print(position)

var normal_color = Color("#bbb")
var lose_color = Color("#eab")
var win_color = Color("#aea")

func check_win() -> bool:
	for row in tiles:
		for tile in row:
			if !tile.is_bomb && !tile.is_revealed:
				return false
	return true
	
func trigger_win():
	reveal_all()
	$ColorRect.color = win_color
func trigger_lose():
	reveal_all()
	$ColorRect.color = lose_color

func reveal_all():
	for row in tiles:
		for tile in row:
			if tile.is_flag:
				tile.toggle_flag()
			if tile.is_revealed == true:
				continue
			tile.is_revealed = true
			tile.update()
			tile.disable_button()

func ready_mines():
	mines = []
	while mines.size() < mine_count:
		var mine_pos = Vector2i(randi() % rows, randi() % cols)
		if mine_pos not in mines:
			mines.append(mine_pos)

func get_tile(tile_position: Vector2i) -> Tile:
	return tiles[tile_position.y][tile_position.x]

var offset = [1, 0, -1]

func get_neigh_mine(tile_position: Vector2i) -> int:
	var mc: int = 0
	for tile in get_neighbours(tile_position):
		if tile.is_bomb:
			mc += 1
	return mc

func get_neighbours(tile_position: Vector2i) -> Array:
	var neighbours = []
	for x in offset:
		if x + tile_position.x not in range(rows):
			continue
		for y in offset:
			
			if y + tile_position.y not in range(cols):
				continue
			if x == 0 && y == 0:
				continue
				
			var tile = get_tile(tile_position + Vector2i(x, y))
			neighbours.append(tile)
	return neighbours

func get_0_neighbours(tile_position: Vector2i) -> Array:
	var neighbours = []
	g0n(tile_position, neighbours)
	return neighbours

func g0n(tile_position: Vector2i, neighbours: Array):
	for neighbour in get_neighbours(tile_position):
		if neighbour not in neighbours:
			neighbours.append(neighbour)
			if neighbour.num == 0 && !neighbour.is_revealed && !neighbour.is_bomb:
				g0n(tile_position, neighbours)

func reveal_neighbours(tile_position: Vector2i):
	for tile in get_neighbours(tile_position):
		if tile.is_revealed:
			continue
		else:
			if tile.num == 0:
				tile.update()
				reveal_neighbours(tile.tile_position)
			else:
				tile.update()
			tile.disable_button()
			

func get_neigh_mine_from_tile(tile: Tile) -> int:
	return get_neigh_mine(tile.tile_position)

func instantiate_board():
	ready_mines()
	
	tiles = []
	for y in range(cols):
		tiles.append([])
	grid.columns = cols
	for y in range(0, cols):
		for x in range(0, rows):
			var tile: Tile = tile_scene.instantiate()
			var tile_position = Vector2i(x, y)
			tile.tile_position = tile_position
			if tile_position in mines:
				tile.is_bomb = true
			tile.connect("tile_pressed", Callable(self, "_tile_pressed"))
			grid.add_child(tile)
			tiles[y].append(tile)
	
	update_tile_num()

func update_tile_num():
	for row in tiles:
		for tile in row:
			var mine_count = get_neigh_mine_from_tile(tile)
			tile.num = mine_count

func reset_board():
	get_tree().reload_current_scene()
