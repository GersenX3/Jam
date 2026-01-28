# ==============================================================================
# MusicManager.gd - Singleton de gestión de audio
# ==============================================================================
# Singleton que maneja música de fondo y efectos de sonido del juego.
# Incluye transiciones suaves, control de volumen/pitch, y sistema de reverb.
#
# EJEMPLOS DE USO:
#
# 1. Reproducir música con fade:
#    MusicManager.play_song("res://assets/music/level_theme.ogg")
#
# 2. Reproducir música con parámetros personalizados:
#    MusicManager.play_song("res://assets/music/boss.ogg", 2.0, false, 1.2, -5.0, true, true)
#
# 3. Detener música con fade out:
#    MusicManager.stop_song(1.5)
#
# 4. Reproducir efecto de sonido:
#    MusicManager.play_sound("res://assets/sfx/jump.wav", 0.5)
#
# 5. Reproducir sonido con pitch aleatorio:
#    MusicManager.play_sound("res://assets/sfx/hit.wav", 0.8, false, randf_range(0.9, 1.1))
#
# 6. Sonido posicional (2D):
#    MusicManager.play_sound("res://assets/sfx/explosion.wav", 1.0, true, 1.0, enemy_position)
#
# 7. Controlar volumen y pitch:
#    MusicManager.set_volume(0.7)    # 70% volumen
#    MusicManager.set_pitch(1.5)      # Pitch 1.5x
#    MusicManager.reset_pitch()       # Volver a pitch normal
#
# 8. Activar/desactivar reverb:
#    MusicManager.set_reverb(true)    # Activar reverb
#    MusicManager.set_reverb(false)   # Desactivar reverb
#
# CONFIGURACIÓN DE BUSES:
# El manager crea automáticamente los buses necesarios:
# - Music: Bus principal de música
# - MusicReverb: Bus con efecto de reverb
# - SFX: Bus de efectos de sonido (debe existir en tu AudioBusLayout)
# ==============================================================================

extends Node

# ==============================================================================
# CONSTANTES DE CONFIGURACIÓN
# ==============================================================================

# Tiempo de fade por defecto (en segundos)
const DEFAULT_FADE_TIME: float = 1.0

# Volumen mínimo en dB (para fades)
const MIN_DB: float = -30.0

# Volumen por defecto (0.0 a 1.0)
const DEFAULT_VOLUME: float = 0.4

# Pitch por defecto
const DEFAULT_PITCH: float = 1.0

# ==============================================================================
# CONFIGURACIÓN DE REVERB (Buenos defaults para la mayoría de casos)
# ==============================================================================

# Tamaño de la sala (0.0 a 1.0) - Más grande = reverb más largo
const REVERB_ROOM_SIZE: float = 0.8

# Amortiguación (0.0 a 1.0) - Más alto = menos brillante
const REVERB_DAMPING: float = 0.5

# Dispersión estéreo (0.0 a 1.0)
const REVERB_SPREAD: float = 1.0

# Filtro paso alto (0.0 a 1.0)
const REVERB_HIPASS: float = 0.0

# Señal seca/original (0.0 a 1.0)
const REVERB_DRY: float = 0.19

# Señal con reverb (0.0 a 1.0)
const REVERB_WET: float = 1.0

# Pre-delay en milisegundos
const REVERB_PREDELAY_MS: float = 150.0

# Feedback del pre-delay (0.0 a 1.0)
const REVERB_PREDELAY_FEEDBACK: float = 0.4

# ==============================================================================
# VARIABLES INTERNAS
# ==============================================================================

var music_player: AudioStreamPlayer
var current_song: String = ""
var target_volume: float = linear_to_db(DEFAULT_VOLUME)
var transition_tween: Tween
var reverb_enabled: bool = false

# Referencias a buses de audio
var music_bus_idx: int
var reverb_bus_idx: int

# ==============================================================================
# INICIALIZACIÓN
# ==============================================================================

func _ready():
	# Obtener o crear buses de audio
	_setup_audio_buses()
	
	# Crear reproductor de música
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	add_child(music_player)
	
	# Configuración inicial del reproductor
	music_player.volume_db = MIN_DB
	music_player.pitch_scale = DEFAULT_PITCH
	music_player.bus = "Music"
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	set_volume(DEFAULT_VOLUME)
	
	print("MusicManager: Inicializado")

func _setup_audio_buses():
	"""Configura los buses de audio necesarios"""
	# Bus principal de música
	music_bus_idx = AudioServer.get_bus_index("Music")
	
	# Crear bus de reverb si no existe
	reverb_bus_idx = AudioServer.get_bus_index("MusicReverb")
	if reverb_bus_idx == -1:
		reverb_bus_idx = AudioServer.bus_count
		AudioServer.add_bus(reverb_bus_idx)
		AudioServer.set_bus_name(reverb_bus_idx, "MusicReverb")
		AudioServer.set_bus_send(reverb_bus_idx, "Master")
		
		# Agregar y configurar efecto de reverb
		var reverb = AudioEffectReverb.new()
		_configure_reverb(reverb)
		AudioServer.add_bus_effect(reverb_bus_idx, reverb)

func _configure_reverb(reverb: AudioEffectReverb):
	"""Configura los parámetros del efecto de reverb"""
	reverb.room_size = REVERB_ROOM_SIZE
	reverb.damping = REVERB_DAMPING
	reverb.spread = REVERB_SPREAD
	reverb.hipass = REVERB_HIPASS
	reverb.dry = REVERB_DRY
	reverb.wet = REVERB_WET
	reverb.predelay_msec = REVERB_PREDELAY_MS
	reverb.predelay_feedback = REVERB_PREDELAY_FEEDBACK

# ==============================================================================
# API PÚBLICA - CONTROL DE MÚSICA
# ==============================================================================

