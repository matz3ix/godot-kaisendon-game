extends Node2D

const GAME_DURATION = 180.0
const RICE_SPAWN_INTERVAL = 2.0

var rice_bowl_scene = preload("res://scenes/rice_bowl.tscn")

var current_score: int = 0
var score_set1: int = 0
var set_number: int = 1
var time_remaining: float = GAME_DURATION
var game_active: bool = false
var rice_spawn_timer: float = 0.0

func _ready() -> void:
	$Player1.game_manager = self
	$Player2.game_manager = self
	_start_set()

func _start_set() -> void:
	current_score = 0
	time_remaining = GAME_DURATION
	rice_spawn_timer = 0.0
	game_active = true
	$CanvasLayer/GameOverLabel.visible = false
	_update_ui()

func _process(delta: float) -> void:
	if not game_active:
		if Input.is_action_just_pressed("ui_accept"):
			if set_number == 1:
				set_number = 2
				_start_set()
			else:
				get_tree().reload_current_scene()
		return

	time_remaining -= delta
	rice_spawn_timer += delta

	if rice_spawn_timer >= RICE_SPAWN_INTERVAL:
		_spawn_rice_bowl()
		rice_spawn_timer = 0.0

	_update_ui()

	if time_remaining <= 0.0:
		_end_set()

func _spawn_rice_bowl() -> void:
	var screen_x: float = get_viewport().get_visible_rect().size.x
	var bowl = rice_bowl_scene.instantiate()
	bowl.set_size_type(randi() % 3)
	bowl.position.x = randf_range(50.0, screen_x - 50.0)
	bowl.position.y = -50.0
	bowl.add_to_group("rice_bowl")
	add_child(bowl)

func add_score(amount: int) -> void:
	current_score += amount
	_update_ui()

func deduct_score(amount: int) -> void:
	current_score -= amount
	_update_ui()

func _end_set() -> void:
	game_active = false
	var label: Label = $CanvasLayer/GameOverLabel
	if set_number == 1:
		score_set1 = current_score
		label.text = "セット1終了！\nスコア: %d\n\nENTERでセット2へ" % score_set1
	else:
		var total: int = score_set1 + current_score
		label.text = "ゲーム終了！\nセット1: %d\nセット2: %d\n合計: %d\n\nENTERでリスタート" % [score_set1, current_score, total]
	label.visible = true

func _update_ui() -> void:
	$CanvasLayer/ScoreLabel.text = "Score: %d" % current_score
	$CanvasLayer/TimerLabel.text = "Time: %d" % int(maxf(0.0, time_remaining))
	$CanvasLayer/SetLabel.text = "Set: %d / 2" % set_number
