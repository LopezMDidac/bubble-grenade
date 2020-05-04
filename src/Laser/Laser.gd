extends Line2D


func _calculate_next_reflect(start_point, direction, laser_length):
	var return_value = {}
	return_value["is_last"] = true
	var space_state = get_world_2d().direct_space_state
	var target = start_point + laser_length * direction
	var result = space_state.intersect_ray(start_point, target)
	if result.size() > 0:
		return_value["vertex"] = result["position"] - direction * 32
		var collider = result["collider"] 
		if (
			collider.get("collision_type") 
			and collider.get("collision_type")  == collider.COLLISION_TYPE.REFLECT
		):
			return_value["direction"] = direction.bounce(result["normal"]).normalized()
			return_value["is_last"] = false

	else:
		return_value["vertex"] = target 
		
	return return_value

	
func on(point_to):
	self.clear_points()
	self.add_point(Vector2(0,0))
	var direction = (point_to - self.position).normalized()
	var next_reflect = _calculate_next_reflect(self.position, direction, 1000)
	var vertex = next_reflect["vertex"]

	while not next_reflect["is_last"]:
		direction = next_reflect["direction"]
		self.add_point(vertex - self.position)
		next_reflect = _calculate_next_reflect(vertex, direction, 500)
		vertex = next_reflect["vertex"]
		
	self.add_point(vertex - self.position)


func off():
	self.clear_points()
