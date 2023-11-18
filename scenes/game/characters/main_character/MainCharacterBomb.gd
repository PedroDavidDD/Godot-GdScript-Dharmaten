extends Node2D
## Controlador de lanzamiento de bombas.
##
## Escucha la tecla de tirar bombas y tira la bomba


# Precargamos la escena de la bomba
var _bomb = preload("res://scenes/game/levels/objects/damage_object/bomb/bomb.tscn")
# El script de movimiento
var _move_script: Node2D


func _ready():
	HealthDashboard.add_bomb(2)
	_move_script = get_parent().get_node("MainCharacterMovement")

# Called when the node enters the scene tree for the first time.
func _getBomb(bomb_scene, _character_position):
	# Validamos cuantas bombas tenemos
	var _count_bomb = HealthDashboard.points["Bomb"]
	# Cuando se presiona la tecla (B - bomb) y no tiramos la bomba antes
	if not _move_script.bombing and _count_bomb > 0:
		# Quitamos la bomba del invetario
		HealthDashboard.add_bomb(-1)
		# Seteamos la dirección de la fuerza y offset
		if _move_script.turn_side == "right":
			bomb_scene.linear_velocity.x = abs(bomb_scene.linear_velocity.x)
			bomb_scene.linear_velocity.y = abs(bomb_scene.linear_velocity.y) - 5
			bomb_scene.position.x = _character_position.x + 25
		else:
			bomb_scene.linear_velocity.x = - abs(bomb_scene.linear_velocity.x)
			bomb_scene.linear_velocity.y = abs(bomb_scene.linear_velocity.y) - 5
			bomb_scene.position.x = _character_position.x - 25
