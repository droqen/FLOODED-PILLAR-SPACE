extends Node2D

enum { PINJUMPBUF, FLORBUF, }

var velocity : Vector2
var bufs : Bufs = Bufs.Make(self, [
	PINJUMPBUF,3, FLORBUF,3,
])
var onfloor : bool = false
var waterjumps : int = 0
var inwater : bool = false

@onready var startpos = position

func _physics_process(delta: float) -> void:
	if $drownsensor.get_overlapping_areas():
		position = startpos
		velocity *= 0
	
	var dpad = Vector2i(
		(1 if Input.is_key_pressed(KEY_RIGHT) else 0)
		-(1 if Input.is_key_pressed(KEY_LEFT) else 0),
		(1 if Input.is_key_pressed(KEY_DOWN) else 0)
		-(1 if Input.is_key_pressed(KEY_UP) else 0)
	)
	var spr : SheetSprite = $SheetSprite
	var mover : NavdiBodyMover = $mover
	var caster = $mover/solidcast
	if onfloor:
		bufs.on(FLORBUF)
		waterjumps = 3
	if Input.is_action_just_pressed("jump"): bufs.on(PINJUMPBUF)
	if bufs.try_eat([FLORBUF, PINJUMPBUF]):
		onfloor = false
		velocity.y = -1.5
	elif waterjumps > 0 and inwater and bufs.try_eat([PINJUMPBUF]):
		# waterjump
		velocity.y = -0.5 -0.4 * waterjumps
		waterjumps -= 1
		inwater = false
	velocity.x = move_toward(velocity.x, dpad.x, 0.1 if onfloor else 0.05)
	velocity.y = move_toward(velocity.y, 2.5, 0.05 if (velocity.y > 0 or Input.is_action_pressed("jump")) else 0.15)
	if $buoyansensor.get_overlapping_areas():
		if velocity.y > 0 and not inwater:
			inwater = true
			velocity.y = 0
		if inwater:
			velocity.y *= 0.9
	else:
		inwater = false
	if dpad.x: spr.flip_h = dpad.x < 0
	if not mover.try_slip_move(self, caster, HORIZONTAL, velocity.x):
		velocity.x = 0
	onfloor = velocity.y > 0 and mover.cast_fraction(self, caster, VERTICAL, velocity.y) < 1.0
	if not mover.try_slip_move(self, caster, VERTICAL, velocity.y):
		velocity.y = 0

