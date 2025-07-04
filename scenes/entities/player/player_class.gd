extends Resource
class_name PlayerClass

# Stats
@export var max_health: int
@export var health_regen: int	# Health regen per second
@export var attack: int	# Attack power/damage
@export var action_range: int	# Pixel range in which the player can performs actions
@export var speed: float	# Movement speed
@export var luck: float	# Affects rng rolls and other luck-based systems
@export var slots: int	# Number of starting inventory slots

# Animation
@export var animation_frames: SpriteFrames
