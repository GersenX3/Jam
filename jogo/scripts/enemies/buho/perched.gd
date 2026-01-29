# PerchedState.gd
extends State
@onready var damage_area: Area2D = $"../../DamageArea"

func enter():
	super.enter()
	if character.anim:
		character.anim.play("perched")
	character.velocity = Vector2.ZERO
	damage_area.set_collision_mask_value(2,true)
	print("Búho: Posado en su lugar")

func process_physics(_delta: float) -> State:
	# Verificar si puede ver al jugador
	if character.can_see_player():
		# Buscar el estado Diving
		var diving_state = state_machine.get_node_or_null("Diving")
		if diving_state and diving_state.can_enter():
			return diving_state
	
	return null
