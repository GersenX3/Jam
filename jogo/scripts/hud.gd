extends Control
@onready var label: Label = $Label
var vida = 2

func _ready() -> void:
	EventBus.subscribe("cambio_vida", actualizar_vida, false)
	label.text = "Vida: " + str(vida)

func actualizar_vida(cambio):
	label.text = "Vida: " + str(vida - cambio)
	vida = vida - cambio
	if vida <= 0:
		EventBus.emit("Muerte", 0)
