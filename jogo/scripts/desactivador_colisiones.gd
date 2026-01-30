extends Node2D

func _ready() -> void:
	desactivar_colisiones_recursivamente(self)

func desactivar_colisiones_recursivamente(nodo: Node) -> void:
	# Si el nodo es un CollisionShape2D o CollisionPolygon2D
	if "visible" in nodo:
		nodo.visible = false
	
	# Si el nodo tiene propiedades de collision_layer y collision_mask (PhysicsBody3D, Area3D, etc.)
	if nodo.has_method("set_collision_layer_value") and nodo.has_method("set_collision_mask_value") and nodo is not TileMapLayer:
		nodo.set_collision_layer_value(2, false)
		nodo.set_collision_mask_value(2, false)
	
	# Iterar recursivamente por todos los hijos
	for hijo in nodo.get_children():
		desactivar_colisiones_recursivamente(hijo)
