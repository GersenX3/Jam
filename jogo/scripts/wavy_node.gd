extends Node2D
class_name wavy_node

@export var wave_amplitude: float = 3.0   # Qué tanto sube/baja
@export var wave_frequency: float = randf_range(1.6, 2.1)  # Qué rápido se mueve
@export var wave_offset: float = 0.0       # Útil si tienes varios botones ondulando distinto
@export var enable_shadow: bool = false

var base_position: Vector2
var wave_time: float = 0.0

func _ready() -> void:
	#add_to_group("atraible")
	
	# Guardamos la posición original
	base_position = position
	# Crear sombra si está habilitado
	if enable_shadow:
		_add_shadow()

func _process(delta: float) -> void:
	wave_time += delta
	
	# Cálculo exacto que usas en tus corazones
	var y_offset = sin((wave_time * wave_frequency) + wave_offset) * wave_amplitude
	
	# Aplicamos nueva posición
	position = base_position + Vector2(0, y_offset)

func _add_shadow():
	var shadow = AnimatedSprite2D.new()
	shadow.name = "Shadow"
	
	# Copiar configuración del AnimatedSprite2D original
	shadow.sprite_frames = self.sprite_frames
	shadow.animation = self.animation
	shadow.frame = self.frame
	
	# Posicionamiento y estilo de sombra
	shadow.position = Vector2(1, 1)  # Offset diagonal
	shadow.modulate = Color(0.0, 0.0, 0.0, 1)  # Negro semi-transparente
	shadow.z_index = -1  # Detrás del sprite original
	shadow.scale = Vector2(1,1)  # Heredar escala del sprite original
	
	# Añadir como hijo
	self.add_child(shadow)
	self.move_child(shadow, 0)  # Asegurar que esté al fondo
	
	# Sincronizar animaciones automáticamente
	self.animation_finished.connect(func(): shadow.animation = self.animation)
	self.frame_changed.connect(func(): shadow.frame = self.frame)
