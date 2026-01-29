@tool
extends State

@export var idle_state: State
@export var walk_state: State
@export var fall_state: State
@export var jump_state: State
@export var hurt_state: State
@export var wall_jump_state: State

# Velocidad de deslizamiento en la pared (más lento que caída normal)
const WALL_SLIDE_SPEED = 100.0
# Fuerza del salto desde la pared
const WALL_JUMP_VELOCITY = -700.0
# Impulso horizontal al saltar desde la pared
const WALL_JUMP_PUSH = 400.0

func enter():
	# Reproducir animación de wall slide
	if character.anim:
		character.anim.play("wall_jump")

func process_input(event: InputEvent) -> State:
	# Si presiona jump, saltar desde la pared
	if event.is_action_pressed("jump"):
		# Determinar la dirección de la pared
		var wall_normal = character.get_wall_normal()
		
		# Aplicar impulso vertical
		character.velocity.y = WALL_JUMP_VELOCITY
		# Aplicar impulso horizontal alejándose de la pared
		character.velocity.x = wall_normal.x * WALL_JUMP_PUSH
		
		# Voltear el sprite en la dirección del salto
		if character.anim:
			character.anim.flip_h = wall_normal.x < 0
		
		return jump_state
	
	return null

func process_physics(delta: float) -> State:
	# Si toca el suelo, ir a idle o walk
	if character.is_on_floor():
		var direction = Input.get_axis("left", "right")
		if direction != 0:
			return walk_state
		else:
			return idle_state
	
	# Si ya no está tocando la pared, caer
	if not character.is_on_wall():
		return fall_state
	
	# Obtener dirección del input
	var direction = Input.get_axis("left", "right")
	
	# Determinar qué lado de la pared está tocando
	var wall_normal = character.get_wall_normal()
	var wall_direction = -sign(wall_normal.x)
	
	# Si el jugador se aleja de la pared (input opuesto), soltar y caer
	if direction != 0 and sign(direction) != wall_direction:
		return fall_state
	
	# Aplicar deslizamiento lento en la pared
	character.velocity.y = min(character.velocity.y + character.get_gravity().y * delta, WALL_SLIDE_SPEED)
	
	# Mantener al jugador pegado a la pared
	character.velocity.x = 0
	
	# Voltear el sprite hacia la pared
	if character.anim:
		character.anim.flip_h = wall_direction < 0
	
	character.move_and_slide()
	return null

func exit():
	pass
