# idle_state.gd
extends State

func enter():
	print("Pájaro: Estado IDLE")
	if character.anim:
		character.anim.play("idle")  # Asegúrate de tener esta animación

func process_physics(_delta: float) -> State:
	# Transición: Si ve al jugador → Aiming
	if character.can_see_player:
		return state_machine.get_node("Aiming")
	
	return null
