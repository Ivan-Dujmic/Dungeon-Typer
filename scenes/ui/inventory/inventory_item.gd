extends Sprite2D
class_name InventoryItem

@onready var ui = get_node("/root/Game/UI")

var typing_text
@export var data: ItemData

func initialize(data_init: ItemData):
	data = data_init
	texture = data.texture
	
	typing_text = ui.create_inventory_item_tt(self)
