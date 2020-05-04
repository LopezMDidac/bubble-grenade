# Bubble Grenade

This repository is a playground to experiment with different features of Godot engine v3.2.1.

## The game

Gameplay is a review of classic bubble gun game. In this case the balls are throw from top to down (like a grenade) and explodes the montain of same color.

Ball color is get from a colorfull bar at the top of the screen. Player should consider not only the impact point but also the color area trajectory.

Gameplay starts directly once the player enter the game. 

### Components

#### Game 

`Game.tscn` is the main node for the game.
It is a container for different layers that compose the game: [BackgroundLayer](####BackgroundLayer), [GamePlayLayer](####GamePlayLayer) and [HUDLayer](####hudlayer).

- Type: [Node2D](https://docs.godotengine.org/en/3.2/classes/class_node2d.html)


#### BackgroundLayer [CanvasLayer]

 - type: [CanvasLayer](https://docs.godotengine.org/en/3.2/classes/class_canvaslayer.html)


#### GamePlayLayer [CanvasLayer]

 - type: [CanvasLayer](https://docs.godotengine.org/en/3.2/classes/class_canvaslayer.html)


#### HUDlayer 



`src/HUDlayer/HUDLayer.tscn` is the node that handles user data.

 - type: [CanvasLayer](https://docs.godotengine.org/en/3.2/classes/class_canvaslayer.html)


## Backlog

## Author

lopezm.didac@gmail.com




------------------------------------------
Backlog
kljkjl
yvujvuk
gbiuolb




------------------------------------------
	Code Refactor

- Documentation
- Review style code
- Autoload config
- _process function and machine
- Move code to mountain
- explosion to scene
- Sound manager o algo refactor
- Unit test



	Features
- End Game
	- message
	- sound
		- new best score
		- no new best score

- Best score persistance

- Background
- map review
- Colors review
- ligths
- SplashScreen
- Menu
	* Letter
	* Sound
	* Music


- [BUG] cannon is not firing at restart
- [BUG] explosion canon is saturing
- [BUG] angle of laser, get entire ball not only center
- [BUG] make colision for almost contact balls 
- [BUG] Hay algo raro a la hora de pillar el color en borde entre dos

- [IMPROVEMENT] Environment music
	* Look for different tracks
	* Look for multipista
- [IMPROVEMENT] Start/Go message when player start to aim
- [IMPROVEMENT] Cambiar la caratula por una mas luminosa que haga match con la foto
- [IMPROVEMENT] Score, best score text + colocación
- [FEATURE] Ball Material (conccept)
	* Bubble sound (water)
	* BubbleFX
 


	Future features
- Powers
	* HearthQuake
	* RerollRainbow
	* MulticolorBall

- Levels
	* Different maps
	* World menu



	



