extends Node2D

var lockinput : int = 0

func _ready() -> void:
	hide()
	Events.got_apple.connect(func():
		get_tree().paused = true
		process_mode = PROCESS_MODE_WHEN_PAUSED # yep
		show()
		lockinput = 15
	)

func _physics_process(delta: float) -> void:
	if visible:
		if lockinput > 0:
			lockinput -= 1
		elif Input.is_action_just_pressed("jump"):
			await get_tree().create_timer(0.1)
			hide()
			get_tree().paused = false
