extends Area2D

const SPEED = 400.0

var screen_size: Vector2
var game_manager
var topping_count: int = 0

func _ready() -> void:
	screen_size = get_viewport_rect().size
	area_entered.connect(_on_area_entered)

func _draw() -> void:
	# どんぶり（茶色の台形風）
	draw_rect(Rect2(-35, 5, 70, 20), Color(0.55, 0.27, 0.07))  # 暗い茶色
	draw_rect(Rect2(-40, 0, 80, 8), Color(0.65, 0.33, 0.1))    # 縁
	# ごはん（白い山盛り）
	draw_rect(Rect2(-30, -12, 60, 15), Color(1.0, 1.0, 0.95))

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

		if game_manager and points > 0:
			game_manager.add_score(points)

		# ネタをどんぶりの子ノードにする（reparent）
		area.reparent(self)

		# ネタの物理処理を止める
		area.set_process(false)
		area.set_physics_process(false)

		# ネタをどんぶりの上に積み上げる位置に配置
		area.position = Vector2(0, -20 - (topping_count * 15))
		topping_count += 1

		# ネタの当たり判定を無効化（二重キャッチ防止）
		area.monitoring = false
		area.monitorable = false

		# CollisionShape2D を無効化
		for child in area.get_children():
			if child is CollisionShape2D:
				child.set_deferred("disabled", true)