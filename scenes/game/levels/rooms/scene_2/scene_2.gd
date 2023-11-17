extends Node2D

var player = []

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	
	if GameManager.level_start:
		GameManager.last_position = player.global_position
	player.global_position = GameManager.last_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
