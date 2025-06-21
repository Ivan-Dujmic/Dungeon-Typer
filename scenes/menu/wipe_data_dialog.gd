extends ConfirmationDialog

var text_controller

func _unhandled_input(event: InputEvent) -> void:
	text_controller._unhandled_input(event)
