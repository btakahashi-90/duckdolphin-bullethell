extends Node2D

@export var anchor_y_ratio: float = 2.0 / 3.0  # lower third
@export var rotate_speed_deg: float = 90.0
@export var min_zoom: float = 0.6
@export var max_zoom: float = 2.5
@export var zoom_factor: float = 1.1

@onready var cam2d: Camera2D = $Camera2D

func _ready() -> void:
	cam2d.enabled = true
	_apply_anchor_local_pos()

func _process(delta: float) -> void:
	if Input.is_action_pressed("rotate_clock"):
		rotation += deg_to_rad(rotate_speed_deg) * delta
		_apply_anchor_local_pos()
	if Input.is_action_pressed("rotate_counter_clock"):
		rotation -= deg_to_rad(rotate_speed_deg) * delta
		_apply_anchor_local_pos()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_zoom(cam2d.zoom * (1.0 / zoom_factor)) # zoom in
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_zoom(cam2d.zoom * zoom_factor)         # zoom out

func _set_zoom(new_zoom: Vector2) -> void:
	var z: Vector2 = Vector2(
		clamp(new_zoom.x, min_zoom, max_zoom),
		clamp(new_zoom.y, min_zoom, max_zoom)
	)
	if z != cam2d.zoom:
		cam2d.zoom = z
		_apply_anchor_local_pos()

func _apply_anchor_local_pos() -> void:
	# Desired screen-space offset: player on lower horizontal third
	var vp: Vector2 = get_viewport_rect().size
	var delta_ratio: float = anchor_y_ratio - 0.5  # ~+0.1667
	var screen_off: Vector2 = Vector2(0, vp.y * delta_ratio)

	# Convert screen offset to camera local units:
	# 1) undo zoom
	var local_off: Vector2 = Vector2(screen_off.x / cam2d.zoom.x, screen_off.y / cam2d.zoom.y)
	# 2) rotate into rig/camera space so it moves with rotation
	local_off = local_off.rotated(0.0)  # Camera2D is child of this rig; rig carries rotation

	# To place the player at that screen point, move the CAMERA opposite the offset
	cam2d.position = -local_off
