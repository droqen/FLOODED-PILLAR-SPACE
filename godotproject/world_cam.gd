extends Camera2D

@onready var player = $"../player"
var target : Vector2
func _ready() -> void:
	target = player.position
	#position = target
var wasdrowned : bool = false
func _physics_process(delta: float) -> void:
	if player.drowned:
		target = lerp(target, player.position + Vector2.DOWN * 90, 0.1)
		wasdrowned = true
	else:
		if wasdrowned:
			target.x = player.position.x
			position.x = target.x
			wasdrowned = false
		if player.onfloor:
			target = lerp(target, player.position, 0.2)
		else:
			target = lerp(target, player.position, 0.02)
	position = lerp(position, target, 0.1)
