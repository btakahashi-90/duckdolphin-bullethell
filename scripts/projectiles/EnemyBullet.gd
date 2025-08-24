# EnemyBullet.gd (Godot 4.4.1)
extends Area2D

@export var speed: float = 320.0
@export var lifetime: float = 2.0
@export var damage: int = 1

var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Auto-despawn
	var t: Timer = Timer.new()
	t.one_shot = true
	t.wait_time = lifetime
	add_child(t)
	t.start()
	t.timeout.connect(_on_lifetime_timeout)
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += velocity * delta

func _on_area_entered(a: Area2D) -> void:
	# If you later give Terrain colliders as Area2D, this will handle them too.
	queue_free()

func _on_body_entered(b: Node) -> void:
	# Hit Player or Terrain bodies → try to apply damage if the body supports it
	if "apply_damage" in b:
		b.apply_damage(damage)
	queue_free()

func _on_lifetime_timeout() -> void:
	queue_free()
