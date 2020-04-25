extends Area2D

var rainbow_ray_path = "res://Rainbow/RainbowRay.tscn"
var rainbow_ray_scene = load(rainbow_ray_path)

var rainbow_colors = ["#ff0000", "#ffa500", "#ffff00", "#008000", "#0000ff", "#4b0082", "#ee82ee"]

var area: Vector2


func _ready():
	self.area = $RainbowArea.shape.extents


func _clear_rainbow():
	for ray in self.get_children():
		if ray.get_filename() == self.rainbow_ray_scene.get_path():
			ray.queue_free()


func _add_ray(ray_area, start_position, color):
	var rainbow_ray = rainbow_ray_scene.instance()
	rainbow_ray.ray_size = ray_area
	rainbow_ray.position.x = start_position
	rainbow_ray.color = color
	add_child(rainbow_ray)
	

func _color_palette(rays):
	var palette = self.rainbow_colors.slice(0, rays-1)
	palette.shuffle()
	return palette


func _calculate_ray_width(rays, rainbow_width):
	var ray_transitions = [1]
	
	#var delta = rainbow_width/rays
	for _i in range(0, rays - 1):
		var ray_transition = randf() * rainbow_width
		ray_transitions.append(ray_transition)#(delta*(i+1))

	ray_transitions.append(rainbow_width-1)
	ray_transitions.sort()
	return ray_transitions


func raise_rainbow(rays):
	rays = clamp(rays, 1, self.rainbow_colors.size())
	self._clear_rainbow()
	var ray_transitions = _calculate_ray_width(rays, self.area.x)
	var palette = self._color_palette(rays)
	var ray_position = -self.area.x
	
	for i in range(0, ray_transitions.size() - 1):
		var ray_width = (ray_transitions[i + 1] - ray_transitions[i])
		var ray_size = Vector2(ray_width, self.area.y)
		ray_position += ray_width
		var ray_color =  palette[i]
		self._add_ray(ray_size, ray_position, ray_color)
		ray_position +=  ray_width


func is_clear():
	var rainbow_bodies = self.get_overlapping_bodies()
	return rainbow_bodies.size() == 0
