extends Area2D

func _on_Exit_body_entered(body):
	if body.name == "Player":
		Player.level = 1.2;