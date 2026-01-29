# ==============================================================================
# GameManager.gd - Singleton de gestión del juego
# ==============================================================================
# Singleton que gestiona el estado global del juego, transiciones de escenas,
# modos de juego, sistema de pausa y comunicación con otros sistemas.
#
# EJEMPLOS DE USO:
#
# 1. Cambiar de escena:
#    GameManager.change_to_scene("res://scenes/levels/level_1.tscn")
#
# 2. Iniciar un nivel:
#    GameManager.start_level(1, GameManager.GameMode.NORMAL)
#
# 3. Sistema de pausa:
#    GameManager.pause_game()    # Pausar
#    GameManager.resume_game()   # Reanudar
#
# 4. Navegar a menús:
#    GameManager.go_to_main_menu()
#    GameManager.go_to_level_select()
#
# 5. Cambiar modo de juego:
#    GameManager.set_game_mode(GameManager.GameMode.CHALLENGE)
#
# 6. Obtener estado actual:
#    var current_level = GameManager.get_current_level()
#    var is_paused = GameManager.is_paused
#
# EVENTOS QUE EMITE (via EventBus):
# - "game_paused" → {}
# - "game_resumed" → {}
# - "scene_changing" → {from: String, to: String}
# - "scene_changed" → {scene_path: String}
# - "mode_changed" → {mode: GameMode, mode_name: String}
# - "level_started" → {level: int, mode: GameMode}
# - "game_quit" → {}
# ==============================================================================

extends Node

# ==============================================================================
# ENUMS Y CONSTANTES
# ==============================================================================

enum GameMode {
	NORMAL,      # Modo de juego principal
	CHALLENGE,   # Modo de desafío/especial
	MENU         # En menús
}

# Rutas de escenas principales - PERSONALIZAR SEGÚN TU PROYECTO
const MAIN_MENU_SCENE = "res://scenes/main_menu.tscn"
const LEVEL_SELECT_SCENE = "res://scenes/ui/level_select.tscn"
const OPTIONS_SCENE = "res://scenes/ui/options_menu.tscn"
const PAUSE_MENU_SCENE = "res://scenes/ui/pause_menu.tscn"

# Template para niveles - usar String.format() o % para insertar número
const LEVEL_PATH_TEMPLATE = "res://scenes/levels/level_%d.tscn"

# ==============================================================================
# VARIABLES DE ESTADO
# ==============================================================================

var current_mode: GameMode = GameMode.NORMAL
var current_level: int = 0
var is_paused: bool = false

# Referencia al menú de pausa activo
var pause_menu_instance: Control = null

# ==============================================================================
# INICIALIZACIÓN
# ==============================================================================

func _ready():
	print("GameManager: Inicializado")
	
	# Configurar para que siempre procese (incluso en pausa)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Suscribirse a eventos relevantes
	_subscribe_to_events()

func _subscribe_to_events():
	"""Suscribirse a eventos del juego usando EventBus"""
	# auto_unsubscribe = false porque GameManager persiste toda la sesión
	
	EventBus.subscribe("level_completed", _on_level_completed, false)
	EventBus.subscribe("level_failed", _on_level_failed, false)
	EventBus.subscribe("player_died", _on_player_died, false)
	
	print("GameManager: Eventos suscritos")

func _input(event):
	"""Detectar input de pausa (ESC o botón asignado)"""
	if event.is_action_pressed("ui_cancel"):
		if not is_paused and _is_in_gameplay():
			pause_game()
		elif is_paused:
			resume_game()

# ==============================================================================
# NAVEGACIÓN DE ESCENAS
# ==============================================================================

## Cambiar a cualquier escena
func change_to_scene(scene_path: String):
	"""Cambia a una escena específica con transición segura"""
	var current_scene = get_tree().current_scene
	var from_path = current_scene.scene_file_path if current_scene else "none"
	
	# Emitir evento antes del cambio
	EventBus.emit("scene_changing", {
		"from": from_path,
		"to": scene_path
	})
	
	# Asegurar que el juego no esté pausado
	if is_paused:
		resume_game()
	
	# Cambiar escena
	get_tree().change_scene_to_file(scene_path)
	
	# Emitir evento después del cambio
	await get_tree().process_frame
	EventBus.emit("scene_changed", {
		"scene_path": scene_path
	})
	
	print("GameManager: Cambiando a escena - %s" % scene_path)

## Volver al menú principal
func go_to_main_menu():
	current_mode = GameMode.MENU
	change_to_scene(MAIN_MENU_SCENE)

## Ir al selector de niveles
func go_to_level_select():
	current_mode = GameMode.MENU
	change_to_scene(LEVEL_SELECT_SCENE)

## Ir al menú de opciones (overlay)
func go_to_options():
	current_mode = GameMode.MENU
	var options = load(OPTIONS_SCENE).instantiate()
	get_tree().root.add_child(options)

# ==============================================================================
# SISTEMA DE NIVELES
# ==============================================================================

