# Projectile.gd
extends Area2D

@export var speed: float = 900.0
@export var damage: int = 5
@export var lifetime: float = 1.5

var direction: Vector2 = Vector2.RIGHT
var has_hit := false

@onready var life_timer: Timer = $LifeTimer

func _ready() -> void:
	set_as_top_level(true)
	life_timer.wait_time = lifetime
	life_timer.timeout.connect(queue_free)
	life_timer.start()
	rotation = direction.angle()

	# Choose one based on your enemy type:
	body_entered.connect(_on_body_entered)        # if enemies are PhysicsBody2D
	area_entered.connect(_on_area_entered)        # if enemies are Area2D

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	_hit(body)

func _on_area_entered(area: Node) -> void:
	_hit(area)

func _hit(target: Node) -> void:
	if has_hit:
		return
	has_hit = true
	monitoring = false  # prevent multi-hit in same frame

	if "apply_damage" in target:
		target.apply_damage(damage)

	_spawn_impact_fx()
	queue_free()

func _spawn_impact_fx() -> void:
	# Optional: instance an ImpactEffect at global_position (one-shot AnimatedSprite2D/Particles)
	pass
