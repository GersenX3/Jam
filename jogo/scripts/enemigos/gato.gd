# enemy_chaser.gd
extends CharacterBody3D

# === CONFIGURACIÓN RÁPIDA ===
@export var speed := 3.5
@export var detection_range := 15.0
@export var attack_range := 1.5
@export var rotation_speed := 5.0

var player: Node3D
var state_machine: StateMachine

# === INICIALIZACIÓN ===
func _ready():
	# Buscar jugador (asume que tiene grupo "player")
	player = get_tree().get_first_node_in_group("player")
	
	# Crear state machine
	state_machine = StateMachine.new()
	add_child(state_machine)
	
	# Estados simples
	var idle_state = State.new()
	idle_state.name = "idle"
	idle_state.physics_process = _idle_physics
	
	var chase_state = State.new()
	chase_state.name = "chase"
	chase_state.physics_process = _chase_physics
	
	var attack_state = State.new()
	attack_state.name = "attack"
	attack_state.enter = _attack_enter
	attack_state.physics_process = _attack_physics
	
	state_machine.add_state(idle_state)
	state_machine.add_state(chase_state)
	state_machine.add_state(attack_state)
	state_machine.set_state("idle")

# === LÓGICA DE ESTADOS ===
func _idle_physics(_delta: float):
	if not player:
		return
	
	var distance = global_position.distance_to(player.global_position)
	if distance < detection_range:
		state_machine.set_state("chase")

func _chase_physics(delta: float):
	if not player:
		return
	
	var distance = global_position.distance_to(player.global_position)
	
	# Si está muy lejos, volver a idle
	if distance > detection_range * 1.5:
		state_machine.set_state("idle")
		return
	
	# Si está cerca, atacar
	if distance < attack_range:
		state_machine.set_state("attack")
		return
	
	# Perseguir
	var direction = (player.global_position - global_position).normalized()
	direction.y = 0  # Mantener en el suelo
	
	# Rotar hacia el jugador
	if direction.length() > 0.01:
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, rotation_speed * delta)
	
	# Mover
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	velocity.y += -9.8 * delta  # Gravedad básica
	
	move_and_slide()

func _attack_enter():
	# Aquí reiniciar al jugador al inicio del nivel
	if player and player.has_method("die"):
		player.die()
	# O llamar directamente al manager del nivel
	get_tree().call_group("level_manager", "restart_level")

func _attack_physics(_delta: float):
	# Esperar un momento antes de volver a perseguir
	await get_tree().create_timer(1.0).timeout
	state_machine.set_state("chase")
