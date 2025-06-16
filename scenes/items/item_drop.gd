extends Area2D
class_name ItemDrop

@onready var sprite = $Sprite
@onready var ui = get_node("/root/Game/UI")

var typing_text
@export var data: ItemData

func initialize(data_init: ItemData, position_init: Vector2):
	data = data_init
	sprite.texture = data.texture
	
	global_position = Vector2(position_init)
	
	typing_text = ui.create_item_drop_tt(self)
