extends Area2D

const SPEED := 400.0

## Set by the game manager (main.gd) at startup.
var game_manager = null
## True when this player is the bowl-catcher; false when acting as obstacle spawner.
var is_catcher: bool = true
var spawn_timer: float = 0.0
const SPAWN_INTERVAL := 3.0

var _obstacle_scene = preload("res://scenes/obstacle.tscn")
var _screen_size: Vector2

func _ready() -> void:
_screen_size = get_viewport_rect().size
position = Vector2(_screen_size.x / 2.0, _screen_size.y - 60.0)
connect("area_entered", _on_area_entered)

func _process(delta: float) -> void:
visible = is_catcher
monitoring = is_catcher
if not game_manager or not game_manager.game_active:
return
if is_catcher:
_move(delta)
else:
_tick_spawner(delta)

func _move(delta: float) -> void:
var vel: float = 0.0
if Input.is_action_pressed("ui_left"):
vel -= SPEED
if Input.is_action_pressed("ui_right"):
vel += SPEED
position.x = clamp(position.x + vel * delta, 50.0, _screen_size.x - 50.0)

func _tick_spawner(delta: float) -> void:
spawn_timer += delta
if spawn_timer >= SPAWN_INTERVAL:
_spawn_obstacle()
spawn_timer = 0.0

func _spawn_obstacle() -> void:
var obs = _obstacle_scene.instantiate()
obs.position.x = randf_range(50.0, _screen_size.x - 50.0)
obs.position.y = -50.0
obs.add_to_group("obstacle")
get_parent().add_child(obs)
var tween := get_parent().create_tween()
tween.tween_property(obs, "position:y", _screen_size.y + 50.0, 5.0)
tween.tween_callback(obs.queue_free)

func _on_area_entered(area: Area2D) -> void:
if not is_catcher or not game_manager:
return
if area.is_in_group("rice_bowl"):
game_manager.add_score(area.points)
area.queue_free()
elif area.is_in_group("obstacle"):
game_manager.add_score(-15)
area.queue_free()
