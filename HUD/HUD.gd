extends CanvasLayer

var score = 0
var best_score = 0


func _on_GamePlay_on_rock_destroyed(new_score):
	self.score += new_score
	$ScoreLayout/Columns/Score.text = str(self.score)


func _on_GamePlay_on_game_over():
	
	if self.score > self.best_score:
		self.best_score = self.score
		$ScoreLayout/Columns/BestScore.text = str(self.score)
	self.score = 0
	$ScoreLayout/Columns/Score.text = str(self.score)
