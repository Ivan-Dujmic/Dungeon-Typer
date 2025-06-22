extends Node

signal entity_moved(entity: Entity, new_position: Vector2)

# Just for the sake of warning suppresion (the entity_moved signal isn't being used in this class)
func nop():
	if false: emit_signal("entity_moved", self, Vector2.ZERO)
