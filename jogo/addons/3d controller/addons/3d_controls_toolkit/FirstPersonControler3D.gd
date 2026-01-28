extends BaseControler3D
class_name FirstPersonControler3D

enum rotation_types {
	Camera_Only,
	Camera_And_Geometry
}

@export_category("Movement")
@export var Mouse_Sensitivity = 0.01
@export var Turn_Speed = 10
@export var Rotation_Type : rotation_types = rotation_types.Camera_And_Geometry

@export_category("Joystick Camera Control")
@export var Enable_Joystick_Camera : bool = true
@export var Joystick_Sensitivity : float = 3.0
@export var Joystick_Deadzone : float = 0.2
@export var Joystick_Smoothing : float = 10.0
@export var Invert_Joystick_Y : bool = false

@export_category("Camera")
@export var Horizontal_Offset : float = 0
@export var Vertical_Offset : float = 0
@export var Custom_Camera : Camera3D
@export_range(1, 360) var Max_Camera_Angle : int = 90
@export_range(-360, 0) var Min_Camera_Angle : int = -90

var pivot : Node3D 
var camera : Camera3D 
var _joystick_input : Vector2 = Vector2.ZERO

func _ready() -> void:	
	pivot = Node3D.new()
	add_child(pivot)
	pivot.position.x = Horizontal_Offset
	pivot.position.y = Vertical_Offset
	if Custom_Camera:
		camera = Custom_Camera
		camera.reparent.call_deferred(pivot)
	else:
		camera = Camera3D.new()
		pivot.add_child.call_deferred(camera)	
	if not Geometry:
		for child in _parent.get_children():
			if child is MeshInstance3D:
				Geometry = child
				continue
	toggle_active(Active)
	
func _input(event):
	if not Active:
		return
	if Handle_Mouse_Capture:
		if event is InputEventMouseButton:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif Input.is_action_just_pressed(Input_Cancel):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE	
			
	# Control de cámara con MOUSE (sin cambios)
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:        
		pivot.rotate_y(-(event as InputEventMouseMotion).relative.x * Mouse_Sensitivity)            
		if Geometry and Rotation_Type == rotation_types.Camera_And_Geometry:
			Geometry.rotate_y(-(event as InputEventMouseMotion).relative.x * Mouse_Sensitivity)
		camera.rotate_x(-(event as InputEventMouseMotion).relative.y * Mouse_Sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(Min_Camera_Angle), deg_to_rad(Max_Camera_Angle))
					
func _process(delta: float) -> void:
	if not Active:
		return
	
	# ===== NUEVO: Control de cámara con JOYSTICK DERECHO =====
	if Enable_Joystick_Camera:
		handle_joystick_camera(delta)
	# =========================================================
	
	HandleGravity(delta)
	HandleJump(delta)
	HandleDash(delta);
	HandleWallSlide();
	HandleWallHang();
	var direction = GetDirection(pivot)
	var currentSpeed = GetSpeed(delta)
	
	if direction:
		LastFacing = Vector3(direction.x, 0, direction.z)
		_velocity.x = move_toward(_velocity.x, direction.x * currentSpeed, Acceleration * delta)
		_velocity.z = move_toward(_velocity.z, direction.z * currentSpeed, Acceleration * delta)
	else:
		_velocity.x = move_toward(_velocity.x, 0, Deacceleration * delta)
		_velocity.z = move_toward(_velocity.z, 0, Deacceleration * delta)
		
	move()

# ===== NUEVA FUNCIÓN: Manejo del joystick derecho =====
func handle_joystick_camera(delta: float) -> void:
	# Leer el joystick derecho (stick derecho del control)
	var raw_input = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)
	
	# Aplicar deadzone (zona muerta para evitar drift)
	if raw_input.length() < Joystick_Deadzone:
		raw_input = Vector2.ZERO
		_joystick_input = Vector2.ZERO
	else:
		# Normalizar y reescalar después del deadzone
		var direction = raw_input.normalized()
		var magnitude = (raw_input.length() - Joystick_Deadzone) / (1.0 - Joystick_Deadzone)
		raw_input = direction * magnitude
		
		# Suavizado del input (para movimiento más fluido)
		_joystick_input = _joystick_input.lerp(raw_input, Joystick_Smoothing * delta)
	
	# Si hay movimiento del joystick, rotar la cámara
	if _joystick_input.length() > 0.01:
		# Rotación HORIZONTAL (eje Y) - girar el pivot
		var horizontal_rotation = -_joystick_input.x * Joystick_Sensitivity * delta
		pivot.rotate_y(horizontal_rotation)
		
		# También rotar la geometría si está configurado
		if Geometry and Rotation_Type == rotation_types.Camera_And_Geometry:
			Geometry.rotate_y(horizontal_rotation)
		
		# Rotación VERTICAL (eje X) - girar la cámara
		var vertical_input = _joystick_input.y
		if Invert_Joystick_Y:
			vertical_input = -vertical_input
		
		camera.rotate_x(vertical_input * Joystick_Sensitivity * delta)
		
		# Limitar el ángulo vertical (mismo que con mouse)
		camera.rotation.x = clamp(
			camera.rotation.x, 
			deg_to_rad(Min_Camera_Angle), 
			deg_to_rad(Max_Camera_Angle)
		)
# ======================================================
	
func toggle_active(state : bool):
	Active = state
	if state:		
		camera.make_current()
	else:		
		camera.clear_current()
