extends Area2D

const SPEED = 400.0

const TOPPING_COLORS = [
	Color(0.98, 0.5, 0.45),   # サーモン
	Color(0.8, 0.1, 0.1),     # マグロ
	Color(1.0, 0.85, 0.0),    # 卵
	Color(0.95, 0.95, 0.95),  # イカ
	Color(0.9, 0.4, 0.2),     # エビ
]

var screen_size: Vector2
var game_manager
# 各要素: { "color": Color, "x_offset": float }
var caught_toppings: Array = []

func _ready() -> void:
	screen_size = get_viewport_rect().size
	area_entered.connect(_on_area_entered)

func _draw() -> void:
	# どんぶり（茶色の台形風）
	draw_rect(Rect2(-35, 5, 70, 20), Color(0.55, 0.27, 0.07))  # 暗い茶色
	draw_rect(Rect2(-40, 0, 80, 8), Color(0.65, 0.33, 0.1))    # 縁
	# ごはん（白い山盛り）
	draw_rect(Rect2(-30, -12, 60, 15), Color(1.0, 1.0, 0.95))
	# 積み上がったネタ — 接触時のX位置を保持して描画
	for i in caught_toppings.size():
		var topping = caught_toppings[i]
		var y_offset = -25 - (i * 10)
		var x_pos = clamp(topping["x_offset"] - 25, -30, 20)
		draw_rect(Rect2(x_pos, y_offset, 50, 8), topping["color"])

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
	if area.is_in_group("obstacle") or area.is_in_group("rice_bowl"):
		var points: int = 0
		if area.is_in_group("obstacle"):
			points = randi_range(10, 35)
		elif area.is_in_group("rice_bowl") and area.has_method("get_score"):
			points = area.get_score()

		# ネタのX座標とどんぶりのX座標の差分を保存
		var x_offset = area.global_position.x - global_position.x
		var color = TOPPING_COLORS[randi() % TOPPING_COLORS.size()]
		caught_toppings.append({"color": color, "x_offset": x_offset})
		queue_redraw()

		if game_manager and points > 0:
			game_manager.add_score(points)

		area.call_deferred("queue_free")