extends Node2D

const PATH_LEVEL_1 = "res://scenes/game/levels/rooms/scene_0/scene_0.tscn"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_video_stream_player_finished():
	HealthDashboard.visible = true
	SceneTransition.change_scene(PATH_LEVEL_1)


func _on_button_pressed():
	HealthDashboard.visible = true
	SceneTransition.change_scene(PATH_LEVEL_1)