## Reproduce una canción con transición suave
## @param song_path: Ruta al archivo de audio
## @param fade_time: Duración del fade in/out en segundos
## @param force_restart: Si true, reinicia la canción aunque ya esté sonando
## @param pitch: Multiplicador de pitch (0.5 a 2.0)
## @param volume_db: Ajuste adicional de volumen en dB
## @param loop: Si la canción debe repetirse
## @param use_reverb: Activar efecto de reverb
func play_song(
	song_path: String, 
	fade_time: float = DEFAULT_FADE_TIME, 
	force_restart: bool = false,
	pitch: float = 1.0,
	volume_db: float = 0.0,
	loop: bool = true,
	use_reverb: bool = false
):
	# Aplicar reverb si se solicita
	set_reverb(use_reverb)
	
	# Si es la misma canción y ya está sonando, no hacer nada
	if song_path == current_song and music_player.playing and not force_restart:
		return
	
	current_song = song_path
	
	# Cargar el stream de audio
	var stream = load(song_path)
	if not stream:
		push_error("MusicManager: Canción no encontrada - %s" % song_path)
		return
	
	# Configurar loop según el tipo de audio
	if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.loop = loop
	
	_cleanup_tweens()
	
	# Configurar pitch
	music_player.pitch_scale = pitch
	
	# Calcular volumen final
	var final_target_volume = target_volume + volume_db
	final_target_volume = clamp(final_target_volume, MIN_DB, 0.0)
	
	# Transición suave entre canciones
	if music_player.playing:
		# Fade out → Cambiar → Fade in
		transition_tween = create_tween().set_parallel(false)
		transition_tween.tween_property(music_player, "volume_db", MIN_DB, fade_time)
		transition_tween.tween_callback(_switch_song.bind(stream))
		transition_tween.tween_property(music_player, "volume_db", final_target_volume, fade_time)
	else:
		# Solo fade in
		_switch_song(stream)
		transition_tween = create_tween()
		transition_tween.tween_property(music_player, "volume_db", final_target_volume, fade_time)

## Detiene la música con fade out
## @param fade_time: Duración del fade out en segundos
func stop_song(fade_time: float = DEFAULT_FADE_TIME):
	_cleanup_tweens()
	transition_tween = create_tween()
	transition_tween.tween_property(music_player, "volume_db", MIN_DB, fade_time)
	transition_tween.tween_callback(_stop_player)

## Activa o desactiva el efecto de reverb
## @param enabled: true para activar, false para desactivar
func set_reverb(enabled: bool):
	reverb_enabled = enabled
	if enabled:
		music_player.bus = "MusicReverb"
	else:
		music_player.bus = "Music"

## Ajusta el volumen de la música
## @param volume: Volumen de 0.0 (silencio) a 1.0 (máximo)
func set_volume(volume: float):
	target_volume = linear_to_db(clamp(volume, 0.0, 1.0))
	if not transition_tween or not transition_tween.is_valid():
		music_player.volume_db = target_volume

## Ajusta el pitch/tono de la música
## @param pitch: Multiplicador de pitch (0.5 a 2.0)
func set_pitch(pitch: float):
	music_player.pitch_scale = clamp(pitch, 0.5, 2.0)

## Resetea el pitch a su valor por defecto
func reset_pitch():
	set_pitch(DEFAULT_PITCH)

## Obtiene el volumen actual (0.0 a 1.0)
func get_volume() -> float:
	return db_to_linear(music_player.volume_db)

## Obtiene el pitch actual
func get_pitch() -> float:
	return music_player.pitch_scale

## Verifica si hay música reproduciéndose
func is_playing() -> bool:
	return music_player.playing

## Obtiene el nombre de la canción actual
func get_current_song() -> String:
	return current_song

# ==============================================================================
# API PÚBLICA - EFECTOS DE SONIDO
# ==============================================================================

## Reproduce un efecto de sonido
## @param sound_path: Ruta al archivo de audio
## @param volume: Volumen del sonido (0.0 a 1.0)
## @param positional: Si debe ser posicional (AudioStreamPlayer2D)
## @param pitch: Multiplicador de pitch
## @param position: Posición global (solo si positional=true)
func play_sound(
	sound_path: String, 
	volume: float = 1.0, 
	positional: bool = false, 
	pitch: float = 1.0, 
	position: Vector2 = Vector2.ZERO
):
	var sound
	
	# Crear el tipo correcto de AudioStreamPlayer
	if positional:
		sound = AudioStreamPlayer2D.new()
		if position != Vector2.ZERO:
			sound.global_position = position
		else:
			# Si no se especifica posición, usar la del jugador
			var player = get_tree().get_first_node_in_group("player")
			if player:
				sound.global_position = player.global_position
	else:
		sound = AudioStreamPlayer.new()
	
	# Añadir al árbol
	get_tree().root.add_child(sound)
	
	# Configurar y reproducir
	sound.stream = load(sound_path)
	sound.volume_db = linear_to_db(clamp(volume, 0.0, 1.0))
	sound.pitch_scale = pitch
	sound.bus = "SFX"
	sound.play()
	
	# Auto-destruir cuando termine
	sound.finished.connect(sound.queue_free)

# ==============================================================================
# MÉTODOS INTERNOS
# ==============================================================================

func _switch_song(stream: AudioStream):
	"""Cambia a una nueva pista inmediatamente"""
	music_player.stream = stream
	music_player.play()
	music_player.volume_db = MIN_DB

func _stop_player():
	"""Detiene el reproductor completamente"""
	music_player.stop()
	current_song = ""

func _cleanup_tweens():
	"""Limpia tweens existentes para evitar conflictos"""
	if transition_tween and transition_tween.is_valid():
		transition_tween.kill()