## Iniciar un nivel específico
func start_level(level_num: int, mode: GameMode = GameMode.NORMAL):
	"""Inicia un nivel con el modo especificado"""
	current_mode = mode
	current_level = level_num
	
	# Emitir cambio de modo
	EventBus.emit("mode_changed", {
		"mode": current_mode,
		"mode_name": get_mode_name(current_mode)
	})
	
	# Emitir inicio de nivel
	EventBus.emit("level_started", {
		"level": level_num,
		"mode": current_mode
	})
	
	# Cargar nivel
	var level_path = LEVEL_PATH_TEMPLATE % level_num
	if ResourceLoader.exists(level_path):
		change_to_scene(level_path)
	else:
		push_error("GameManager: Nivel no encontrado - %s" % level_path)
		go_to_main_menu()

## Ir al siguiente nivel
func go_to_next_level():
	"""Avanza al siguiente nivel en secuencia"""
	start_level(current_level + 1, current_mode)

## Reiniciar el nivel actual
func restart_current_level():
	"""Reinicia el nivel en el que estamos actualmente"""
	if current_level > 0:
		start_level(current_level, current_mode)
	else:
		push_warning("GameManager: No hay nivel actual para reiniciar")

# ==============================================================================
# SISTEMA DE PAUSA
# ==============================================================================

## Pausar el juego
func pause_game():
	"""Pausa el juego y muestra el menú de pausa"""
	if is_paused:
		return
	
	is_paused = true
	get_tree().paused = true
	
	EventBus.emit("game_paused", {})
	_show_pause_menu()
	
	print("GameManager: Juego pausado")

## Reanudar el juego
func resume_game():
	"""Reanuda el juego y oculta el menú de pausa"""
	if not is_paused:
		return
	
	is_paused = false
	get_tree().paused = false
	
	EventBus.emit("game_resumed", {})
	_hide_pause_menu()
	
	print("GameManager: Juego reanudado")

func _show_pause_menu():
	"""Instancia el menú de pausa como overlay"""
	if pause_menu_instance:
		return
	
	var pause_scene = load(PAUSE_MENU_SCENE)
	if pause_scene:
		pause_menu_instance = pause_scene.instantiate()
		pause_menu_instance.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().root.add_child(pause_menu_instance)

func _hide_pause_menu():
	"""Elimina el menú de pausa"""
	if pause_menu_instance:
		pause_menu_instance.queue_free()
		pause_menu_instance = null

func _is_in_gameplay() -> bool:
	"""Verifica si estamos en una escena de juego (no menús)"""
	var current_scene = get_tree().current_scene
	if not current_scene:
		return false
	
	var scene_path = current_scene.scene_file_path
	# Personalizar según la estructura de tu proyecto
	return scene_path.contains("/levels/")

# ==============================================================================
# CALLBACKS DE EVENTOS
# ==============================================================================

func _on_level_completed(data):
	"""Responde cuando se completa un nivel"""
	print("GameManager: Nivel completado - ", data)
	# Lógica personalizada aquí (guardar progreso, mostrar UI, etc.)

func _on_level_failed(data):
	"""Responde cuando falla un nivel"""
	print("GameManager: Nivel fallado - ", data)
	# Lógica personalizada aquí (mostrar retry screen, etc.)

func _on_player_died(data):
	"""Responde cuando el jugador muere"""
	print("GameManager: Jugador murió - ", data)
	# Lógica personalizada aquí (reiniciar, quitar vida, etc.)

# ==============================================================================
# GESTIÓN DE MODOS
# ==============================================================================

## Cambiar el modo de juego actual
func set_game_mode(mode: GameMode):
	"""Cambia el modo de juego y emite evento"""
	current_mode = mode
	EventBus.emit("mode_changed", {
		"mode": mode,
		"mode_name": get_mode_name(mode)
	})

## Obtener nombre del modo como string
func get_mode_name(mode: GameMode) -> String:
	"""Convierte el enum GameMode a string legible"""
	match mode:
		GameMode.NORMAL:
			return "Normal"
		GameMode.CHALLENGE:
			return "Challenge"
		GameMode.MENU:
			return "Menu"
		_:
			return "Unknown"

# ==============================================================================
# GETTERS Y UTILIDADES
# ==============================================================================

## Obtener el número del nivel actual
func get_current_level() -> int:
	return current_level

## Obtener el modo de juego actual
func get_game_mode() -> GameMode:
	return current_mode

## Verificar si está en modo normal
func is_in_normal_mode() -> bool:
	return current_mode == GameMode.NORMAL

## Verificar si está en modo desafío
func is_in_challenge_mode() -> bool:
	return current_mode == GameMode.CHALLENGE

## Salir del juego
func quit_game():
	"""Cierra el juego de forma segura"""
	print("GameManager: Cerrando juego")
	
	EventBus.emit("game_quit", {})
	await get_tree().process_frame
	
	get_tree().quit()

## Obtener estado completo del juego (útil para debug)
func get_game_state() -> Dictionary:
	"""Retorna un diccionario con el estado actual del juego"""
	return {
		"mode": get_mode_name(current_mode),
		"level": current_level,
		"paused": is_paused,
		"scene": get_tree().current_scene.scene_file_path if get_tree().current_scene else "none"
	}

## Imprimir estado del juego en consola
func print_game_state():
	"""Debug: Imprime el estado actual del juego"""
	var state = get_game_state()
	print("=== GAME STATE ===")
	print("Mode: ", state.mode)
	print("Level: ", state.level)
	print("Paused: ", state.paused)
	print("Scene: ", state.scene)
	print("==================")
