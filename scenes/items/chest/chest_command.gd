extends Resource

func execute(_player: Player):
	Signals.emit_signal("modifier_selection")
