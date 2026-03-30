extends Area2D

const FALL_SPEED = 200.0

const SIZE_DATA = [
	{"score": 10, "size": Vector2(200, 200), "color": Color(1.0, 0.95, 0.6)},   # 小盛り
	{"score": 15, "size": Vector2(350, 350), "color": Color(1.0, 0.75, 0.3)},   # 普通盛り
	{"score": 20, "size": Vector2(450, 450), "color": Color(1.0, 0.5, 0.1)},    # 大盛り
]

var score_value: int = 10
var _size_type: int = 0

func set_size_type(type: int) -> void:
	_size_type = clamp(type, 0, 2)
	if is_inside_tree():
		_apply_size()

func _ready() -> void:
	_apply_size()

func _apply_size() -> void:
	var data = SIZE_DATA[_size_type]
	score_value = data["score"]
	var half: Vector2 = data["size"] / 2.0

	var rect: ColorRect = $ColorRect
	rect.size = data["size"]
	rect.position = -half
	rect.color = data["color"]

	var col_shape: RectangleShape2D = $CollisionShape2D.shape
	col_shape.size = data["size"]

func get_score() -> int:
	return score_value

func _process(delta: float) -> void:
	position.y += FALL_SPEED * delta
	if position.y > get_viewport_rect().size.y + 100.0:
		queue_free()
