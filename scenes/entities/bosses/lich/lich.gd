extends Boss
class_name LichBoss
	
@onready var enemy_generator = get_node("/root/Game/TilesViewportContainer/TilesViewport/YSort/EnemyGenerator")

var tile_position
	
func initialize(class_init: BossClass, position_init: Vector2i):
	super.initialize(class_init, position_init)
	text_controller.unblock(typing_text)
	tile_position = position_init

func _on_action_timer_timeout():
	for i in range(2):
		var spawn_pos: Vector2i
		spawn_pos.x = randi_range(tile_position.x - 1, tile_position.x + 1)
		spawn_pos.y = randi_range(tile_position.y - 5, tile_position.y + 5)
		enemy_generator.attempt_enemy_spawn("Skeleton", 1, spawn_pos)
