extends RigidBody2D

signal on_ball_destroyed
signal on_ball_impacted
signal on_ball_stopped

enum  SHIFT {MANUAL, AUTOMATIC}
enum STATE {SLEEP, WAKE_UP, PHYSICS_CALCULATING, PHYSICS_CALCULATED, EXPLODING, EXPLODED}

var score = 0
var current_state = STATE.WAKE_UP
var manual_direction: Vector2 = Vector2()
var _speed = 1000
var _physics_idle_cycles:int = 0
var _exploding_time = 0.75


func _physics_process(delta):	
	
	if self.mode == self.MODE_KINEMATIC and self.current_state == STATE.WAKE_UP:
		var motion = Vector2()
		if self.manual_direction != Vector2():
			motion += _manual_movement(delta)
		self.position += motion
	
	elif self.current_state == STATE.PHYSICS_CALCULATING:
		set_deferred("current_state", STATE.PHYSICS_CALCULATED)
		
	elif self.current_state == STATE.PHYSICS_CALCULATED:		
		self.set_deferred("current_state", STATE.WAKE_UP)
		emit_signal("on_ball_impacted")
		
		
	elif self.current_state == STATE.EXPLODING:
		if self._exploding_time < 0:
			self.set_deferred("current_state", STATE.EXPLODED)
		else:
			self._exploding_time -= delta
	
	elif self.current_state == STATE.EXPLODED:
		self.exploded()
		self.set_deferred("current_state", STATE.SLEEP)

func _on_Ball_sleeping_state_changed():
	if self.mode == self.MODE_RIGID and self.is_sleeping():
		set_deferred("mode", self.MODE_KINEMATIC)
		self.current_state = STATE.SLEEP
		emit_signal("on_ball_stopped", self)


func _manual_movement(delta):
	var motion = self.manual_direction * self._speed * delta
	var result = Physics2DTestMotionResult.new()

	if test_motion(motion, true, 0.2, result):
		var collider = result.collider
		motion = result.get_motion()
		motion += 0.2 * motion.normalized()

		if (
			collider.get("collision_type") 
			and collider.get("collision_type")  == collider.COLLISION_TYPE.REFLECT
		):
			var reflect = motion.bounce(result.get_collision_normal())
			self.manual_direction = reflect.normalized() 

		else:
			$Impact.emitting = true
			self.manual_direction = Vector2()
			self.set_deferred("current_state", STATE.PHYSICS_CALCULATING)

	return motion


func _notify_impact():
	emit_signal("on_ball_impacted")


func _on_Visibility_screen_exited():
	self.queue_free()
	self.emit_signal("on_ball_destroyed", self)


func init(
		shift: int = SHIFT.MANUAL,
		pos: Vector2 = self.position,
		velocity : Vector2 = Vector2()
	):

	if shift == SHIFT.MANUAL:
		self.mode = self.MODE_KINEMATIC

	else:
		self.mode = self.MODE_RIGID

	self.mode = mode
	self.position = pos
	self.linear_velocity = velocity


func wake_up():
	self.set_deferred("current_state", STATE.WAKE_UP)


func sleep():
	self.set_deferred("current_state", STATE.SLEEP)

func exploded():
	self.set_color("#000000")
	var x = (randi() % 2000) - 1000
	var y = (randi() % 500) - 1000
	self.linear_velocity = Vector2(x, y)
	$Explosion_sound.play()

func explode():
	self.disable()
	self.set_deferred("current_state", STATE.EXPLODING)
	$Explosion.emitting = true
	# $Explosion.set_modulate("#ffffff")


func disable():
	self.set_deferred("collision_mask", 0)
	self.set_deferred("collision_layer", 0)
	self.set_deferred("mode", self.MODE_RIGID)
	

func set_color(color):
	self.set_self_modulate(color)
	$BallTexture.set_self_modulate(color)


func _on_Ball_body_entered(body):
	if body.has_method("hit"):
		var volume = 0
		
		if self.mode == MODE_RIGID:
			volume = -40
			
		body.hit(volume)

func hit(volume):
	$Hit.volume_db = volume
	$Hit.play()
