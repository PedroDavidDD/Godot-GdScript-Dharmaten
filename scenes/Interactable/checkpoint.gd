extends Node2D
class_name Checkpoint

@export var spawnpoint = false

func activate():
	GameManager.last_position = global_position
	print("checkpoint: "+ str(GameManager.last_position))
	$AnimationPlayer.play("Activated")

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		activate()


