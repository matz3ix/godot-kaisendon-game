extends Area2D

var fall_speed = 200.0
var points = 10
var screen_size: Vector2
var game_manager

func _ready():
    screen_size = get_viewport_rect().size
    add_to_group("rice_bowl")
    # Create a unique shape so multiple instances don't share it
    var shape = CircleShape2D.new()
    $CollisionShape2D.shape = shape
    # Randomise bowl type: 0=小盛り, 1=普通盛り, 2=大盛り
    var bowl_type = randi() % 3
    if bowl_type == 0:
        points = 10
        shape.radius = 30.0
        $ColorRect.size = Vector2(60, 60)
        $ColorRect.position = Vector2(-30, -30)
        $ColorRect.color = Color(0.9, 0.85, 0.4, 1)
    elif bowl_type == 1:
        points = 15
        shape.radius = 50.0
        $ColorRect.size = Vector2(100, 100)
        $ColorRect.position = Vector2(-50, -50)
        $ColorRect.color = Color(0.8, 0.75, 0.2, 1)
    else:
        points = 20
        shape.radius = 70.0
        $ColorRect.size = Vector2(140, 140)
        $ColorRect.position = Vector2(-70, -70)
        $ColorRect.color = Color(0.7, 0.65, 0.1, 1)

func _process(delta):
    position.y += fall_speed * delta
    if position.y > screen_size.y + 100.0:
        if game_manager:
            game_manager.add_score(-5)
        queue_free()
