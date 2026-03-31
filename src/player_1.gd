extends Area2D

const SPEED = 400.0

const TOPPING_COLORS = [
	Color(0.98, 0.5, 0.45),   # サーモン
	Color(0.8, 0.1, 0.1),     # マグロ
	Color(1.0, 0.85, 0.0),    # 卵
	Color(0.95, 0.95, 0.95),  # イカ
	Color(0.9, 0.4, 0.2),     # エビ
]

const DEFAULT_TOPPING_SIZE = Vector2(50, 50)

var screen_size: Vector2
var game_manager
# 各要素: { "color": Color, "x_offset": float, "size": Vector2 }
var caught_toppings: Array = []
# CollisionShape2D の元の高さ（_ready で取得）
var _base_collision_height: float = 35.0

func _ready() -> void:
	screen_size = get_viewport_rect().size
	area_entered.connect(_on_area_entered)
	# シェイプをインスタンス固有に複製し、元の高さを記録
	var collision = $CollisionShape2D
	if collision and collision.shape is RectangleShape2D:
		collision.shape = collision.shape.duplicate()
		_base_collision_height = collision.shape.size.y

func _draw() -> void:
	# どんぶり（茶色）
	draw_rect(Rect2(-40, 0, 80, 8), Color(0.65, 0.33, 0.1))   # 縁
	draw_rect(Rect2(-35, 5, 70, 20), Color(0.55, 0.27, 0.07))  # 本体
	# ごはん（白）
	draw_rect(Rect2(-30, -12, 60, 15), Color(1.0, 1.0, 0.95))
	# 積み上がったネタ — 落下時と同じサイズ・色で描画
	var y_pos = -12.0  # ごはんの上面
	for i in caught_toppings.size():
		var topping = caught_toppings[i]
		var size = topping.get("size", DEFAULT_TOPPING_SIZE)
		y_pos -= size.y
		var x_pos = topping["x_offset"] - size.x / 2.0
		draw_rect(Rect2(x_pos, y_pos, size.x, size.y), topping["color"])

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

func _catch_topping(area: Area2D) -> void:
	# 落下中のネタから実際の色を取得
	var color: Color
	var color_rect = area.get_node_or_null("ColorRect")
	if color_rect:
		color = color_rect.color
	else:
		var area_color = area.get("_color")
		if area_color != null:
			color = area_color
		else:
			color = TOPPING_COLORS[randi() % TOPPING_COLORS.size()]

	# 落下中のネタから実際のサイズを取得
	var topping_size = DEFAULT_TOPPING_SIZE
	for child in area.get_children():
		if child is CollisionShape2D and child.shape is RectangleShape2D:
			topping_size = child.shape.size
			break

	var x_offset = area.global_position.x - global_position.x
	caught_toppings.append({"color": color, "x_offset": x_offset, "size": topping_size})
	queue_redraw()
	# 当たり判定をネタのスタック分だけ上方向に拡大（物理処理外で安全に実行）
	call_deferred("_update_collision_shape")

func _update_collision_shape() -> void:
	var collision = $CollisionShape2D
	if not (collision and collision.shape is RectangleShape2D):
		return
	var base_height = _base_collision_height
	var topping_total_height = 0.0
	for topping in caught_toppings:
		var size = topping.get("size", DEFAULT_TOPPING_SIZE)
		topping_total_height += size.y
	collision.shape.size.y = base_height + topping_total_height
	# 下端を固定したまま中心を上にずらす
	collision.position.y = -(topping_total_height / 2.0)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacle"):
		_catch_topping(area)
		if game_manager:
			game_manager.add_score(randi_range(10, 35))
		area.call_deferred("queue_free")
	elif area.is_in_group("rice_bowl"):
		_catch_topping(area)
		var points: int = 0
		if area.has_method("get_score"):
			points = area.get_score()
		if game_manager and points > 0:
			game_manager.add_score(points)
		area.call_deferred("queue_free")