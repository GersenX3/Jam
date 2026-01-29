@tool
extends State

@export var idle_state: State
@export var walk_state: State
@export var fall_state: State
@export var jump_state: State
@export var hurt_state: State
@export var wall_jump_state: State

func enter():
	# Reproducir animación de caminar
	if character.anim:
		character.anim.play("walk")

func process_input(event: InputEvent) -> State:
	# Si presiona jump, cambiar a estado de salto
	if event.is_action_pressed("jump") and character.is_on_floor():
		return jump_state
	return null

func process_physics(delta: float) -> State:
	# Si no está en el suelo, cambiar a fall
	if not character.is_on_floor():
		return fall_state
	
	# Obtener dirección del input
	var direction = Input.get_axis("left", "right")
	
	# Si no hay input, volver a idle
	if direction == 0:
		return idle_state
	
	# Aplicar movimiento horizontal
	character.velocity.x = direction * character.SPEED
	
	# Voltear el sprite según la dirección
	if direction != 0 and character.anim:
		character.anim.flip_h = direction < 0
	
	# Aplicar gravedad
	character.velocity.y += character.get_gravity().y * delta
	
	character.move_and_slide()
	return null

func exit():
	pass
