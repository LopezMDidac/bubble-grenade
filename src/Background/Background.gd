extends CanvasLayer

enum STATE_LIGHTS {FIRST_NIGHT, END_NIGHT, FIRST_DAY, END_DAY}

var light_path = 0.0
var path = 0.0
var current_light = STATE_LIGHTS.FIRST_NIGHT
var light_points = {
	STATE_LIGHTS.FIRST_NIGHT: Vector3(145,145,145),
	STATE_LIGHTS.END_NIGHT: Vector3(30,30,30),
	STATE_LIGHTS.FIRST_DAY: Vector3(230,230,200),
	STATE_LIGHTS.END_DAY: Vector3(0,0,0)
}


func _on_GamePlay_on_rock_destroyed(score):
	#$Skywalker/Moon.unit_offset += 0.00001 * score
	var increment = 0.0002 * score
	
	self.path +=  increment
	$Skywalker/Moon.unit_offset = self.path
	
	if self.path > 1.0:
		self.path = 0.0

	self.light_path += increment

	var light_direction = get_light_direction()
	var previous_light = posmod((self.current_light - 1), STATE_LIGHTS.size())
	
	var light_color = self.light_points[previous_light] +  self.light_path * light_direction
	if light_path > 0.5:
		self.light_path = 0.0
		self.current_light = posmod((self.current_light + 1), STATE_LIGHTS.size())
	
	$AmbientLight.color = Color8(light_color.x, light_color.y, light_color.z)
	
func get_light_direction():
	var previous_point =  light_points[posmod((self.current_light - 1), STATE_LIGHTS.size())]
	
	return light_points[self.current_light] - previous_point
	
