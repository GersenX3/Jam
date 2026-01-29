# shooting_state.gd
extends State

func enter():
	print("Pájaro: Estado SHOOTING")
	
	# Ejecutar el disparo
	if character.has_method("shoot_projectile"):
		character.shoot_projectile()
	
	# Reproducir animación de disparo (opcional)
	if character.anim:
		character.anim.play("shoot")  # O usa "idle"
	
	# Transición inmediata a Cooldown
	state_machine.transition_to(state_machine.get_node("Cooldown"))

func process_physics(_delta: float) -> State:
	# Este estado es instantáneo, no debería quedarse aquí
	return null
