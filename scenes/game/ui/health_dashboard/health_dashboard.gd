extends CanvasLayer

# Variable (públicas) de vida y puntuación
var life = 10 # Variable para menejo de vida
var exp = 0 # Variable para menejo de vida

var enemies = {
	CRABBY = "Crabby",
	SLIME = "Slime",
}

# Referencias hacia la barra de vida y los números de la puntuación
@onready var bar = $LifeBar/Bar

@onready var point_group = $PointGroup
@onready var enemy_group = $EnemyGroup
@onready var LabelCrabby = $EnemyGroup/Panel/Crabby/LabelCrabby
@onready var LabelKey = $EnemyGroup/Panel/Keys/LabelKey
@onready var LabelKey_white = $EnemyGroup/Panel/Keys_door_scene/LabelKey

@onready var expBar = $ExpBar/Bar
@onready var label_expBar = $ExpBar/LabelBar
@onready var textureReactSkill = $Skills/ContainerSkill/TextureReactSkill

# Función de inicialización
func _ready():
	self.visible = false

# Agrega vida del personaje principal, según el valor proporcionado
func add_life(value: int):
	life += value
	if life > 10:
		life = 10
	_set_life_progress(life)

# Agrega experiencia
func add_exp(value: int):
	exp += value
	
#	Subir de nivel
	if expBar.value >= expBar.max_value:
		expBar.max_value *= 2
	# Activar habilidades al subir ciertos niveles
	var global_dict = get_tree().get_nodes_in_group("player")[0].get_node("MainCharacterMovement").elemental_skills_enabled
	if (expBar.value <= 10):
		global_dict["flame"] = true
	elif (expBar.value <= 30):
		global_dict["water"] = true
	elif (expBar.value > 40):
		global_dict["darkness"] = true
	
	_set_exp_progress(exp)


# Quita vida del personaje principal, según el valor proporcionado
func remove_life(value: int):
	life -= value
	if life < 0:
		life = 0
	_set_life_progress(life)

# Función para resetear los valores de vida y puntos
func restart():
	life = 10
	exp = 0
	expBar.value = 0
	expBar.max_value = 10
	_set_life_progress(10)
	_set_exp_progress(0)

# Actualiza la barra de progreso de la vida
func _set_life_progress(value: int):
	bar.value = value

# Actualiza la barra de progreso de la experiencia 
func _set_exp_progress(value: int):
	expBar.value = value
	label_expBar.text = str(expBar.value) + " / " + str(expBar.max_value)

# Cambiar el Icon de la habilidad elemental actual en el marco
func update_element_icon(type: String, status: String ):
	var texture_to_set =  load("res://assets/sprites/Objects/elements/"+ status + "/" + type +".png")
	textureReactSkill.texture = texture_to_set
