extends CanvasLayer
@onready var label_vida: Label = $Control/LabelVida


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.subscribe("cambio_vida", _cambio_vida, false)
	label_vida.text = "100"
	pass # Replace with function body.


func _cambio_vida(arg):
	label_vida.text = str(arg)

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#label_vida
	#pass
