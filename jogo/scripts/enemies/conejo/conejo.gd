extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine
@onready var detection_area: Area2D = $DetectionArea

# ============================================================================
# VARIABLES CONFIGURABLES
# ============================================================================
@export_group("Movement")
@export var stalking_speed: float = 80.0  # Velocidad al perseguir (más lenta que el jugador)
@export var idle_speed: float = 30.0      # Velocidad al patrullar

@export_group("Detection")
@export var detection_range: float = 200.0  # Radio del área de detección

# ============================================================================
# VARIABLES INTERNAS
# ============================================================================
var LIFE = 1
var player: CharacterBody2D = null
var is_player_in_range: bool = false

func _ready() -> void:
	add_to_group("conejo")
	
	# Buscar al jugador
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		push_warning("Conejo: No se encontró al jugador en el grupo 'player'")
	
	# Configurar área de detección
	if detection_area:
		# Asegurarse de que tenga un CircleShape2D
		var shape = CircleShape2D.new()
		shape.radius = detection_range
		
		# Verificar si ya tiene un CollisionShape2D, si no, crearlo
		var collision_shape = detection_area.get_node_or_null("CollisionShape2D")
		if not collision_shape:
			collision_shape = CollisionShape2D.new()
			collision_shape.name = "CollisionShape2D"
			detection_area.add_child(collision_shape)
		
		collision_shape.shape = shape
		
		# Conectar señales
		detection_area.body_entered.connect(_on_detection_area_entered)
		detection_area.body_exited.connect(_on_detection_area_exited)

func _physics_process(delta: float) -> void:
	# Actualizar cooldowns de estados
	for child in state_machine.get_children():
		if child is State:
			child.update_cooldown(delta)
	
	move_and_slide()

# ============================================================================
# FUNCIONES DE DETECCIÓN
# ============================================================================
func _on_detection_area_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range = true

func _on_detection_area_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range = false

func is_player_looking_at_me() -> bool:
	"""
	Verifica si el jugador está mirando al conejo basado en last_move
	"""
	if not player:
		return false
	
	# Obtener dirección del jugador
	var player_direction = player.get("last_move")
	if not player_direction:
		return false
	
	# Calcular posición relativa
	var direction_to_rabbit = global_position - player.global_position
	
	# Si el conejo está a la izquierda y el jugador mira a la izquierda, o viceversa
	if player_direction == -1 and direction_to_rabbit.x < 0:
		return true
	elif player_direction == 1 and direction_to_rabbit.x > 0:
		return true
	
	return false

func get_direction_to_player() -> Vector2:
	"""
	Retorna la dirección normalizada hacia el jugador
	"""
	if not player:
		return Vector2.ZERO
	
	return (player.global_position - global_position).normalized()

# ============================================================================
# SISTEMA DE VIDA
# ============================================================================
func hazard():
	LIFE = LIFE - 1
	if LIFE <= 0:
		_trigger_death()

func vida():
	LIFE = LIFE + 1
	if LIFE >= 3:
		_trigger_death()

func _trigger_death():
	self.queue_free()
