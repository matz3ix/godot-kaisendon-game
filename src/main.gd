extends Node2D

const SET_DURATION := 180.0
const RICE_SPAWN_INTERVAL := 1.5

var score: int = 0
var score_set1: int = 0
var current_set: int = 1
var time_left: float = SET_DURATION
var rice_timer: float = 0.0
var game_active: bool = false

@onready var player1 = $Player1
@onready var player2 = $Player2
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var timer_label: Label = $CanvasLayer/TimerLabel
@onready var set_label: Label = $CanvasLayer/SetLabel
@onready var result_label: Label = $CanvasLayer/ResultLabel

var rice_bowl_scene = preload("res://scenes/rice_bowl.tscn")

func _ready() -> void:
player1.game_manager = self
player2.game_manager = self
start_set()

func start_set() -> void:
score = 0
time_left = SET_DURATION
rice_timer = 0.0
game_active = true
result_label.visible = false
set_label.text = "セット %d" % current_set
_update_ui()
print("Set %d started!" % current_set)

func _process(delta: float) -> void:
if not game_active:
return
time_left -= delta
rice_timer += delta
if rice_timer >= RICE_SPAWN_INTERVAL:
_spawn_rice_bowl()
rice_timer = 0.0
_update_ui()
if time_left <= 0.0:
_end_set()

func _spawn_rice_bowl() -> void:
var screen_size := get_viewport_rect().size
var bowl = rice_bowl_scene.instantiate()
bowl.position.x = randf_range(50.0, screen_size.x - 50.0)
bowl.position.y = -50.0
# Random type: 0=small(+10), 1=normal(+15), 2=large(+20)
bowl.points = [10, 15, 20][randi() % 3]
bowl.add_to_group("rice_bowl")
add_child(bowl)

func add_score(amount: int) -> void:
score += amount
_update_ui()

func _update_ui() -> void:
score_label.text = "スコア: %d" % score
timer_label.text = "残り: %d秒" % int(max(time_left, 0.0))

func _end_set() -> void:
game_active = false
# Clean up falling objects
for node in get_children():
if node.is_in_group("rice_bowl") or node.is_in_group("obstacle"):
node.queue_free()

if current_set == 1:
score_set1 = score
result_label.text = (
"セット1終了!\nスコア: %d点\n\nEnterキーでセット2開始\n(役割が交代します)" % score_set1
)
result_label.visible = true
else:
_show_final_result()

func _show_final_result() -> void:
var winner: String
if score_set1 > score:
winner = "1P の勝ち! 🎉"
elif score > score_set1:
winner = "2P の勝ち! 🎉"
else:
winner = "引き分け!"
result_label.text = (
"ゲーム終了!\n"
+ "セット1 (1Pキャッチ): %d点\n" % score_set1
+ "セット2 (2Pキャッチ): %d点\n\n" % score
+ winner
+ "\n\nEnterキーで再スタート"
)
result_label.visible = true

func _input(event: InputEvent) -> void:
if event.is_action_pressed("ui_accept") and not game_active:
if current_set == 1:
current_set = 2
player1.is_catcher = false
player2.is_catcher = true
player1.spawn_timer = 0.0
player2.position = Vector2(
get_viewport_rect().size.x / 2.0,
get_viewport_rect().size.y - 60.0
)
start_set()
else:
get_tree().reload_current_scene()
