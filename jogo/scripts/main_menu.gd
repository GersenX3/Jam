extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_song("res://assets/music/Intro.wav", 0, false, 0.4)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_empezar_pressed() -> void:
	GameManager.change_to_scene("res://scenes/levels/Level_1.tscn")
	MusicManager.play_song("res://assets/music/Base.wav")


func _on_salir_pressed() -> void:
	GameManager.quit_game()
