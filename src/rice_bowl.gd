extends Area2D

const FALL_SPEED = 200.0

const SIZE_DATA = [
	{"score": 10, "half": Vector2(15, 10), "color": Color(0.98, 0.5, 0.45)},   # 小ネタ（サーモン）
	{"score": 15, "half": Vector2(25, 12), "color": Color(0.8, 0.1, 0.1)},     # 中ネタ（マグロ）
	{"score": 20, "half": Vector2(35, 15), "color": Color(1.0, 0.85, 0.0)},    # 大ネタ（卵）
]

var score_value: int = 10
var _size_type: int = 0
var _half: Vector2 = Vector2(15, 10)
var _color: Color = Color(0.98, 0.5, 0.45)

func set_size_type(type: int) -> void:
	_size_type = clamp(type, 0, 2)

func _ready() -> void:
	var data = SIZE_DATA[_size_type]
	score_value = data["score"]
	_half = data["half"]
	_color = data["color"]

	var col_shape: RectangleShape2D = $CollisionShape2D.shape.duplicate()
	$CollisionShape2D.shape = col_shape
	col_shape.size = _half * 2.0

func _draw() -> void:
	# ネタ本体
	draw_rect(Rect2(-_half.x, -_half.y, _half.x * 2.0, _half.y * 2.0), _color)
	# ネタの光沢ライン
	draw_rect(Rect2(-_half.x + 2.0, -_half.y + 2.0, _half.x * 2.0 - 4.0, 3.0), _color.lightened(0.3))

func get_score() -> int:
	return score_value

func _process(delta: float) -> void:
	position.y += FALL_SPEED * delta
	if position.y > get_viewport_rect().size.y + 100.0:
		queue_free()
