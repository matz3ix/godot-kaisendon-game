extends Node2D

var score_set1 = 0
var score_set2 = 0
var current_set = 1
var time_left = 180.0
var game_active = false
var waiting_for_restart = false

var rice_bowl_scene = preload("res://scenes/rice_bowl.tscn")
var rice_spawn_timer = 0.0
var rice_spawn_interval = 2.0

func _ready():
    $Player1.game_manager = self
    $Player2.game_manager = self
    $Player1.set_role("catcher")
    $Player2.set_role("spawner")
    game_active = true
    update_ui()
    print("Set 1 started!")

func _process(delta):
    if waiting_for_restart:
        if Input.is_action_just_pressed("ui_accept"):
            get_tree().reload_current_scene()
        return

    if not game_active:
        return

    time_left -= delta
    if time_left <= 0.0:
        time_left = 0.0
        game_active = false
        end_set()
        return

    rice_spawn_timer += delta
    if rice_spawn_timer >= rice_spawn_interval:
        spawn_rice_bowl()
        rice_spawn_timer = 0.0

    update_ui()

func spawn_rice_bowl():
    var bowl = rice_bowl_scene.instantiate()
    var screen_size = get_viewport_rect().size
    bowl.position.x = randf_range(50.0, screen_size.x - 50.0)
    bowl.position.y = -50.0
    bowl.game_manager = self
    add_child(bowl)

func add_score(amount: int):
    if current_set == 1:
        score_set1 = max(score_set1 + amount, 0)
    else:
        score_set2 = max(score_set2 + amount, 0)
    update_ui()
    print("Score - Set1:", score_set1, " Set2:", score_set2)

func update_ui():
    var current_score = score_set1 if current_set == 1 else score_set2
    $CanvasLayer/ScoreLabel.text = "スコア: " + str(current_score)
    $CanvasLayer/TimerLabel.text = "残り: " + str(int(time_left)) + "秒"
    $CanvasLayer/SetLabel.text = "セット " + str(current_set) + " / 2"

func end_set():
    if current_set == 1:
        var msg = "セット1終了！\nP1スコア: %d\n\nロール交代します...\n(3秒後にセット2開始)" % score_set1
        $CanvasLayer/GameOverLabel.text = msg
        $CanvasLayer/GameOverLabel.visible = true
        await get_tree().create_timer(3.0).timeout
        start_set_2()
    else:
        show_final_result()

func start_set_2():
    current_set = 2
    time_left = 180.0
    rice_spawn_timer = 0.0
    game_active = true
    $CanvasLayer/GameOverLabel.visible = false
    $Player1.set_role("spawner")
    $Player2.set_role("catcher")
    update_ui()
    print("Set 2 started!")

func show_final_result():
    var result = ""
    if score_set1 > score_set2:
        result = "P1 の勝ち！"
    elif score_set2 > score_set1:
        result = "P2 の勝ち！"
    else:
        result = "引き分け！"
    var msg = "ゲーム終了！\nP1: %d  vs  P2: %d\n%s\n\nEnter でリスタート" % [score_set1, score_set2, result]
    $CanvasLayer/GameOverLabel.text = msg
    $CanvasLayer/GameOverLabel.visible = true
    waiting_for_restart = true
    print("Game finished! P1:", score_set1, " P2:", score_set2)
