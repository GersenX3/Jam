# projectile.gd
# Este script va en una escena nueva que debes crear
extends Node2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 200.0
var lifetime: float = 5.0  # Se destruye después de 5 segundos

@onready var area_damage: Area2D = $AreaDaño  # La escena que ya tienes

func _ready() -> void:
	# Timer para autodestruirse
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(_on_lifetime_timeout)
	add_child(timer)
	timer.start()

func setup(new_direction: Vector2, new_speed: float) -> void:
	"""
	Configura la dirección y velocidad del proyectil
	Llamado desde el pájaro al crear el proyectil
	"""
	direction = new_direction.normalized()
	speed = new_speed
	
	# Rotar el proyectil para que apunte en la dirección correcta (opcional)
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	# Mover el proyectil
	position += direction * speed * delta

func _on_lifetime_timeout() -> void:
	queue_free()
#```
#
#**Escena del Proyectil** (`res://scenes/projectile.tscn`):
#```
#Projectile (Node2D) - script: projectile.gd
#└── AreaDaño (instancia de res://scenes/area_daño.tscn)
