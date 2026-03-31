extends Area2D

const SPEED = 400.0

var screen_size: Vector2
var game_manager

func _ready() -> void:
	screen_size = get_viewport_rect().size
	area_entered.connect(_on_area_entered)
	$Sprite2D.texture = preload("res://asset/donburi/donburi.png")

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

func _catch_topping(area, _hit_by = null) -> void:
	call_deferred("_freeze_topping_in_place", area)

func _freeze_topping_in_place(area) -> void:
	if not is_instance_valid(area):
		return

	# ① 衝突した時点のグローバル位置を保存
	var frozen_global_pos = area.global_position

	# ② 落下を停止
	area.set_process(false)
	area.set_physics_process(false)

	# ③ どんぶり（self）の子要素に reparent
	var old_parent = area.get_parent()
	if old_parent:
		old_parent.remove_child(area)
	add_child(area)

	# ④ 衝突した位置を復元
	area.global_position = frozen_global_pos

	# ⑤ グループ変更
	area.remove_from_group("obstacle")
	area.remove_from_group("rice_bowl")
	area.add_to_group("stacked_topping")

	# ⑥ 当たり判定を維持（他のネタもキャッチできるように）
	if area is Area2D:
		if not area.area_entered.is_connected(_on_stacked_topping_hit):
			area.area_entered.connect(_on_stacked_topping_hit.bind(area))

func _catch_and_score(area) -> void:
	_catch_topping(area)
	if area.is_in_group("obstacle"):
		if game_manager:
			game_manager.add_score(randi_range(10, 35))
	elif area.is_in_group("rice_bowl"):
		var points: int = 0
		if area.has_method("get_score"):
			points = area.get_score()
		if game_manager and points > 0:
			game_manager.add_score(points)

func _is_hitting_from_above(hitting_area, target_area) -> bool:
	return hitting_area.global_position.y < target_area.global_position.y

func _on_stacked_topping_hit(hitting_area, stacked_area) -> void:
	if not _is_hitting_from_above(hitting_area, stacked_area):
		return
	if hitting_area.is_in_group("obstacle") or hitting_area.is_in_group("rice_bowl"):
		_catch_and_score(hitting_area)

func _on_area_entered(area: Area2D) -> void:
	if not _is_hitting_from_above(area, self):
		return
	if area.is_in_group("obstacle") or area.is_in_group("rice_bowl"):
		_catch_and_score(area)
