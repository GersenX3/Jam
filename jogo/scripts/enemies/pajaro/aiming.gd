# aiming_state.gd
extends State

var aim_timer: Timer
@export var aim_duration: float = 0.4  # Tiempo de apuntado (0.3-0.5s)

func _ready() -> void:
	# Crear timer para el apuntado
	aim_timer = Timer.new()
	aim_timer.one_shot = true
	aim_timer.timeout.connect(_on_aim_complete)
	add_child(aim_timer)

func enter():
	print("Pájaro: Estado AIMING")
	if character.anim:
		character.anim.play("aiming")  # Crea esta animación o usa "idle"
	
	# Iniciar timer de apuntado
	aim_timer.start(aim_duration)

func exit():
	# Detener el timer si salimos antes de que termine
	aim_timer.stop()

func process_physics(_delta: float) -> State:
	# Si pierde visión del jugador antes de disparar → Idle
	if not character.can_see_player:
		return state_machine.get_node("Idle")
	
	return null

func _on_aim_complete() -> void:
	# Cuando termina de apuntar → Shooting
	if character and state_machine:
		state_machine.transition_to(state_machine.get_node("Shooting"))
