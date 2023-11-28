extends Node2D
var player = []
var enemy = load("res://scenes/game/enemy/Slime/slime_green.tscn")
var wave = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	
	if GameManager.level_start:
		GameManager.last_position = player.global_position
	player.global_position = GameManager.last_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var inst=enemy.instantiate()
	
	if (get_tree().get_nodes_in_group("enemy").size() == 0 and wave <=15):
			wave +=1
			add_child(inst)
			inst.position = Vector2(0,0)
			print(wave)
