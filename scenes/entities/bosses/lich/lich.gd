extends Boss
class_name LichBoss
	
@onready var enemy_generator = get_node("/root/Game/TilesViewportContainer/TilesViewport/YSort/EnemyGenerator")

var tile_position
	
func initialize(class_init: BossClass, position_init: Vector2i):
	super.initialize(class_init, position_init)
	text_controller.unblock(typing_text)
	tile_position = position_init

func _on_action_timer_timeout():
	var spawns: Array[Vector2i] = []
	for i in range(2):
		var spawn_pos: Vector2i
		# Don't spawn two at the same location
		while true:
			spawn_pos.x = randi_range(tile_position.x - 1, tile_position.x + 1)
			spawn_pos.y = randi_range(tile_position.y - 4, tile_position.y + 4)
			var found = false
			for spawn in spawns:
				if spawn_pos == spawn:
					found = true
					break
			if not found:
				break
		spawns.append(spawn_pos)
	for spawn in spawns:
		if randf() < 0.7:
			enemy_generator.attempt_enemy_spawn("Skeleton", 1, spawn)
		else:
			enemy_generator.attempt_enemy_spawn("Flaming Skull", 1, spawn)
