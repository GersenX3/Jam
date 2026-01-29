extends CharacterBody2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0

var LIFE = 1


func _ready() -> void:
	add_to_group("buho")


func hazard():
	LIFE = LIFE - 1
	if LIFE <= 0:
		_trigger_death()

func vida():
	LIFE = LIFE + 1
	if LIFE >= 3:
		_trigger_death()

func _trigger_death():
	self.queue_free()
	pass
