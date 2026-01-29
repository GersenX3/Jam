@tool
extends State

@export var idle_state: State
@export var walk_state: State
@export var fall_state: State
@export var jump_state: State
@export var hurt_state: State
@export var wall_jump_state: State

func enter():
	# Reproducir animación de idle
	if character.anim:
		character.anim.play("idle")

func process_input(event: InputEvent) -> State:
	# Si presiona jump, cambiar a estado de salto
	if event.is_action_pressed("jump") and character.is_on_floor():
		return jump_state
	return null

func process_physics(delta: float) -> State:
	# Si no está en el suelo, cambiar a fall
	if not character.is_on_floor():
		return fall_state
	
	# Aplicar fricción para detener al personaje
	character.velocity.x = move_toward(character.velocity.x, 0, character.SPEED * delta * 10)
	
	# Detectar input de movimiento
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		return walk_state
	
	# Aplicar gravedad
	character.velocity.y += character.get_gravity().y * delta
	
	character.move_and_slide()
	return null

func exit():
	pass
