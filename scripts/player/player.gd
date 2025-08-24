class_name Player
extends CharacterBody2D

@onready var animated_sprite = $anim_sprite
@onready var muzzle_distance = 12.0
@onready var fire_cooldown = $FireCooldown
@onready var camera_rig = $CameraRig

@export var projectile_root_path: NodePath
@export var fire_rate = 0.18
@export var projectile_scene: PackedScene

@onready var projectile_root: Node = get_node(projectile_root_path)


var can_fire = true

const SPEED = 150.0

func _ready():
	# Enforce single Player instance at runtime
	add_to_group("player")
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 1:
		var keep: Node = players[0]
		if keep != self:
			push_warning("Duplicate Player detected; removing this instance: %s" % [self])
			queue_free()
			return
	
	fire_cooldown.wait_time = fire_rate
	fire_cooldown.timeout.connect(_on_fire_cooldown_timeout)

func _process(delta):
	if Input.is_action_pressed("fire") and can_fire:
		_shoot()
		can_fire = false
		fire_cooldown.start()
		
func _on_fire_cooldown_timeout():
	can_fire = true
	
func _shoot():
	if projectile_scene == null or projectile_root == null: return
	var dir = (get_global_mouse_position() - global_position).normalized()
	var spawn = global_position + dir * muzzle_distance  # your muzzle distance
	var p = projectile_scene.instantiate()
	p.global_position = spawn
	p.direction = dir
	projectile_root.add_child(p)
	
func _physics_process(delta):
	var input_dir = Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1

	# 2) Normalize (so diagonals aren’t faster)
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()

	# 3) Rotate into world space by the camera’s rotation
	#    Now W is always "forward on screen", A is "left on screen", etc.
	var input_world: Vector2 = input_dir.rotated(camera_rig.rotation)
	
	velocity = input_world.normalized() * SPEED
	
	# Keep sprite rotated opposite the rig so it appears glued to screen
	animated_sprite.rotation = camera_rig.rotation

	move_and_slide()
	
	# Animation control
	if input_dir.x != 0:
		animated_sprite.flip_h = input_dir.x < 0

	if input_dir != Vector2.ZERO:
		if not animated_sprite.is_playing() or animated_sprite.animation != "walk":
			animated_sprite.play("walk")
	else:
		if not animated_sprite.is_playing() or animated_sprite.animation != "idle":
			animated_sprite.play("idle")
