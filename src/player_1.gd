extends Area2D

const SPEED = 400.0

var screen_size: Vector2
var game_manager

func _ready() -> void:
	screen_size = get_viewport_rect().size
	area_entered.connect(_on_area_entered)

func _draw() -> void:
	# どんぶり（茶色）
	draw_rect(Rect2(-40, 0, 80, 8), Color(0.65, 0.33, 0.1))   # 縁
	draw_rect(Rect2(-35, 5, 70, 20), Color(0.55, 0.27, 0.07))  # 本体
	# ごはん（白）
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

func _freeze_topping_in_place(area: Area2D) -> void:
	if not is_instance_valid(area):
		return

	# 衝突した瞬間のグローバル位置を保存
	var frozen_global_pos = area.global_position

	# 落下を停止
	area.set_process(false)
	area.set_physics_process(false)

	# Player1の子ノードに移動
	var old_parent = area.get_parent()
	if old_parent:
		old_parent.remove_child(area)
	add_child(area)

	# グローバル位置を復元（reparentでローカル座標が変わるため）
	area.global_position = frozen_global_pos

	# 積まれたネタに新しいネタが乗れるよう area_entered を接続
	if not area.area_entered.is_connected(_on_stacked_topping_hit):
		area.area_entered.connect(_on_stacked_topping_hit.bind(area))

func _handle_catch(area: Area2D) -> void:
	# スコアを加算（グループ変更前に判定）
	if game_manager:
		if area.is_in_group("rice_bowl") and area.has_method("get_score"):
			game_manager.add_score(area.get_score())
		else:
			game_manager.add_score(randi_range(10, 35))

	# 二重処理を防ぐため即座にグループを変更
	area.remove_from_group("obstacle")
	area.remove_from_group("rice_bowl")
	area.add_to_group("stacked_topping")

	call_deferred("_freeze_topping_in_place", area)

func _on_stacked_topping_hit(hitting_area: Area2D, _stacked_area: Area2D) -> void:
	# 落下中のネタだけ処理する
	if not hitting_area.is_in_group("obstacle") and not hitting_area.is_in_group("rice_bowl"):
		return
	_handle_catch(hitting_area)

func _on_area_entered(area: Area2D) -> void:
	# 落下中のネタだけ処理する（積み済みは無視）
	if not area.is_in_group("obstacle") and not area.is_in_group("rice_bowl"):
		return
	_handle_catch(area)