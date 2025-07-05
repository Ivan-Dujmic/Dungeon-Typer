extends VBoxContainer

@export var max_columns = 4
@export var max_rows = 2

# If number of slots gets reduced when the inventory is filled 
# then the item isn't trashed and the slot is removed when an item is removed
var slots: int = 0	# Current number of slots
var items: int = 0 # Number of items in inventory

func index_to_row_and_slot(index: int) -> Array[Node]: # -> [HBoxContainer, ColorRect]
	@warning_ignore("integer_division")
	var row_index = max_rows - int(index / max_columns) - 1
	var column_index = index % max_columns
	var row = get_child(row_index)
	var slot = null
	if len(row.get_children()) > column_index:
		slot = row.get_child(column_index)
	return [row, slot]
	
func _ready():
	for i in range(max_rows):
		var row = HBoxContainer.new()
		row.custom_minimum_size.x = 500
		row.add_theme_constant_override("separation", 40) 
		add_child(row)

func _add_slots(amount: int):
	var extra = max(0, items - slots)
	for i in range(slots + extra, slots + extra + amount):
		var rect = ColorRect.new()
		rect.color = Color(0.8, 0.8, 0.8, 0.2)
		rect.custom_minimum_size = Vector2(64, 64)
		var row = index_to_row_and_slot(i)[0]
		row.add_child(rect)

func _remove_slots(amount: int):
	var extra = max(0, items - slots)
	for i in range(slots + extra - 1, slots + extra - amount - 1, -1):
		var row_slot = index_to_row_and_slot(i)
		row_slot[0].remove_child(row_slot[1])
		row_slot[1].queue_free()
	
# Mark slots filled with items past the current max slots red
func _red(amount: int):
	for i in range(items - 1, items - amount - 1, -1):
		var slot = index_to_row_and_slot(i)[1]
		slot.color = Color(1, 0, 0, 0.2)
	
# Unmark red
func _white(amount: int):
	for i in range(slots, slots + amount):
		var slot = index_to_row_and_slot(i)[1]
		slot.color = Color(0.8, 0.8, 0.8, 0.2)

func resize(new_size: int):
	if new_size >= 0 and new_size <= max_rows * max_columns:
		if new_size > slots:
			if items <= slots:
				_add_slots(new_size - slots)
			if items > slots and items < new_size:
				_white(items - slots)
				_add_slots(new_size - items)
			if items >= new_size:
				_white(new_size - slots)
		elif new_size < slots:
			var diff = slots - new_size
			if new_size > items:
				_remove_slots(diff)
			else:
				var red = items - new_size
				_remove_slots(diff - red)
				_red(red)
		slots = new_size
	
# Returns true if successful (there is space)
func add_item(item: InventoryItem) -> bool:
	if items < slots:
		var slot = index_to_row_and_slot(items)[1]
		slot.add_child(item)
		items += 1
		return true
	else:
		return false
	
func remove_item(item: InventoryItem):
	var found = false
	var prev_slot
	for i in range(items):
		var slot = index_to_row_and_slot(i)[1]
		if not found:
			if slot.get_child(0) == item:
				found = true
				prev_slot = slot
		else:
			# Reparent doesn't reposition the items
			var child = slot.get_child(0)
			slot.remove_child(child)
			prev_slot.add_child(child)
			prev_slot = slot
	if items > slots:
		_remove_slots(1)
	items -= 1
