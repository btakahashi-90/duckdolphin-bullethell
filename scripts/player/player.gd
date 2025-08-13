class_name Player
extends CharacterBody2D

@onready var animated_sprite = $anim_sprite
@onready var muzzle_distance = 12.0
@onready var fire_cooldown = $FireCooldown

@export var projectile_root_path: NodePath
@export var fire_rate = 0.18
@export var projectile_scene: PackedScene

@onready var projectile_root: Node = get_node(projectile_root_path)


var can_fire = true

const SPEED = 150.0

func _ready():
	# Detect duplicates BEFORE adding to group
	var others = get_tree().get_nodes_in_group("player")
	if others.size() > 0:
		push_error("Duplicate Player detected at runtime: " + str(others))
	add_to_group("player")
	var all_players = get_tree().get_nodes_in_group("player")
	print("[PLAYER] instances in tree: ", all_players.size(), " -> ", all_players)
	
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

	velocity = input_dir.normalized() * SPEED
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
