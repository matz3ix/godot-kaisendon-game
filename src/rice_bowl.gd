extends Area2D

const FALL_SPEED = 200.0

const SIZE_DATA = [
	{"score": 10, "half": Vector2(15, 10), "texture": preload("res://asset/samon/samon.png")},    # 小ネタ（サーモン）
	{"score": 15, "half": Vector2(25, 12), "texture": preload("res://asset/maguro/maguro.png")},  # 中ネタ（マグロ）
	{"score": 20, "half": Vector2(35, 15), "texture": preload("res://asset/tamago/tamago.png")},  # 大ネタ（卵）
]

var score_value: int = 10
var _size_type: int = 0
var _half: Vector2 = Vector2(15, 10)

func set_size_type(type: int) -> void:
	_size_type = clamp(type, 0, 2)

func _ready() -> void:
	var data = SIZE_DATA[_size_type]
	score_value = data["score"]
	_half = data["half"]

	var col_shape: RectangleShape2D = $CollisionShape2D.shape.duplicate()
	$CollisionShape2D.shape = col_shape
	col_shape.size = _half * 2.0

	$Sprite2D.texture = data["texture"]

func get_score() -> int:
	return score_value

func _process(delta: float) -> void:
	position.y += FALL_SPEED * delta
	if position.y > get_viewport_rect().size.y + 100.0:
		queue_free()
