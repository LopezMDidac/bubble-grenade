extends Node2D

signal on_bullet_loaded()

var bullet_scene: PackedScene
var shooting_time: float = 5.0
var initial_position: Vector2 = Vector2(544, 288)


func _ready():
	self.position = initial_position


func _shoot_automatic(bullet):
	var x = (randi() % 2000) - 1000
	var y = (randi() % 2000) - 1000
	bullet.init(bullet.SHIFT.AUTOMATIC, self.position, Vector2(x,y))


func _load_bullet():
	var bullet = self.bullet_scene.instance()
	emit_signal("on_bullet_loaded", bullet)
	return bullet


func init(bullet, shoot_time, init_pos):
	self.bullet_scene = bullet
	self.shooting_time = shoot_time
	self.position = init_pos


func fire_automatic(ammo):
	var fire_cadence: float = shooting_time / ammo

	for _bullet in range(0, ammo):
		var bullet = self._load_bullet()
		self._shoot_automatic(bullet)
		yield(get_tree().create_timer(fire_cadence), "timeout")


func reload():
	var bullet = self._load_bullet()
	bullet.init(bullet.SHIFT.MANUAL, initial_position)
	return bullet


