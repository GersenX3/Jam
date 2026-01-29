# DivingState.gd
extends State

@export_group("Diving Settings")
@export var max_dive_time: float = 3.0  # Tiempo máximo de diving

var dive_timer: float = 0.0
var target_position: Vector2
var has_hit_ground: bool = false

func enter():
	super.enter()
	character.anim.play("dive")
	character.current_dive_speed = 0.0
	dive_timer = 0.0
	has_hit_ground = false
	
	# Voltear hacia el jugador
	character.flip_to_player()
	
	# Guardar posición objetivo
	if character.player:
		target_position = character.player.global_position
	
	print("Búho: ¡Atacando en picada!")

func process_physics(delta: float) -> State:
	dive_timer += delta
	
	# Acelerar gradualmente
	character.current_dive_speed += character.DIVE_ACCELERATION * delta
	character.current_dive_speed = min(character.current_dive_speed, character.MAX_DIVE_SPEED)
	
	# Dirección hacia el objetivo
	var direction = (target_position - character.global_position).normalized()
	character.velocity = direction * character.current_dive_speed
	
	character.move_and_slide()
	
	# Verificar si llegó al objetivo o pasó el tiempo máximo
	var distance_to_target = character.global_position.distance_to(target_position)
	
	if distance_to_target < 20.0 or dive_timer >= max_dive_time:
		return state_machine.get_node_or_null("Returning")
	
	# Verificar si chocó con el suelo (sin dar al jugador)
	if character.is_on_floor() or character.is_on_wall():
		has_hit_ground = true
		# Ir a Stunned si falló
		var stunned_state = state_machine.get_node_or_null("Stunned")
		if stunned_state:
			return stunned_state
		else:
			# Si no hay estado stunned, volver directamente
			return state_machine.get_node_or_null("Returning")
	
	return null

func exit():
	super.exit()
	character.current_dive_speed = 0.0
