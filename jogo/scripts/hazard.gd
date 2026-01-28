extends Area3D
@export var auto_destruccion = false

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("_trigger_hazard"):
		body._trigger_hazard(0)
		if auto_destruccion:
			self.queue_free()
