extends GridContainer

@onready var player = get_node("/root/Game/TilesViewportContainer/TilesViewport/YSort/Player")

@onready var stats: Dictionary[String, Label] = {
	"health_regen": $HealthRegenLabelValue,
	"attack": $AttackLabelValue,
	"speed": $SpeedLabelValue,
	"luck": $LuckLabelValue,
}

func _update_stat(stat: String, value):
	stats[stat].text = str(value)
	
func _ready():
	player.connect("update_stat", Callable(self, "_update_stat"))
