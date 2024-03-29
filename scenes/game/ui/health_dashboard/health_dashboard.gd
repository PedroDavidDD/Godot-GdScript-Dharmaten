extends CanvasLayer

# Variable (públicas) de vida y puntuación
var life = 10 # Variable para menejo de vida
var exp = 0 # Variable para menejo de vida

var enemies = {
	CRABBY = "Crabby",
	SLIME = "Slime",
}

# movil
signal enviar_joystick(j : Joystick)

@onready var label = $Label
@onready var joystick = $Joystick



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
@onready var textureReactSkillDisabled = $Skills/ContainerSkill/TextureRectDisabled

@onready var alert_level_up = $AlertLevelUP
@onready var timer_alert_level_up = $Timer
var isAlertLevelUP = false
var control_cron = load("res://scenes/game/ui/health_dashboard/cronometro.gd").new()

@export var incre_max_value = 20

# Función de inicialización
func _ready():
	# movil
	enviar_joystick.emit(joystick)
	
	self.visible = false
	expBar.max_value = incre_max_value

func _process(delta):
	# movil
	label.text = str(joystick.direccion)
	
	
	alert_level_up.visible = isAlertLevelUP
	
#	Activar habilidades al subir ciertos niveles
	check_skill_activation()
	check_cron_vis()

# Agrega vida del personaje principal, según el valor proporcionado
func add_life(value: int):
	life += value
	if life > 10:
		life = 10
	_set_life_progress(life)

# Agrega experiencia
func add_exp(value: int):
	exp += value
#	Subir de nivel cada que aumenta la exp
	check_level_up()

#	Subir de nivel cada que aumenta la exp
func check_level_up():
	var global_dict = get_tree().get_nodes_in_group("player")[0].get_node("MainCharacterMovement").elemental_skills_enabled
	if expBar.value >= expBar.max_value:
		expBar.max_value += incre_max_value
		
		if check_false_value_in_dict(global_dict):
			iniciarTimer_alert_level_up()
	_set_exp_progress(exp)

	# Devuelve true si 'false' está presente en los valores del diccionario de skills
func check_false_value_in_dict(dict):
	var values = dict.values()
	return values.has(false)

func iniciarTimer_alert_level_up(): 
	isAlertLevelUP = true
	timer_alert_level_up.start()

func check_skill_activation():
	var global_dict = get_tree().get_nodes_in_group("player")
	if global_dict:
		global_dict = global_dict[0].get_node("MainCharacterMovement").elemental_skills_enabled
		var level_thresholds = generate_level_thresholds(global_dict.size(), incre_max_value)
		for i in range(global_dict.size()):
			if expBar.value <= level_thresholds[i]:
				global_dict[global_dict.keys()[i]] = true
				return
			else:
				global_dict[global_dict.keys()[i]] = true

func generate_level_thresholds(size: int, exp_per_level: int) -> Array:
	var level_thresholds = [] # Niveles de experiencia para cada habilidad segun la cantidad de skills
	for i in range(size):
		level_thresholds.append(exp_per_level * (i + 1))
	return level_thresholds

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
	expBar.max_value = incre_max_value
	_set_life_progress(10)
	_set_exp_progress(0)
	reset_orbes_on_the_floor()

func reset_orbes_on_the_floor():
	var global_orbes = get_tree().get_nodes_in_group("group_orbe")
	if global_orbes:
		for i in global_orbes:
			i.queue_free()

# Actualiza la barra de progreso de la vida
func _set_life_progress(value: int):
	bar.value = value

# Actualiza la barra de progreso de la experiencia 
func _set_exp_progress(value: int):
	expBar.value = value
	label_expBar.text = str(expBar.value) + " / " + str(expBar.max_value)

# Cambiar el Icon de la habilidad elemental actual en el marco
func update_element_icon(type: String, status: String ):
	if status == "disabled":
		textureReactSkillDisabled.visible = true
	else:
		textureReactSkillDisabled.visible = false
	
	var texture_to_set =  load("res://assets/sprites/Objects/elements/enabled/" + type +".png")
	textureReactSkill.texture = texture_to_set
	if type == "lightning":
		$Skills/ContainerSkill/Sprite2D.self_modulate = Color("#ffffff")
		$LabelCarga.visible = true
	else:
		$Skills/ContainerSkill/Sprite2D.self_modulate = Color("#ffffff")
		$LabelCarga.visible = false

func check_cron_vis():
	var check = get_tree().get_nodes_in_group("menu")
	check = check[0].cron_vis
	if check == true:
		$cronometro.visible = true
		$EnemyGroup.visible = false
	else:
		$cronometro.visible = false
		$EnemyGroup.visible = true

func _on_timer_timeout():
	isAlertLevelUP = false
	
func stop_timer():
	control_cron.stop()



