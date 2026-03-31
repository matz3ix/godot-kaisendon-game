extends Area2D

const FALL_SPEED = 150.0

const TOPPING_TEXTURES = [
	preload("res://asset/samon/samon.png"),    # サーモン
	preload("res://asset/maguro/maguro.png"),  # マグロ
	preload("res://asset/tamago/tamago.png"),  # 卵
	preload("res://asset/ikura/ikura.png"),    # いくら
	preload("res://asset/ebi/ebi.png"),        # エビ
]

func _ready() -> void:
	$Sprite2D.texture = TOPPING_TEXTURES[randi() % TOPPING_TEXTURES.size()]

func _process(delta: float) -> void:
	position.y += FALL_SPEED * delta
	if position.y > get_viewport_rect().size.y + 50.0:
		queue_free()
