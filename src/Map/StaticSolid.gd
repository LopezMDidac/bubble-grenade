extends StaticBody2D

enum COLLISION_TYPE {STICKY, REFLECT}

export(COLLISION_TYPE) var collision_type = COLLISION_TYPE.REFLECT

func hit(volume):
	$Hit.volume_db = volume
	$Hit.play()
