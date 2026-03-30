extends Area2D

const SPEED = 400.0

var screen_size: Vector2
var game_manager

func _ready() -> void:
	screen_size = get_viewport_rect().size
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if not game_manager or not game_manager.game_active:
		return

	var vel_x: float = 0.0
	if Input.is_action_pressed("ui_right"):
		vel_x += 1.0
	if Input.is_action_pressed("ui_left"):
		vel_x -= 1.0

	position.x += vel_x * SPEED * delta
	position.x = clamp(position.x, 0.0, screen_size.x)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacle"):
		var penalty: int = randi_range(10, 35)
		if game_manager:
			game_manager.deduct_score(penalty)
		area.queue_free()
	elif area.is_in_group("rice_bowl"):
		var points: int = area.get_score()
		if game_manager:
			game_manager.add_score(points)
		area.queue_free()