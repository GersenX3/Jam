@tool
extends State

@export var idle_state: State


func enter():
	get_tree().reload_current_scene()
	pass


	
func process_input(event: InputEvent) -> State:
	
	return null

func process_physics(delta: float) -> State:
	return null

func exit():
	pass
