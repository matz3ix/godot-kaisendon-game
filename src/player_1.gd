extends Area2D

# Player 1 (rice bowl catcher) script

# Called when the node enters the scene tree for the first time.
func _ready():
    print("Player 1 is ready!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    handle_input()

func handle_input():
    if Input.is_action_pressed('ui_left'):
        position.x -= 5
    if Input.is_action_pressed('ui_right'):
        position.x += 5
    if Input.is_action_pressed('ui_up'):
        position.y -= 5
    if Input.is_action_pressed('ui_down'):
        position.y += 5
