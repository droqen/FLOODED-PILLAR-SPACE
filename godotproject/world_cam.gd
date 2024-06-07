extends Camera2D

@onready var player = $"../player"
var target : Vector2
func _ready() -> void:
	target = player.position
	position = target
func _physics_process(delta: float) -> void:
	if player.onfloor:
		target = lerp(target, player.position, 0.2)
	else:
		target = lerp(target, player.position, 0.02)
	position = lerp(position, target, 0.1)
