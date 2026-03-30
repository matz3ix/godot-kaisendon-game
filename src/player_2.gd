extends Node

const SPAWN_INTERVAL = 3.0

var obstacle_scene = preload("res://scenes/obstacle.tscn")
var spawn_timer: float = 0.0
var game_manager

func _process(delta: float) -> void:
	if not game_manager or not game_manager.game_active:
		return

	spawn_timer += delta
	if spawn_timer >= SPAWN_INTERVAL:
		_spawn_obstacle()
		spawn_timer = 0.0

func _spawn_obstacle() -> void:
	var screen: Vector2 = get_viewport().get_visible_rect().size
	var obstacle = obstacle_scene.instantiate()
	obstacle.position.x = randf_range(50.0, screen.x - 50.0)
	obstacle.position.y = -50.0
	obstacle.add_to_group("obstacle")
	get_parent().add_child(obstacle)
	var tween: Tween = create_tween()
	tween.tween_property(obstacle, "position:y", screen.y + 50.0, 5.0)
	tween.tween_callback(obstacle.queue_free)