extends Area2D

var speed = 400.0
var screen_size: Vector2
var game_manager
var role = "catcher"
var spawn_timer = 0.0
var spawn_interval = 3.0
var obstacle_scene = preload("res://scenes/obstacle.tscn")

func _ready():
    screen_size = get_viewport_rect().size
    add_to_group("player1")
    position = Vector2(screen_size.x / 2.0, screen_size.y - 50.0)
    connect("area_entered", _on_area_entered)
    print("Player 1 Ready!")

func set_role(new_role: String):
    role = new_role
    if role == "catcher":
        add_to_group("catcher")
    else:
        remove_from_group("catcher")
        spawn_timer = 0.0

func _process(delta):
    if not game_manager or not game_manager.game_active:
        return
    if role == "catcher":
        var vel_x = 0.0
        if Input.is_action_pressed("ui_right"):
            vel_x = 1.0
        if Input.is_action_pressed("ui_left"):
            vel_x = -1.0
        position.x += vel_x * speed * delta
        position.x = clamp(position.x, 50.0, screen_size.x - 50.0)
    elif role == "spawner":
        spawn_timer += delta
        if spawn_timer >= spawn_interval:
            spawn_obstacle()
            spawn_timer = 0.0

func spawn_obstacle():
    var obstacle = obstacle_scene.instantiate()
    obstacle.position.x = randf_range(50.0, screen_size.x - 50.0)
    obstacle.position.y = -50.0
    obstacle.add_to_group("obstacle")
    get_parent().add_child(obstacle)
    var tween = get_tree().create_tween()
    tween.tween_property(obstacle, "position:y", screen_size.y + 100.0, (screen_size.y + 150.0) / 300.0)
    tween.tween_callback(obstacle.queue_free)

func _on_area_entered(area: Area2D):
    if role != "catcher":
        return
    if area.is_in_group("obstacle"):
        var penalty = randi_range(10, 35)
        if game_manager:
            game_manager.add_score(-penalty)
        area.queue_free()
    elif area.is_in_group("rice_bowl"):
        var pts: int = area.get("points") if area.get("points") != null else 10
        if game_manager:
            game_manager.add_score(pts)
        area.queue_free()