# EnemySentry.gd (Godot 4.4.1)
extends CharacterBody2D

@export var hp: int = 3
@export var fire_rate: float = 0.75
@export var projectile_speed: float = 320.0
@export var projectile_scene: PackedScene
@export var player_path: NodePath  # Set this to your Player node in the editor

var player: Node = null

func _ready() -> void:
	if player_path != NodePath():
		player = get_node(player_path)
	var fire_timer: Timer = $FireTimer
	fire_timer.wait_time = fire_rate
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	fire_timer.start()

func _on_fire_timer_timeout() -> void:
	if player == null:
		return
	var to_player: Vector2 = (player.global_position - global_position)
	if to_player == Vector2.ZERO:
		return
	var dir: Vector2 = to_player.normalized()
	_fire(dir)

func _fire(dir: Vector2) -> void:
	if projectile_scene == null:
		return
	var bullet: Area2D = projectile_scene.instantiate()
	bullet.global_position = global_position
	# Assumes EnemyBullet.gd with 'velocity' and 'speed'
	if "velocity" in bullet:
		bullet.velocity = dir * (bullet.speed if ("speed" in bullet) else projectile_speed)
	add_sibling(bullet)  # Put bullet next to enemy in the tree; adjust if you prefer a Projectiles node

func apply_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		queue_free()

# --- Bullet/Collision intake ---

func _on_area_entered(a: Area2D) -> void:
	# If Player bullets are Areas, either: add them to "player_bullet" group,
	# or ensure they expose a 'damage' property. Handle both:
	if a.is_in_group("player_bullet"):
		var dmg: int = 1
		if "damage" in a:
			dmg = int(a.damage)
		apply_damage(dmg)
		a.queue_free()
	elif a.is_in_group("terrain"):
		# In case terrain uses Area2D later.
		pass

func _on_body_entered(b: Node) -> void:
	# If Player bullets are Bodies, or if a stray body bumps this enemy.
	if b.is_in_group("player_bullet"):
		var dmg: int = 1
		if "damage" in b:
			dmg = int(b.damage)
		apply_damage(dmg)
		b.queue_free()
