# ==============================================================================
# gato.gd
# ==============================================================================
# Enemigo gato que busca al jugador cuando entra a su espacio
# ==============================================================================
extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_daño: Area2D = $AreaDaño
@onready var detection_area: Area2D = $DetectionArea
@onready var state_machine: StateMachine = $StateMachine

const SPEED = 250.0
const GRAVITY = 980.0

var LIFE = 1
var player: CharacterBody2D = null
var direction: int = 1  # 1 = derecha, -1 = izquierda

func _ready() -> void:
	add_to_group("gato")
	
	# Conectar señales del área de detección
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_body_entered)
		detection_area.body_exited.connect(_on_detection_area_body_exited)
	
	# Conectar señales del área de daño
	if area_daño:
		area_daño.body_entered.connect(_on_area_daño_body_entered)

func _physics_process(delta: float) -> void:
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# Actualizar cooldowns de estados
	for child in state_machine.get_children():
		if child is State:
			child.update_cooldown(delta)
	
	move_and_slide()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		print("Gato: Jugador detectado")

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null
		print("Gato: Jugador perdido")

func _on_area_daño_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Gato: Golpeó al jugador")
		# Aquí puedes llamar a una función del jugador para hacerle daño
		# Por ejemplo: body.take_damage(1)

func flip_sprite(dir: int) -> void:
	"""Voltear el sprite según la dirección"""
	if dir > 0:
		anim.flip_h = false
	else:
		anim.flip_h = true
	direction = dir

func hazard() -> void:
	LIFE = LIFE - 1
	if LIFE <= 0:
		_trigger_death()

func vida() -> void:
	LIFE = LIFE + 1
	if LIFE >= 3:
		_trigger_death()

func _trigger_death() -> void:
	queue_free()
