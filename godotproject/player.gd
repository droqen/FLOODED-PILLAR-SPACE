extends Node2D

enum { PINJUMPBUF, FLORBUF, DEADBUF }

var gameover : bool = false

var velocity : Vector2
var bufs : Bufs = Bufs.Make(self, [
	PINJUMPBUF,3, FLORBUF,3, DEADBUF,60,
])
var onfloor : bool = false
var waterjumps : int = 0
var inwater : bool = false
var drowned : bool = false

@onready var startpos = position

@onready var waterlevelnode = $"../Water"

var last_frame_y_velocity : float = 0

func _ready():
	reset.call_deferred()

func reset():
	drowned = false
	$SheetSprite.setup([10])
	if ThoughtMgr.active_respawn:
		position = ThoughtMgr.active_respawn.global_position
	else:
		position.x = startpos.x
		position.y = waterlevelnode.position.y + 150.0
	await get_tree().physics_frame
	position.y -= 1.0
	$mover.try_slip_move(self, $mover/solidcast, VERTICAL, 10.0)
	position.y -= 0.5
	velocity *= 0

func _physics_process(delta: float) -> void:
	
	#if Input.is_action_just_pressed("ui_cancel"):
		#position = Vector2(1041,-101)
	
	if not bufs.has(DEADBUF):
		if $spikesensor.get_overlapping_bodies():
			$SheetSprite.setup([60])
			bufs.on(DEADBUF)
		elif $drownsensor.get_overlapping_areas():
			$SheetSprite.setup([60])
			bufs.on(DEADBUF)
			drowned = true
	
	if bufs.read(DEADBUF) == 1:
		reset()
	
	var dpad = Vector2i(
		(1 if Input.is_key_pressed(KEY_RIGHT) else 0)
		-(1 if Input.is_key_pressed(KEY_LEFT) else 0),
		(1 if Input.is_key_pressed(KEY_DOWN) else 0)
		-(1 if Input.is_key_pressed(KEY_UP) else 0)
	)
	
	#if Input.is_key_pressed(KEY_G):
		#velocity = dpad * 10
	
	if gameover or bufs.has(DEADBUF): dpad *= 0
	var spr : SheetSprite = $SheetSprite
	var mover : NavdiBodyMover = $mover
	var caster = $mover/solidcast
	if onfloor:
		bufs.on(FLORBUF)
		waterjumps = 3
	if Input.is_action_just_pressed("jump"): bufs.on(PINJUMPBUF)
	if gameover or bufs.has(DEADBUF): bufs.clr(PINJUMPBUF)
	if bufs.try_eat([FLORBUF, PINJUMPBUF]):
		onfloor = false
		velocity.y = -1.5
		if last_frame_y_velocity < 0:
			velocity.y += last_frame_y_velocity
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
		
	var prevypos = position.y;
	mover.try_slip_move(self, caster, VERTICAL, -2.0)
	if not mover.try_slip_move(self, caster, VERTICAL, velocity.y+2.0):
		velocity.y = 0
	self.last_frame_y_velocity = position.y - prevypos
	onfloor = velocity.y >= 0 and mover.cast_fraction(self, caster, VERTICAL, 1.0) < 1.0

	$Label.text = "floor" if onfloor else "-----"
	
	for apple in $applesensor.get_overlapping_areas():
		if apple.has_method('eat'): apple.call('eat')
