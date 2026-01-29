# StunnedState.gd
extends State

@export var stun_duration: float = 4.0
@onready var damage_area: Area2D = $"../../DamageArea"

var stun_timer: float = 0.0

func enter():
	super.enter()
	character.anim.play("stun")
	character.velocity = Vector2.ZERO
	stun_timer = 0.0
	damage_area.set_collision_mask_value(2,false)
	print("Búho: ¡Aturdido!")

func process_physics(delta: float) -> State:
	stun_timer += delta
	
	# Aplicar gravedad mientras está aturdido
	if not character.is_on_floor():
		character.velocity.y += 980 * delta
		character.move_and_slide()
	
	# Terminar el aturdimiento
	if stun_timer >= stun_duration:
		return state_machine.get_node_or_null("Returning")
	
	return null

func exit():
	super.exit()
	print("Búho: Recuperado del aturdimiento")
#```
#
#---
#
### 🎯 **Estructura de Nodos en Godot:**
#```
#OwlEnemy (CharacterBody2D) [Script: OwlEnemy.gd]
#├── AnimatedSprite2D
#├── CollisionShape2D
#├── DamageArea (Area2D) [Tu área existente]
#│   └── CollisionShape2D
#├── DetectionArea (Area2D) [NUEVO - para detectar jugador]
#│   └── CollisionShape2D (CircleShape2D o RectangleShape2D)
#└── StateMachine (Node) [Script: StateMachine.gd]
	#├── PerchedState (Node) [Script: PerchedState.gd]
	#├── DivingState (Node) [Script: DivingState.gd]
	#├── ReturningState (Node) [Script: ReturningState.gd]
	#└── StunnedState (Node) [Script: StunnedState.gd]
