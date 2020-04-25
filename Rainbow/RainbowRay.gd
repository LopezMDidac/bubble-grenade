extends Area2D

var ray_size: Vector2
var color: Color

func _ready():
	$RayArea.shape.extents = self.ray_size
	$Color.rect_size = self.ray_size * 2
	$Color.rect_position.x -= ray_size.x
	$Color.color = color


func _on_RainbowRay_body_entered(body):
	body.set_color($Color.color)


func _on_RainbowRay_body_exited(body):
	body.set_color($Color.color)
