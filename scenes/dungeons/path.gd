class_name Path

# y level of a path
# width of a path ; if even then it should be the upper middle
# structure that is currently being built
# "x line" or "x in a row" or "time" for how long the structure has been built
# flags contain substructures, subtimes, any anything necessary for individual structures

var y: int
var width: int
var structure: String
var time: int
var flags: Dictionary

func _init(_y: int = 0, _width: int = 3, _structure: String = "", _time: int = 0, _flags: Dictionary = {}):
	y = _y
	width = _width
	structure = _structure
	time = _time
	flags = _flags

func finish_structure():
	structure = ""
	time = 0
	flags.clear()
