extends Node

# Player 2 (obstacle spawner) script

var obstacle_scene = preload("res://scenes/obstacle.tscn")
var spawn_timer = 0.0
var spawn_interval = 3.0  # Spawn an obstacle every 3 seconds

func _ready():
    print("Player 2 is ready!")

func _process(delta):
    spawn_timer += delta
    if spawn_timer >= spawn_interval:
        spawn_obstacle()
        spawn_timer = 0.0

func spawn_obstacle():
    var obstacle = obstacle_scene.instantiate()
    # Set random x position
    obstacle.position.x = randf() * 800
    obstacle.position.y = -50
    add_child(obstacle)
    print("Obstacle spawned!")