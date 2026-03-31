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
# 各要素: { "color": Color, "x_offset": float, "y_pos": float, "size": Vector2 }
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
	# 積み上がったネタ — 各ネタの y_pos（上端）と size で描画
	for topping in caught_toppings:
		var size = topping.get("size", DEFAULT_TOPPING_SIZE)
		var x_pos = topping["x_offset"] - size.x / 2.0
		var y = topping["y_pos"]
		draw_rect(Rect2(x_pos, y, size.x, size.y), topping["color"])

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

func _get_area_size(area: Area2D) -> Vector2:
	for child in area.get_children():
		if child is CollisionShape2D and child.shape is RectangleShape2D:
			return child.shape.size
	return DEFAULT_TOPPING_SIZE

func _get_area_color(area: Area2D) -> Color:
	var color_rect = area.get_node_or_null("ColorRect")
	if color_rect:
		return color_rect.color
	var area_color = area.get("_color")
	if area_color != null:
		return area_color
	return TOPPING_COLORS[randi() % TOPPING_COLORS.size()]

func _catch_topping(area: Area2D, hit_by: Area2D = null) -> bool:
	# 多重処理を防ぐ（同じネタが複数のエリアに同時に当たった場合）
	if area.has_meta("being_caught"):
		return false
	area.set_meta("being_caught", true)

	var topping_size = _get_area_size(area)
	var x_offset: float
	var y_pos: float

	if hit_by != null and hit_by != self and is_instance_valid(hit_by):
		# 当たったネタの直上に配置
		x_offset = hit_by.position.x
		y_pos = hit_by.position.y - topping_size.y
	else:
		# どんぶりのごはんの上に配置
		x_offset = 0.0
		y_pos = -12.0 - topping_size.y

	call_deferred("_add_topping_to_bowl", area, x_offset, y_pos)
	return true

func _add_topping_to_bowl(area: Area2D, x_offset: float, y_pos: float) -> void:
	if not is_instance_valid(area):
		return

	var color = _get_area_color(area)
	var topping_size = _get_area_size(area)

	# 視覚データを追加
	caught_toppings.append({"color": color, "x_offset": x_offset, "y_pos": y_pos, "size": topping_size})

	# 当たり判定用の子 Area2D ノードを作成
	# position = ネタの上端（y_pos）に合わせる
	var stacked = Area2D.new()
	stacked.add_to_group("stacked_topping")
	var shape_node = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = topping_size
	shape_node.shape = rect
	# y_pos はネタ上端。CollisionShape2D は中心基準なので size.y/2 だけ下にずらす
	shape_node.position = Vector2(0.0, topping_size.y / 2.0)
	stacked.add_child(shape_node)
	stacked.position = Vector2(x_offset, y_pos)
	add_child(stacked)
	stacked.area_entered.connect(_on_stacked_topping_hit.bind(stacked))

	# 元の落下ネタを削除
	area.queue_free()
	queue_redraw()

# stacked_area（積まれたネタ）に hitting_area（降ってきたネタ）が触れた
func _on_stacked_topping_hit(hitting_area: Area2D, stacked_area: Area2D) -> void:
	if hitting_area.is_in_group("obstacle") or hitting_area.is_in_group("rice_bowl"):
		if _catch_topping(hitting_area, stacked_area):
			_add_score_for_area(hitting_area)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacle") or area.is_in_group("rice_bowl"):
		if _catch_topping(area):
			_add_score_for_area(area)

func _add_score_for_area(area: Area2D) -> void:
	if not game_manager:
		return
	if area.is_in_group("rice_bowl") and area.has_method("get_score"):
		var points: int = area.get_score()
		if points > 0:
			game_manager.add_score(points)
	else:
		game_manager.add_score(randi_range(10, 35))