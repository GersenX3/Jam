# ==============================================================================
# CameraShake.gd - Singleton de efectos de cámara
# ==============================================================================
# Singleton que maneja diferentes tipos de shake/vibración de cámara.
# Busca automáticamente la cámara activa en la escena y aplica efectos visuales.
#
# EJEMPLOS DE USO:
#
# 1. Shake simple al recibir daño:
#    CameraShake.shake_camera(CameraShake.ShakeType.Random, 20.0)
#
# 2. Shake con ruido para explosión:
#    CameraShake.shake_camera(CameraShake.ShakeType.Noise, 40.0, 30.0)
#
# 3. Sway suave para movimiento de ambiente:
#    CameraShake.shake_camera(CameraShake.ShakeType.Sway, 15.0, 1.0, 1.0, 60.0, 10.0, 2.0)
#
# TIPOS DE SHAKE:
# - Random: Sacudida aleatoria rápida (ideal para impactos)
# - Noise: Sacudida basada en Perlin noise (ideal para vibraciones)
# - Sway: Movimiento suave ondulante (ideal para ambientes)
# ==============================================================================

extends Node

# ==============================================================================
# ENUMS
# ==============================================================================

enum ShakeType {
	Random,  # Sacudida aleatoria
	Noise,   # Sacudida con ruido Perlin
	Sway     # Movimiento suave ondulante
}

# ==============================================================================
# PARÁMETROS CONFIGURABLES
# ==============================================================================

# Velocidad del shake basado en noise (mayor = más rápido)
var noise_shake_speed: float = 10.0

# Velocidad del sway (menor = más suave)
var noise_sway_speed: float = 1.0

# Intensidad del shake noise
var noise_shake_strength: float = 60.0

# Intensidad del sway
var noise_sway_strength: float = 10.0

# Velocidad de decaimiento del efecto (mayor = desaparece más rápido)
var shake_decay_rate: float = 1.0

# ==============================================================================
# VARIABLES INTERNAS
# ==============================================================================

var active_camera: Camera2D = null
var shake_strength: float = 0.0
var shake_type: int = ShakeType.Random
var active: bool = false
var noise_i: float = 0.0

var noise: FastNoiseLite = FastNoiseLite.new()
var rand: RandomNumberGenerator = RandomNumberGenerator.new()

# ==============================================================================
# INICIALIZACIÓN
# ==============================================================================

func _ready() -> void:
	# Configurar generadores
	rand.randomize()
	noise.seed = rand.randi()
	noise.frequency = 0.5
	
	# Desactivar procesamiento hasta que se active el shake
	set_process(false)

# ==============================================================================
# API PÚBLICA
# ==============================================================================

## Inicia un efecto de shake en la cámara activa
## @param shake_type_input: Tipo de shake a aplicar (Random, Noise, Sway)
## @param strength: Intensidad base del shake
## @param p_noise_shake_speed: Velocidad del shake noise
## @param p_noise_sway_speed: Velocidad del sway
## @param p_noise_shake_strength: Fuerza del shake noise
## @param p_noise_sway_strength: Fuerza del sway
## @param p_shake_decay_rate: Velocidad de decaimiento del efecto
func shake_camera(
	shake_type_input: int = ShakeType.Random,
	strength: float = 30.0,
	p_noise_shake_speed: float = 30.0,
	p_noise_sway_speed: float = 1.0,
	p_noise_shake_strength: float = 60.0,
	p_noise_sway_strength: float = 10.0,
	p_shake_decay_rate: float = 3.0
) -> void:
	# Obtener todas las cámaras en la escena
	var cameras = get_all_cameras()
	if cameras.is_empty():
		push_error("CameraShake: No se encontraron cámaras en la escena")
		return
	
	# Buscar la cámara activa
	active_camera = find_active_camera(cameras)
	if active_camera == null:
		push_error("CameraShake: No se encontró una cámara activa")
		return

	# Asignar parámetros
	shake_type = shake_type_input
	shake_strength = strength
	noise_shake_speed = p_noise_shake_speed
	noise_sway_speed = p_noise_sway_speed
	noise_shake_strength = p_noise_shake_strength
	noise_sway_strength = p_noise_sway_strength
	shake_decay_rate = p_shake_decay_rate

	# Activar el efecto
	active = true
	set_process(true)

# ==============================================================================
# PROCESAMIENTO
# ==============================================================================

func _process(delta: float) -> void:
	if not active or active_camera == null:
		return

	# Reducir gradualmente la fuerza del shake
	shake_strength = lerp(shake_strength, 0.0, shake_decay_rate * delta)
	
	# Calcular offset según el tipo de shake
	var shake_offset: Vector2 = Vector2.ZERO
	match shake_type:
		ShakeType.Random:
			shake_offset = get_random_offset()
		ShakeType.Noise:
			shake_offset = get_noise_offset(delta, noise_shake_speed, shake_strength)
		ShakeType.Sway:
			shake_offset = get_noise_offset(delta, noise_sway_speed, noise_sway_strength)
	
	# Aplicar el offset a la cámara
	active_camera.offset = shake_offset
	
	# Detener el efecto cuando la fuerza es mínima
	if abs(shake_strength) < 0.1:
		active = false
		set_process(false)
		active_camera.offset = Vector2.ZERO
		active_camera = null

# ==============================================================================
# HELPERS - BÚSQUEDA DE CÁMARAS
# ==============================================================================

## Obtiene todas las cámaras presentes en la escena
func get_all_cameras() -> Array:
	var cameras: Array = []
	var root = get_tree().root
	_find_cameras_recursive(root, cameras)
	return cameras

## Busca cámaras recursivamente en el árbol de nodos
func _find_cameras_recursive(node: Node, result: Array) -> void:
	if node is Camera2D:
		result.append(node)
	
	for child in node.get_children():
		_find_cameras_recursive(child, result)

## Encuentra la primera cámara activa en un array de cámaras
func find_active_camera(cameras: Array) -> Camera2D:
	for camera in cameras:
		if camera.enabled:
			return camera
	return null

# ==============================================================================
# HELPERS - GENERACIÓN DE OFFSET
# ==============================================================================

## Genera un offset basado en ruido Perlin
func get_noise_offset(delta: float, speed: float, strength: float) -> Vector2:
	noise_i += delta * speed
	return Vector2(
		noise.get_noise_2d(1, noise_i) * strength,
		noise.get_noise_2d(100, noise_i) * strength
	)

## Genera un offset completamente aleatorio
func get_random_offset() -> Vector2:
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)
