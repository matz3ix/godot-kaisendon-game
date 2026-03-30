extends Node
var obstacle_scene = preload("res://scenes/obstacle.tscn")
var spawn_timer = 0.0
var spawn_interval = 2.0
var screen_size
var game_manager

func _ready():
    screen_size = get_viewport_rect().size
    print("Player 2 Ready!")

func _process(delta):
    if not game_manager or not game_manager.game_over:
        spawn_timer += delta
        if spawn_timer >= spawn_interval:
            spawn_obstacle()
            spawn_timer = 0.0

func spawn_obstacle():
    var obstacle = obstacle_scene.instantiate()
    obstacle.position.x = randf_range(50, screen_size.x - 50)
    obstacle.position.y = -50
    obstacle.add_to_group("obstacle")
    get_parent().add_child(obstacle)
    var tween = create_tween()
    tween.tween_property(obstacle, "position:y", screen_size.y + 50, 5.0)
    tween.tween_callback(obstacle.queue_free)