extends Node2D
var score = 0
var game_over = false
var player1
var player2

func _ready():
    print("Game Started!")
    player1 = $Player1
    player2 = $Player2
    if player1:
        player1.game_manager = self
    if player2:
        player2.game_manager = self

func _process(delta):
    if game_over:
        if Input.is_action_pressed("ui_accept"):
            get_tree().reload_current_scene()

func add_score(amount):
    score += amount
    if $CanvasLayer/ScoreLabel:
        $CanvasLayer/ScoreLabel.text = "Score: " + str(score)
    print("Score: ", score)

func game_end():
    game_over = true
    print("Game Over! Final Score: ", score)
    if $CanvasLayer/GameOverLabel:
        $CanvasLayer/GameOverLabel.visible = true
