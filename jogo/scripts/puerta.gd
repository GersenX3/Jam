extends Area2D
@export var path_escena = ""
@export var path_cancion_nueva = ""


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.change_to_scene(path_escena)
		MusicManager.play_sound("res://assets/sfx/celebration.wav", 0.2, false)
		if path_cancion_nueva != "":
			MusicManager.play_song(path_cancion_nueva)
	pass # Replace with function body.
