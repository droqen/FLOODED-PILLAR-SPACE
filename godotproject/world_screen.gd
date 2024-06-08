extends Node2D

var fading : bool = false

func _ready():
	Events.got_apple.connect(func():
		$Water/hungry.enabled = false
		$"Water/the-end".enabled = true
		$"Water/the-end".activated.connect(func():
			fading = true
			$player.gameover = true
		)
	)

func _physics_process(delta: float) -> void:
	if fading and $level_ctr.modulate.a > 0:
		$level_ctr.modulate.a -= delta
