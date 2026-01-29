@tool
extends State

@export var idle_state: State
@export var walk_state: State
@export var fall_state: State
@export var jump_state: State
@export var hurt_state: State
@export var wall_jump_state: State

func enter():
	# Reproducir animación de caída
	if character.anim:
		character.anim.play("fall")

func process_input(event: InputEvent) -> State:
	return null

func process_physics(delta: float) -> State:
	# Si toca una pared y está presionando hacia ella, cambiar a wall_jump
	# PERO SOLO SI EL COOLDOWN HA TERMINADO
	if character.is_on_wall() and character.wall_jump_cooldown <= 0:
		var direction = Input.get_axis("left", "right")
		var wall_normal = character.get_wall_normal()
		# Verificar si está presionando hacia la pared
		if direction != 0 and sign(direction) == -sign(wall_normal.x):
			return wall_jump_state
	
	# Si toca el suelo, cambiar a idle o walk según el input
	if character.is_on_floor():
		var direction = Input.get_axis("left", "right")
		if direction != 0:
			return walk_state
		else:
			return idle_state
	
	# Permitir movimiento horizontal en el aire SOLO SI el cooldown ha terminado
	var direction = Input.get_axis("left", "right")
	if direction != 0 and character.wall_jump_cooldown <= 0:
		character.velocity.x = direction * character.SPEED
		# Voltear el sprite según la dirección
		if character.anim:
			character.anim.flip_h = direction < 0
	else:
		# Si hay cooldown activo o no hay input, reducir velocidad gradualmente
		character.velocity.x = move_toward(character.velocity.x, 0, character.SPEED * delta * 2)
	
	# Aplicar gravedad
	character.velocity.y += character.get_gravity().y * delta
	
	character.move_and_slide()
	return null

func exit():
	pass
