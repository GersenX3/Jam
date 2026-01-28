extends CharacterBody3D

@onready var third_person_controler_3d: ThirdPersonControler3D = $ThirdPersonControler3D
@onready var state_machine: StateMachine = $StateMachine
@onready var muerte: Node = $StateMachine/Muerte
@onready var hurt: Node = $StateMachine/Hurt

func _ready() -> void:
	EventBus.subscribe("Muerte", _trigger_death, false)
	add_to_group("jugador")
	third_person_controler_3d.toggle_active(true)

func _trigger_hazard(args):
	EventBus.emit("cambio_vida", 1)

func _trigger_death(args):
	"""
	Llamado por hazards o cuando la vida llega a 0
	"""
	if has_node("StateMachine"):
		var state_machine = get_node("StateMachine")
		
		# Verificar que no esté ya en estado de muerte
		if state_machine.current_state != muerte and muerte:
			state_machine.transition_to(muerte)

			
func disable_all():
	rotation = Vector3.ZERO
	#first_person_controler_3d.toggle_active(false)
	third_person_controler_3d.toggle_active(false)
	#side_scrolling_controler_3d.toggle_active(false)
	#top_down_controler_3d.toggle_active(false)
