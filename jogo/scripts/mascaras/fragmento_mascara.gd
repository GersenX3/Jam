extends Area3D
@export var nodo_desbloqueable: Node3D
@export var nodo_destruible: Node3D

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Jugador":
		nodo_desbloqueable.visible = true
		nodo_destruible.queue_free()

		# Activar colisiones en todos los nodos con CollisionShape3D/CollisionPolygon3D
		activar_colisiones_recursivamente(nodo_desbloqueable)

func activar_colisiones_recursivamente(nodo: Node) -> void:
	# Si el nodo es un CollisionShape3D o CollisionPolygon3D
	if nodo is CollisionShape3D or nodo is CollisionPolygon3D:
		nodo.disabled = false
	
	# Si el nodo tiene propiedades de collision_layer y collision_mask (PhysicsBody3D, Area3D, etc.)
	if nodo.has_method("set_collision_layer_value") and nodo.has_method("set_collision_mask_value"):
		nodo.set_collision_layer_value(2, true)
		nodo.set_collision_mask_value(2, true)
	
	# Iterar recursivamente por todos los hijos
	for hijo in nodo.get_children():
		activar_colisiones_recursivamente(hijo)
