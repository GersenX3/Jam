@tool
extends State

@export var idle_state: State
@export var walk_state: State
@export var fall_state: State
@export var jump_state: State
@export var hurt_state: State
@export var wall_jump_state: State

func enter():
	pass

func process_input(event: InputEvent) -> State:
	#if event.is_action_pressed("left"):
	#	return state
	return null

func process_physics(delta: float) -> State:
	if not character.is_on_floor():
		character.velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
		return null
		
	character.move_and_slide()
	return null

func exit():
	pass
