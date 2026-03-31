extends Area2D

const SPEED = 400.0

# どんぶり描画定数
const TOPPING_START_Y = -16   # ネタ積み上げ開始Y位置
const TOPPING_SPACING = 8     # ネタ間の垂直スペース
const TOPPING_WIDTH = 50      # ネタの幅
const TOPPING_HEIGHT = 7      # ネタの高さ
const TOPPING_OFFSET_X = -25  # ネタのX開始位置

const TOPPING_COLORS = [
	Color(0.98, 0.5, 0.45),   # サーモン
	Color(0.8, 0.1, 0.1),     # マグロ
	Color(1.0, 0.85, 0.0),    # 卵
	Color(0.95, 0.95, 0.95),  # イカ
	Color(0.9, 0.4, 0.2),     # エビ
]

var screen_size: Vector2
var game_manager
var caught_toppings: Array = []

func _ready() -> void:
	screen_size = get_viewport_rect().size
	area_entered.connect(_on_area_entered)

func _draw() -> void:
	# どんぶり（茶色）
	draw_rect(Rect2(-40, 0, 80, 8), Color(0.65, 0.33, 0.1))   # 縁
	draw_rect(Rect2(-35, 5, 70, 20), Color(0.55, 0.27, 0.07))  # 本体
	# ごはん（白）
	draw_rect(Rect2(-30, -12, 60, 15), Color(1.0, 1.0, 0.95))
	# 積み上がったネタ（色情報から描画）
	for i in caught_toppings.size():
		var y_offset = TOPPING_START_Y - (i * TOPPING_SPACING)
		draw_rect(Rect2(TOPPING_OFFSET_X, y_offset, TOPPING_WIDTH, TOPPING_HEIGHT), caught_toppings[i])

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

func _catch_topping() -> void:
	caught_toppings.append(TOPPING_COLORS[randi() % TOPPING_COLORS.size()])
	queue_redraw()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacle"):
		_catch_topping()
		if game_manager:
			game_manager.add_score(randi_range(10, 35))
		area.call_deferred("queue_free")
	elif area.is_in_group("rice_bowl"):
		var points: int = 0
		if area.has_method("get_score"):
			points = area.get_score()
		_catch_topping()
		if game_manager and points > 0:
			game_manager.add_score(points)
		area.call_deferred("queue_free")