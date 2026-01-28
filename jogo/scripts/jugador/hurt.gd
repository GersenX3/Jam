@tool
extends State

@export var idle_state: State


func enter():
	EventBus.emit("cambio_vida", 1)
	pass


	
func process_input(event: InputEvent) -> State:
	
	return null

func process_physics(delta: float) -> State:
	return null

func exit():
	pass
