extends Camera2D

@export var anchor_y_ratio: float = 2.0 / 3.0  # lower third
@export var rotate_speed_deg: float = 90.0
@export var min_zoom: float = 0.6
@export var max_zoom: float = 2.5
@export var zoom_factor: float = 1.1

var _last_rotation: float = 0.0

func _ready() -> void:
	enabled = true
	_apply_anchor_offset(true)

func _process(delta: float) -> void:
	if Input.is_action_pressed("rotate_clock"):
		rotation += deg_to_rad(rotate_speed_deg) * delta
	if Input.is_action_pressed("rotate_counter_clock"):
		rotation -= deg_to_rad(rotate_speed_deg) * delta
	if rotation != _last_rotation:
		_last_rotation = rotation
		_apply_anchor_offset()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_zoom(zoom * (1.0 / zoom_factor))
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_zoom(zoom * zoom_factor)

func _set_zoom(new_zoom: Vector2) -> void:
	var z = Vector2(clamp(new_zoom.x, min_zoom, max_zoom), clamp(new_zoom.y, min_zoom, max_zoom))
	if z != zoom:
		zoom = z
		_apply_anchor_offset()

func _apply_anchor_offset(force: bool = false) -> void:
	# desired screen-space offset: player on lower third
	var vp = get_viewport_rect().size
	var delta_ratio: float = anchor_y_ratio - 0.5
	var screen_off = Vector2(0, -vp.y * delta_ratio)
	# account for zoom, then convert to camera-local by rotating by -rotation
	var local_off = Vector2(screen_off.x / zoom.x, screen_off.y / zoom.y).rotated(-rotation)
	offset = local_off
