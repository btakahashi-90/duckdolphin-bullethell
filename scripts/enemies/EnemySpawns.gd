# EnemySpawns.gd (Godot 4.4.1)
extends Node2D

@export var enemy_scene: PackedScene
@export var enemies_container_path: NodePath = ^"../Enemies"
@export var player_path: NodePath = ^"../Player"

func _ready() -> void:
	var enemies_container: Node = get_node(enemies_container_path)
	var player: Node = get_node(player_path)
	if enemy_scene == null or enemies_container == null or player == null:
		return
	for child in get_children():
		if child is Marker2D:
			var e: Node2D = enemy_scene.instantiate()
			if "player_path" in e:
				e.player_path = player.get_path()
			e.global_position = (child as Marker2D).global_position
			enemies_container.add_child(e)
