extends VBoxContainer

@export var max_columns = 4
@export var max_rows = 2

# If number of slots gets reduced when the inventory is filled 
# then the item isn't trashed and the slot is removed when an item is removed
var slots: int = 0	# Current number of slots
var data: Array[ItemData] = []	# Items

func _ready():
	for i in range(max_rows):
		var row = HBoxContainer.new()
		row.custom_minimum_size.x = 500
		row.add_theme_constant_override("separation", 40) 
		add_child(row)

func _add_slots(amount: int):
	var extra = max(0, len(data) - slots)
	for i in range(slots + extra, slots + extra + amount):
		var rect = ColorRect.new()
		rect.color = Color(0.8, 0.8, 0.8, 0.2)
		rect.custom_minimum_size = Vector2(64, 64)
		
		@warning_ignore("integer_division")
		var row_index = max_rows - int(i / max_columns) - 1
		var row = get_child(row_index)
		row.add_child(rect)

func _remove_slots(amount: int):
	var extra = max(0, len(data) - slots)
	for i in range(slots + extra - 1, slots + extra - amount - 1, -1):
		@warning_ignore("integer_division")
		var row_index = max_rows - int(i / max_columns) - 1
		var column_index = i % max_columns
		var row = get_child(row_index)
		var slot = row.get_child(column_index)
		row.remove_child(slot)
		slot.queue_free()
	
# Mark slots filled with items past the current max slots red
func _red(amount: int):
	for i in range(len(data) - 1, len(data) - amount - 1, -1):
		@warning_ignore("integer_division")
		var row_index = max_rows - int(i / max_columns) - 1
		var column_index = (i) % max_columns
		var slot = get_child(row_index).get_child(column_index)
		slot.color = Color(1, 0, 0, 0.2)
	
# Unmark red
func _white(amount: int):
	for i in range(slots, slots + amount):
		@warning_ignore("integer_division")
		var row_index = max_rows - int(i / max_columns) - 1
		var column_index = (i) % max_columns
		var slot = get_child(row_index).get_child(column_index)
		slot.color = Color(0.8, 0.8, 0.8, 0.2)

func resize(new_size: int):
	if new_size >= 0 and new_size <= max_rows * max_columns:
		if new_size > slots:
			if len(data) <= slots:
				_add_slots(new_size - slots)
			if len(data) > slots and len(data) < new_size:
				_white(len(data) - slots)
				_add_slots(new_size - len(data))
			if len(data) >= new_size:
				_white(new_size - slots)
		elif new_size < slots:
			var diff = slots - new_size
			if new_size > len(data):
				_remove_slots(diff)
			else:
				var red = len(data) - new_size
				_remove_slots(diff - red)
				_red(red)
		slots = new_size
	
# Returns true if successful (there is space)
func add_item(item: ItemData) -> bool:
	if len(data) < slots:
		data.append(item)
		return true
	else:
		return false
	
func remove_item(index: int):
	if len(data) > slots:
		_remove_slots(1)
	data.remove_at(index)
