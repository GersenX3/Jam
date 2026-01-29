# ==============================================================================
# gato_attack_state.gd
# ==============================================================================
# Estado Attack: El gato ejecuta un ataque al jugador
# Transiciones:
# - Tras el golpe, si el jugador sigue en rango → ChasingState
# - Si el jugador salió del rango → IdleState
# ==============================================================================
extends State
@onready var area_daño: Area2D = $"../../AreaDaño"

@export var attack_duration: float = 2

var attack_timer: float = 0.0
var has_dealt_damage: bool = false

func enter() -> void:
	super.enter()
	area_daño.set_collision_mask_value(2, false)
	print("Gato: Estado ATTACK")
	character.anim.play("attack")
	character.velocity.x = 0
	attack_timer = attack_duration
	has_dealt_damage = false

func exit() -> void:
	area_daño.set_collision_mask_value(2, true)
	has_dealt_damage = false

func process_physics(delta: float) -> State:
	# Mantener al gato quieto durante el ataque
	character.velocity.x = 0
	
	# Aplicar daño una sola vez durante el ataque
	if not has_dealt_damage:
		var bodies = character.area_daño.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player"):
				print("Gato: Daño aplicado al jugador")
				# Aquí aplicarías el daño real
				# body.take_damage(1)
				has_dealt_damage = true
	
	# Esperar a que termine la animación de ataque
	attack_timer -= delta
	
	if attack_timer <= 0:
		# Verificar si el jugador sigue en rango
		if character.player != null:
			return get_node("../Chasing")
		else:
			return get_node("../Idle")
	
	return null
