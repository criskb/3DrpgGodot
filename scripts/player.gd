extends CharacterBody3D

signal npc_interacted(npc_name: String)

@export var move_speed := 6.0
@export var acceleration := 10.0
@export var jump_velocity := 6.0
@export var mouse_sensitivity := 0.002

@onready var pivot: Node3D = $Pivot
@onready var camera: Camera3D = $Pivot/SpringArm3D/Camera3D
@onready var raycast: RayCast3D = $Pivot/SpringArm3D/Camera3D/RayCast3D

var gravity := ProjectSettings.get_setting("physics/3d/default_gravity") as float
var look_pitch := 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		pivot.rotate_y(-event.relative.x * mouse_sensitivity)
		look_pitch = clamp(look_pitch - event.relative.y * mouse_sensitivity, -0.9, 0.6)
		pivot.rotation.x = look_pitch
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("interact"):
		_try_interact()

func _physics_process(delta: float) -> void:
	var input_vector := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	)
	var direction := Vector3.ZERO
	if input_vector.length() > 0.0:
		direction = (pivot.global_transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()
		var target_rotation := atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, delta * 10.0)

	velocity.x = move_toward(velocity.x, direction.x * move_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, direction.z * move_speed, acceleration * delta)

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	move_and_slide()

func _try_interact() -> void:
	if not raycast.is_colliding():
		return
	var collider := raycast.get_collider()
	if collider and collider.is_in_group("npc"):
		emit_signal("npc_interacted", collider.name)
