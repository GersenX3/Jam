extends Area2D
@export var nodo_desbloqueable: Node2D
@export var nodo_destruible: Node2D = self

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and nodo_desbloqueable and nodo_destruible:
		activar_colisiones_recursivamente(nodo_desbloqueable)
		nodo_destruible.queue_free()

func activar_colisiones_recursivamente(nodo: Node) -> void:
	# Si el nodo es un CollisionShape2D o CollisionPolygon2D

	nodo.visible = true
	
	# Si el nodo tiene propiedades de collision_layer y collision_mask (PhysicsBody3D, Area3D, etc.)
	if nodo.has_method("set_collision_layer_value") and nodo.has_method("set_collision_mask_value"):
		nodo.set_collision_layer_value(1, true)
		nodo.set_collision_mask_value(1, true)
	
	# Iterar recursivamente por todos los hijos
	for hijo in nodo.get_children():
		activar_colisiones_recursivamente(hijo)
