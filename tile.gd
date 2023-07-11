class_name Tile extends Control

signal tile_pressed(position: Vector2i)

@export var num = 0
@export var is_revealed = false
@export var is_bomb: bool = false
@export var is_flag: bool = false
@export var tile_position: Vector2i

@export var bomb_texture: Texture
@export var flag_texture: Texture

@onready var button: Button = $Button
@onready var label: Label = $Button/Label


func update():
	is_revealed = true
	if is_bomb:
		$Button.icon = bomb_texture
		pass
	else:
		if num != 0:
			label.text = str(num)

func toggle_flag():
	is_flag = !is_flag
	if is_flag:
		print("Flag on")
		$Button.icon = flag_texture
	else:
		$Button.icon = null

func _on_button_pressed():
	pass # Replace with function body.

func _on_button_gui_input(event):
	print(event)
	
	if event is InputEventMouseButton and event.pressed:
		if disabled:
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			tile_pressed.emit(tile_position)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			print("right")
			toggle_flag()


var disabled = false
func disable_button():
	disabled = true
	button.disabled = true
