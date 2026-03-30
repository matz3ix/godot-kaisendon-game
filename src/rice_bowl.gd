extends Area2D

## Points awarded when this bowl is caught.
var points: int = 15
const FALL_SPEED := 200.0

func _process(delta: float) -> void:
position.y += FALL_SPEED * delta
if position.y > get_viewport_rect().size.y + 100.0:
queue_free()
