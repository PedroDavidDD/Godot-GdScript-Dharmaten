extends Node2D
var player = []
var enemy = load("res://scenes/game/enemy/Slime/slime_green.tscn")
var wave = 1
var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	
	if GameManager.level_start:
		GameManager.last_position = player.global_position
	player.global_position = GameManager.last_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_spawn_timer_timeout():
	wave +=1
	var random_number = rng.randi_range(1,4)
	print (random_number)
	var inst=enemy.instantiate()
	
	if (random_number == 1):
		inst.position = $SpawnLocation1.position
	elif (random_number == 2):
		inst.position = $SpawnLocation2.position
	elif (random_number == 3):
		inst.position = $SpawnLocation3.position
	else:
		inst.position = $SpawnLocation4.position	
	
	add_child(inst)
	print(inst.position)
