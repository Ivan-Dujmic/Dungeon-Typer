extends Enemy
class_name FlamingSkullEnemy
	
func _physics_process(_delta):
	if target and global_position.distance_to(target.global_position) < 256:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

		Signals.emit_signal("entity_moved", self, global_position)

		animated_sprite.scale.x = -1 if velocity.x <= 0 else 1  # Looking direction
		animated_sprite.play("moving")
	else:
		animated_sprite.play("idle")
		velocity = Vector2.ZERO
