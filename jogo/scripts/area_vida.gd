extends Area2D
@export var autodestroy = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _on_body_entered(body: Node2D) -> void:
	if body.has_method("vida"):
		body.vida()
		if autodestroy:
			self.queue_free()
