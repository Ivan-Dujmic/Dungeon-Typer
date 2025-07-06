extends RangeArea

@onready var range_indicator = $RangeIndicator

func set_range(radius: float):
	super.set_range(radius)
	range_indicator.radius = radius
	range_indicator.queue_redraw()
