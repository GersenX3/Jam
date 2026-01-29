# pajaro_enemy.gd
extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine
@onready var detection_area: Area2D = $DetectionArea

const SPEED = 300.0
var LIFE = 1

# Referencias para los estados
var player: Node2D = null  # Referencia al jugador cuando esté en rango
var can_see_player: bool = false  # Si el jugador está en el área de detección

# Proyectil
@export var projectile_scene: PackedScene  # Asignar desde el inspector
@export var projectile_speed: float = 200.0

func _ready() -> void:
	add_to_group("pajaro")
	
	# Conectar señales del área de detección
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_body_entered)
		detection_area.body_exited.connect(_on_detection_area_body_exited)

func _physics_process(delta: float) -> void:
	# El pájaro no se mueve, pero mantenemos esto por si acaso
	move_and_slide()

# ==============================================================================
# DETECCIÓN DEL JUGADOR
# ==============================================================================
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):  # Asegúrate que tu jugador esté en el grupo "player"
		player = body
		can_see_player = true
		print("Pájaro: Jugador detectado!")

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null
		can_see_player = false
		print("Pájaro: Jugador perdido!")

# ==============================================================================
# SISTEMA DE DISPARO
# ==============================================================================
func shoot_projectile() -> void:
	if not projectile_scene or not player:
		print("Pájaro: No se puede disparar (sin proyectil o sin jugador)")
		return
	
	# Crear el proyectil
	var projectile = projectile_scene.instantiate()
	
	# Calcular dirección hacia el jugador
	var direction = (player.global_position - global_position).normalized()
	
	# Posicionar el proyectil en la posición del pájaro
	projectile.global_position = global_position
	
	# Configurar el proyectil
	if projectile.has_method("setup"):
		projectile.setup(direction, projectile_speed)
	
	# Añadir al mundo (no como hijo del pájaro)
	get_tree().root.add_child(projectile)
	
	print("Pájaro: ¡Proyectil disparado!")

# ==============================================================================
# SISTEMA DE VIDA
# ==============================================================================
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
