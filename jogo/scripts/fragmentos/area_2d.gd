extends Area2D
@export var nodo_desbloqueable: Node2D
@export var nodo_destruible: Node2D = self
@export var path_cancion_nueva = ""
@export var path_sonido_animal = ""

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and nodo_desbloqueable and nodo_destruible:
		if path_cancion_nueva != "":
			MusicManager.play_song(path_cancion_nueva)
		if path_cancion_nueva != "":
			MusicManager.play_sound(path_sonido_animal, 0.2)
		activar_colisiones_recursivamente(nodo_desbloqueable)
		nodo_destruible.queue_free()

func activar_colisiones_recursivamente(nodo: Node) -> void:
	# Si el nodo es un CollisionShape2D o CollisionPolygon2D
	if "visible" in nodo:
		nodo.visible = true
	
	# Si el nodo tiene propiedades de collision_layer y collision_mask (PhysicsBody3D, Area3D, etc.)
	if nodo.has_method("set_collision_layer_value") and nodo.has_method("set_collision_mask_value"):
		nodo.set_collision_layer_value(1, true)
		nodo.set_collision_mask_value(1, true)
	
	# Iterar recursivamente por todos los hijos
	for hijo in nodo.get_children():
		activar_colisiones_recursivamente(hijo)
