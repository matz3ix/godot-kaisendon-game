extends Area2D

const FALL_SPEED = 150.0

const TOPPING_COLORS = [
	Color(0.98, 0.5, 0.45),   # サーモン
	Color(0.8, 0.1, 0.1),     # マグロ
	Color(1.0, 0.85, 0.0),    # 卵
	Color(0.95, 0.95, 0.95),  # イカ
	Color(0.9, 0.4, 0.2),     # エビ
]

func _ready() -> void:
	var color_rect = $ColorRect
	if color_rect:
		color_rect.color = TOPPING_COLORS[randi() % TOPPING_COLORS.size()]

func _process(delta: float) -> void:
	position.y += FALL_SPEED * delta
	if position.y > get_viewport_rect().size.y + 50.0:
		queue_free()
