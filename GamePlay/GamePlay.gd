extends CanvasLayer

signal on_rock_destroyed
signal on_game_over


# STATE MACHINE
enum STATE {
	START, 
	SHOOTING, 
	PLAYER_ROCK, 
	PLAYER_AIMING, 
	ROCK_IMPACT,
	MOUNTAIN_EXPLOSION,
	MOUNTAIN_ROCKFALL,
	END_GAME,
	RESTART
}

# CONSTANTS
const utils = preload("res://utils.gd")
const MOUNTAIN = "MOUNTAIN"

# VAR ROCK
var ball_path: String = "res://Ball/Ball.tscn"
var ball_scene: PackedScene = load(ball_path)

#VAR CANNON
var cannon_shooting_time: float = 1.0
var cannon_init_pos: Vector2 = Vector2(544, 288)

#VAR GAMEPLAY
var current_state: int 
var rock_rain:int = 55
var rocks: int = 0
var min_rocks: int = 15
var player_rock: Node2D
var rainbow_rays = 0
var player_shoots = 5


func _ready():
	randomize()
	$Cannon.init(ball_scene, cannon_shooting_time, cannon_init_pos)
	var _connection = $Cannon.connect("on_bullet_loaded", self, "_rock_added")
	$Laser.position = cannon_init_pos
	self.set_deferred("current_state", STATE.START)
	$EnvironmentMusic.play()

func _process(_delta):

	if self.current_state == STATE.PLAYER_AIMING:
		pass
		
	if self.current_state == STATE.END_GAME:
		pass
		
	elif self.current_state == STATE.SHOOTING:
		get_tree().call_group(MOUNTAIN, "wake_up")
		var mountain_rocks = get_tree().get_nodes_in_group(MOUNTAIN).size()
		
		if mountain_rocks == self.rocks:
			self.set_deferred("current_state", STATE.START)
	
	elif self.current_state == STATE.PLAYER_ROCK:
		self.player_shoots -= 1
		self.player_rock = $Cannon.reload()
		get_tree().call_group(MOUNTAIN, "sleep")
		self.set_deferred("current_state", STATE.PLAYER_AIMING)

	elif self.current_state == STATE.ROCK_IMPACT:
		self._evaluate_impact()

	elif self.current_state == STATE.MOUNTAIN_EXPLOSION:
		self.player_shoots += 1
		self.set_deferred("current_state", STATE.MOUNTAIN_ROCKFALL)
	
	elif self.current_state == STATE.MOUNTAIN_ROCKFALL:
		self._mountain_rockfall()

	elif self.current_state == STATE.START:
		
		if not $Rainbow.is_clear():
			self.set_deferred("current_state", STATE.END_GAME)
			emit_signal("on_game_over")
			$EnvironmentMusic.stop()
			
		elif self.rocks < self.min_rocks or self.player_shoots == 0:
			$Cannon.fire_automatic(rock_rain)
			self.player_shoots = 5
			self.rainbow_rays += 1
			self.set_deferred("current_state", STATE.SHOOTING)
		
		else:
			self.set_deferred("current_state", STATE.PLAYER_ROCK)
		
		$Rainbow.raise_rainbow(self.rainbow_rays)
	
	elif self.current_state == STATE.RESTART:
		get_tree().call_group(MOUNTAIN, "disable")
		get_tree().call_group(MOUNTAIN, "exploded")
		self.set_deferred("current_state", STATE.START)
		self.rainbow_rays = 0
		$EnvironmentMusic.play()
		
		
func _input(event):
	if (
		self.current_state == STATE.PLAYER_AIMING 
		and event is InputEventScreenTouch 
		and not event.pressed
	):
		var target = event.position
		var direction = (target - self.player_rock.position).normalized()
		self.player_rock.manual_direction = direction
		$Laser.off()
		self.set_deferred("current_state", STATE.SHOOTING)

	elif (
		self.current_state == STATE.PLAYER_AIMING 
		and (
			event is InputEventScreenDrag
			or (
				event is InputEventScreenTouch 
				and event.pressed
			)
		)
	):
		var target = event.position
		$Laser.on(target)

	elif (self.current_state == STATE.END_GAME 
		and event is InputEventScreenTouch 
	):
		self.set_deferred("current_state", STATE.RESTART)

func _rock_added(rock):
	self.rocks += 1
	rock.connect("on_ball_destroyed", self, "_rock_destroyed")
	rock.connect("on_ball_impacted", self, "_rock_impacted")
	rock.connect("on_ball_stopped", self, "_rock_to_montain")
	add_child(rock)


func _rock_to_montain(rock):
	rock.add_to_group(MOUNTAIN)


func _rock_destroyed(rock):
	self.rocks -= 1

	emit_signal("on_rock_destroyed", rock.score)

func _rock_impacted():
	self.set_deferred("current_state", STATE.ROCK_IMPACT)


func _is_same_color(slope, next_slope):
	return slope.get_self_modulate() == next_slope.get_self_modulate()


func _evaluate_impact():
	var criteria = funcref(self, "_is_same_color")
	
	var explosion_array = utils.recursive_colliding_bodies(
		self.player_rock,
		[self.player_rock],
		criteria
	)

	if explosion_array.size() > 2:
		self._rocks_explode(explosion_array)
		self.set_deferred("current_state", STATE.MOUNTAIN_EXPLOSION)
	else:
		self.player_rock.add_to_group(MOUNTAIN)
		self.set_deferred("current_state", STATE.SHOOTING)


func _rocks_explode(explosion_array):
	for rock in explosion_array:
		rock.score = 10
		if rock != self.player_rock:
			rock.remove_from_group(MOUNTAIN)
		rock.explode()
	$PlayerEnergy.play()


func _mountain_rockfall():
	var slopes = $MountainSlope.get_overlapping_bodies() 
	var new_mountain = []

	for slope in slopes:
		if not slope in new_mountain:
			new_mountain.append(slope)
			new_mountain = _climb_mountain(slope, new_mountain)

	var old_mountain = get_tree().get_nodes_in_group(MOUNTAIN)
	var shrapnel = utils.array_difference(old_mountain, new_mountain)

	for rock in shrapnel:
		rock.score = 50
		rock.disable()
		rock.remove_from_group(MOUNTAIN)

	self.set_deferred("current_state", STATE.SHOOTING)


func _is_sibiling(slope, next_slope):
	 return slope.get_filename() == next_slope.get_filename()


func _climb_mountain(slope, mountain):
	var colliding_criteria = funcref(self, "_is_sibiling")
	mountain = utils.recursive_colliding_bodies(slope, mountain, colliding_criteria)
	return mountain
