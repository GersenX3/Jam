# cooldown_state.gd
extends State

var cooldown_timer: Timer
@export var cooldown_duracion: float = 1.5  # 1-2 segundos de espera

func _ready() -> void:
	# Crear timer para el cooldown
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_complete)
	add_child(cooldown_timer)

func enter():
	print("Pájaro: Estado COOLDOWN")
	if character.anim:
		character.anim.play("idle")
	
	# Iniciar el cooldown
	cooldown_timer.start(cooldown_duracion)

func exit():
	cooldown_timer.stop()

func process_physics(_delta: float) -> State:
	# Si pierde visión del jugador durante cooldown → Idle
	if not character.can_see_player:
		return state_machine.get_node("Idle")
	
	return null

func _on_cooldown_complete() -> void:
	# Cuando termina el cooldown, verificar si sigue viendo al jugador
	if character and state_machine:
		if character.can_see_player:
			# Vuelve a apuntar
			state_machine.transition_to(state_machine.get_node("Aiming"))
		else:
			# Vuelve a Idle
			state_machine.transition_to(state_machine.get_node("Idle"))
