extends Node2D

signal activated

@export var enabled : bool = true

var printdelay : int = 0

@export var base_printdelay : int = 2
@export var midi_printdelay : int = 20
@export var long_printdelay : int = 50
@export var midi_chars : String = ",;:"
@export var long_chars : String = "!.?"
@export var linebreak_midi : bool = true
@export var linebreak_long : bool = false


func _ready():
	$Label.visible_characters = 0
	$Area2D.connect("area_entered", func(_area):
		if enabled:
			emit_signal("activated")
			ThoughtMgr.active_thought = self
			if has_node("respawn"):
				ThoughtMgr.active_respawn = $respawn
	)

func _physics_process(delta: float) -> void:
	if self == ThoughtMgr.active_thought:
		if printdelay > 0:
			printdelay -= 1
		else:
			if $Label.visible_characters >= 0:
				if $Label.visible_characters < $Label.text.length():
					var c = $Label.text[$Label.visible_characters]
					if long_chars.contains(c): printdelay = long_printdelay
					elif midi_chars.contains(c): printdelay = midi_printdelay
					elif c == '\n':
						if linebreak_long: printdelay = long_printdelay
						elif linebreak_midi: printdelay = midi_printdelay
						else: printdelay = base_printdelay
					else: printdelay = base_printdelay
				$Label.visible_characters += 1
	else:
		if $Label.visible_ratio > 0:
			$Label.visible_ratio -= delta
		printdelay = 0
