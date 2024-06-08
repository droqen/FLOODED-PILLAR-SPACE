extends Area2D

func eat():
	queue_free()
	Events.got_apple.emit()
