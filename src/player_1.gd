extends Area2D
var speed = 300
var screen_size
var game_manager

func _ready():
    screen_size = get_viewport_rect().size
    connect("area_entered", Callable(self, "_on_area_entered"))
    print("Player 1 Ready!")

func _process(delta):
    if not game_manager or not game_manager.game_over:
        var velocity = Vector2.ZERO
        if Input.is_action_pressed("ui_right"):
            velocity.x += 1
        if Input.is_action_pressed("ui_left"):
            velocity.x -= 1
        if Input.is_action_pressed("ui_down"):
            velocity.y += 1
        if Input.is_action_pressed("ui_up"):
            velocity.y -= 1

        if velocity.length() > 0:
            velocity = velocity.normalized() * speed
            position += velocity * delta
            position.x = clamp(position.x, 0, screen_size.x)
            position.y = clamp(position.y, 0, screen_size.y)

func _on_area_entered(area):
    if area.is_in_group("obstacle"):
        print("Hit by obstacle! Game Over!")
        if game_manager:
            game_manager.game_end()
    elif area.is_in_group("rice_bowl"):
        print("Caught rice bowl!")
        if game_manager:
            game_manager.add_score(10)
        area.queue_free()