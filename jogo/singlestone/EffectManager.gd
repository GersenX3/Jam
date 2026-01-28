# ==============================================================================
# EffectManager.gd - Singleton de efectos visuales y de audio
# ==============================================================================
# Singleton que centraliza la reproducción de efectos visuales (partículas) y
# efectos de sonido. Se integra con EventBus para responder a eventos del juego
# de forma desacoplada.
#
# EJEMPLOS DE USO:
#
# 1. Reproducir efecto completo (partículas + sonido):
#    EffectManager.play_collision_effect("wall_hit", position, Vector2.LEFT, 0.8)
#
# 2. Reproducir solo partículas:
#    EffectManager.spawn_particles_only("explosion", global_position)
#
# 3. Reproducir sonido personalizado:
#    EffectManager.play_custom_effect("res://assets/sfx/custom.wav", position, 0.5, 1.2)
#
# 4. Agregar nuevos efectos:
#    - Añadir entrada en PARTICLE_SCENES con la ruta a la escena
#    - Añadir entrada en SFX_CONFIG con configuración de audio
#    - Usar play_collision_effect() con el nombre del efecto
#
# INTEGRACIÓN CON EVENTBUS:
# El manager se suscribe automáticamente a eventos relevantes. Para agregar más:
#    EventBus.subscribe("mi_evento", _on_mi_evento, false)
# ==============================================================================

extends Node

# ==============================================================================
# CONFIGURACIÓN DE EFECTOS
# ==============================================================================

# Diccionario de escenas de partículas
# Formato: "nombre_efecto": "ruta/a/escena.tscn"
const PARTICLE_SCENES = {
	"wall_hit": "res://scenes/particles/wall_impact.tscn",
	"explosion": "res://scenes/particles/explosion.tscn",
	# Añade más efectos aquí siguiendo el mismo formato
}

# Configuración de efectos de sonido
# Formato: "nombre_efecto": { path, volume, pitch_min, pitch_max }
const SFX_CONFIG = {
	"wall_hit": {
		"path": "res://assets/sfx/impact.wav",
		"volume": 0.3,           # Volumen base (0.0 a 1.0)
		"pitch_min": 1.2,        # Pitch mínimo para variación
		"pitch_max": 1.6         # Pitch máximo para variación
	},
	"explosion": {
		"path": "res://assets/sfx/explosion.wav",
		"volume": 0.5,
		"pitch_min": 0.9,
		"pitch_max": 1.1
	},
	# Añade más configuraciones aquí siguiendo el mismo formato
}

# ==============================================================================
# INICIALIZACIÓN
# ==============================================================================

func _ready():
	print("EffectManager: Inicializado")
	_subscribe_to_events()

func _subscribe_to_events():
	"""Suscribirse a eventos de colisión y otros eventos relevantes"""
	# Ejemplo: Suscribirse a eventos de colisión
	EventBus.subscribe("wall_collision", _on_wall_collision, false)
	EventBus.subscribe("player_damaged", _on_player_damaged, false)
	
	print("EffectManager: Eventos suscritos")

# ==============================================================================
# CALLBACKS DE EVENTOS
# ==============================================================================

func _on_wall_collision(data: Dictionary):
	"""
	Maneja colisiones con paredes
	Data esperada: {position: Vector2, velocity: Vector2, normal: Vector2}
	"""
	var impact_strength = abs(data.velocity.x) / 100.0
	impact_strength = clamp(impact_strength, 0.3, 1.0)
	
	play_collision_effect(
		"wall_hit",
		data.position,
		data.get("normal", Vector2.LEFT),
		impact_strength
	)

func _on_player_damaged(data: Dictionary):
	"""
	Maneja cuando el jugador recibe daño
	Data esperada: {position: Vector2, damage: float}
	"""
	var strength = clamp(data.get("damage", 1.0) / 10.0, 0.5, 1.0)
	
	play_collision_effect(
		"explosion",
		data.position,
		Vector2.ZERO,
		strength
	)

# ==============================================================================
# API PÚBLICA - SISTEMA DE EFECTOS
# ==============================================================================

