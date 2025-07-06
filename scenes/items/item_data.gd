extends Resource
class_name ItemData

@export var name: String	# Unique identifier
@export var description: String	# For tooltips and such
@export var texture: Texture2D	# Both on ground and in inventory
@export var use_command: Script	# Use effect
@export var use_on_pickup: bool
