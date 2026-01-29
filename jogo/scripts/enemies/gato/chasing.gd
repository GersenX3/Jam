# ==============================================================================
# gato_chasing_state.gd
# ==============================================================================
# Estado Chasing: El gato persigue al jugador
# Transiciones:
# - Si el área de daño toca al jugador → AttackState
# - Si el jugador sale del rango de detección → IdleState
# ==============================================================================
extends State

@export var chase_speed: float = 300.0

func enter() -> void:
	super.enter()
	print("Gato: Estado CHASING")
	character.anim.play("run")

func exit() -> void:
	character.velocity.x = 0

func process_physics(delta: float) -> State:
	# Si perdimos al jugador → Volver a Idle
	if character.player == null:
		return get_node("../Idle")
	
	# Verificar si estamos tocando al jugador con el área de daño
	var bodies = character.area_daño.get_overlapping_bodies()
	for body in bodies:
		print(bodies)
		if body.is_in_group("player"):
			return get_node("../Attack")
	
	# Perseguir al jugador
	var direction = sign(character.player.global_position.x - character.global_position.x)
	
	if direction != 0:
		character.velocity.x = direction * chase_speed
		character.flip_sprite(direction)
	
	return null