## Reproduce un efecto completo: partículas + SFX + shake de cámara
## @param effect_type: Nombre del efecto (debe existir en PARTICLE_SCENES y SFX_CONFIG)
## @param position: Posición global donde reproducir el efecto
## @param direction: Dirección del efecto (opcional, para orientar partículas)
## @param strength: Multiplicador de intensidad (0.0 a 1.0)
func play_collision_effect(
	effect_type: String,
	position: Vector2,
	direction: Vector2 = Vector2.ZERO,
	strength: float = 1.0
):
	# Reproducir SFX
	_play_sfx(effect_type, strength)
	
	# Shake de cámara proporcional a la fuerza
	CamaraShake.shake_camera(CamaraShake.ShakeType.Random, strength * 8.0)
	
	# Spawnear partículas
	_spawn_particles(effect_type, position, direction)

## Reproduce solo un efecto de sonido personalizado
## @param sfx_path: Ruta al archivo de audio
## @param position: Posición donde reproducir (opcional)
## @param volume: Volumen del sonido (0.0 a 1.0)
## @param pitch: Pitch del sonido
func play_custom_effect(
	sfx_path: String, 
	position: Vector2 = Vector2.ZERO, 
	volume: float = 0.3, 
	pitch: float = 1.0
):
	MusicManager.play_sound(sfx_path, volume, false, pitch)

## Spawnea solo partículas sin sonido ni shake
## @param effect_type: Nombre del efecto en PARTICLE_SCENES
## @param position: Posición global donde spawnear
## @param direction: Dirección para orientar las partículas
func spawn_particles_only(
	effect_type: String, 
	position: Vector2, 
	direction: Vector2 = Vector2.ZERO
):
	_spawn_particles(effect_type, position, direction)

# ==============================================================================
# MÉTODOS INTERNOS
# ==============================================================================

func _play_sfx(effect_type: String, strength: float):
	"""Reproduce el sonido apropiado con variación de pitch"""
	if not SFX_CONFIG.has(effect_type):
		push_warning("EffectManager: SFX no configurado para tipo '%s'" % effect_type)
		return
	
	var config = SFX_CONFIG[effect_type]
	
	# Calcular pitch aleatorio dentro del rango
	var pitch = randf_range(config.pitch_min, config.pitch_max)
	
	# Ajustar volumen según la fuerza
	var volume = config.volume * strength
	
	# Reproducir sonido
	MusicManager.play_sound(config.path, volume, false, pitch)

func _spawn_particles(effect_type: String, position: Vector2, direction: Vector2):
	"""Instancia y configura partículas en la posición indicada"""
	if not PARTICLE_SCENES.has(effect_type):
		push_warning("EffectManager: Partículas no configuradas para tipo '%s'" % effect_type)
		return
	
	var particle_path = PARTICLE_SCENES[effect_type]
	
	# Verificar si el archivo existe
	if not ResourceLoader.exists(particle_path):
		push_error("EffectManager: Archivo de partículas no encontrado: %s" % particle_path)
		return
	
	# Cargar e instanciar partículas
	var particle_scene = load(particle_path)
	var particles = particle_scene.instantiate()
	
	# Configurar posición
	particles.global_position = position
	
	# Configurar dirección si el nodo tiene el método
	if particles.has_method("set_direction"):
		particles.set_direction(direction)
	
	# Añadir al árbol de escenas
	get_tree().root.add_child(particles)
	
	# Auto-destruir según el tipo de partículas
	_setup_particle_cleanup(particles)

func _setup_particle_cleanup(particles: Node):
	"""Configura la auto-destrucción de partículas según su tipo"""
	if particles is GPUParticles2D or particles is CPUParticles2D:
		particles.emitting = true
		# Esperar a que termine la animación
		var cleanup_time = particles.lifetime * 1.5
		await get_tree().create_timer(cleanup_time).timeout
		particles.queue_free()
		
	elif particles is AnimatedSprite2D:
		particles.play()
		await particles.animation_finished
		particles.queue_free()
		
	else:
		# Fallback: eliminar después de 2 segundos
		await get_tree().create_timer(2.0).timeout
		particles.queue_free()
