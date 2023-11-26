extends Node2D

@onready var player = $".." # Referencia al personaje a mover
@onready var main_animation := $"../Animation" # Referencia al sprite del personaje
@export var effect_animation_sword: AnimatedSprite2D # Referencia al sprite del personaje
@onready var audio_player:= $"../AudioStreamPlayer2D" # Reproductor de audios
@onready var _collision := $"../AreaSword/CollisionShape2D" # Colicionador de espada
@onready var main_animation_effects= $"../Effects" # Sprite effectos Player
@onready var weapon := $"../Weapon" # Scena del gancho

@onready var MainCharacterBomb := $"../MainCharacterBomb"

@onready var containerMagic := $"../ContainerMagic"
@export var magicBullet = preload("res://scenes/game/objects/balls/ball.tscn")

var velocity = 100 # Velocidad de movimiento en horizontal
var fast_velocity = 150
# Mapa de movimientos del personaje
var _movements = {
	IDLE = "default",
	IDLE_WITH_SWORD = "idle_with_sword",
	RUN_WITH_SWORD = "run_with_sword",
	HIT_WITH_SWORD = "hit_with_sword",
	DEAD_HIT = "dead_hit",
	ATTACK = "attack_2",
	BOMB = "attack_3",
}
var _current_movement = _movements.IDLE # Variable de movimiento
var _died = false # Define si esta vovo o muerto
var attacking = false # Define si esta atacando
var bombing = false # Define si esta atacando
var _is_playing: String = "" # Define si se esta reproducionedo el sonido
var turn_side: String = "right" # Define si se esta reproducionedo el sonido

# Precargamos los sonidos de saltar
var _run_sound = preload("res://assets/sounds/running.mp3")
var _dead_sound = preload("res://assets/sounds/dead.mp3")
var _male_hurt_sound = preload("res://assets/sounds/male_hurt.mp3")
var _hit_sound = preload("res://assets/sounds/slash.mp3")

#conseguir llaves del player
var playerKeys = [] # C0, C20, ...

var direction = Vector2()
var bomb = preload("res://scenes/game/levels/objects/damage_object/bomb/bomb.tscn")  # Ruta al recurso de la bomba

# Keys
var btnUp = Input.is_action_pressed("arriba")
var btnDown = Input.is_action_pressed("abajo")
var btnLeft = Input.is_action_pressed("izquierda")
var btnRight = Input.is_action_pressed("derecha")

# Elementos 
var type_element = ["flame", "water", "darkness"]
var type_element_value = 0

func _process(_delta):
	_move(_delta)

func _move(delta):	
	direction = Vector2()
	
	# Keys
	btnUp = Input.is_action_pressed("arriba")
	btnDown = Input.is_action_pressed("abajo")
	btnLeft = Input.is_action_pressed("izquierda")
	btnRight = Input.is_action_pressed("derecha")
	
	direction = direction.normalized()
	
	# Movimiento del jugador
	if btnUp or btnDown or btnLeft or btnRight:
		if btnUp:
			direction.y -= 1
		elif btnDown:
			direction.y += 1
		
		if btnLeft:
			direction.x -= 1
			turn_side = "left"
		elif btnRight:
			direction.x += 1
			turn_side = "right"
		_current_movement = _movements.RUN_WITH_SWORD
	else:
		_current_movement = _movements.IDLE
	
	# Movimiento normal o rápido al presionar la tecla shif
	if Input.is_key_pressed(KEY_SHIFT):
		move_player(fast_velocity, delta)
	else:
		move_player(velocity, delta)
	
	# Cambiar estado: K
	if Input.is_action_just_pressed("change_element"):
		if type_element_value == (type_element.size() - 1):
			type_element_value = 0
		else:
			type_element_value += 1
		HealthDashboard.update_element_icon(type_element[type_element_value])
	
	# Cuando se presiona la tecla J, atacamos
	if Input.is_action_just_pressed("attack"):
		var nearest_slime_green = find_nearest_slime_green_player()
		if nearest_slime_green:
			create_magic_bullet(nearest_slime_green, type_element[type_element_value])
	
	# Cuando se presiona la tecla b, lanzamos bomba
	if Input.is_action_just_pressed("bomb"):
		throw_bomb()
		# _current_movement = _movements.BOMB
	
	_set_animation()

# Controla la animación según el movimiento del personaje
func _set_animation():
	# Si esta atacando no interrumpimos la animació	
	if attacking or bombing:
		return
	# Personaje murio
	if _died:
		main_animation.play(_movements.DEAD_HIT)
		return
	elif _current_movement == _movements.ATTACK:
		# Atacamos
		attacking = true
		main_animation.play(_movements.ATTACK)
		weapon.get_node("AnimatedSprite2D").play("default")
		_play_sound(_hit_sound)
		# Agregamos el effecto especial
		_play_sword_effect()
	elif _current_movement == _movements.BOMB:
		# Lanzamos bomba
		bombing = true
		main_animation.play(_movements.BOMB)
	elif _current_movement == _movements.RUN_WITH_SWORD:
		if btnRight:
			# Movimiento hacia la derecha (animación "correr" no volteada)
			main_animation.flip_h = false
		elif btnLeft:
			# Movimiento hacia la izquierda (animación "correr" volteada)
			main_animation.flip_h = true
		main_animation.play(_movements.RUN_WITH_SWORD)
	else:
		# Movimiento por defecto (animación de "reposo")
		main_animation.play(_movements.IDLE)
		# Pausamos el sonido
		audio_player.stop()
		_is_playing = ""

func _play_sword_effect():
	# Obtenems que efecto tenemos activo
	var type = Global.attack_effect
	if type == "blue_potion":
		# Aplicamos el efecto blue_potion
		effect_animation_sword.self_modulate = Color("#70a2ff")
	elif type == "green_bottle":
		# Aplicamos el efecto green_bottle
		effect_animation_sword.self_modulate = Color("#80b65a")
	else:
		# Aplicamos el efecto predefinido
		effect_animation_sword.self_modulate = Color("#ffffff")
	
	# Reproducimos el efecto de la espada
	effect_animation_sword.play("attack_2_effect")

func _play_sound(sound):
	# Pausamos el sonido
	audio_player.stop()
	# Reproducimos el sonido
	audio_player.stream = sound
	audio_player.play()

# Función para mover al jugador
func move_player(speed, delta):
	player.position += direction * speed * delta

	# Tirar bombas
func throw_bomb():
	MainCharacterBomb._getBomb()

# Recibir daño
func hit(value: int):
	if _died:
		return
	attacking = false
	HealthDashboard.remove_life(value)
	_play_sound(_male_hurt_sound)
	main_animation.play("hit_with_sword")
	
	# Bajamos vida y validamos si el personaje ha perdido
	if HealthDashboard.life == 0:
		die()
	else:
		pass

func die():
	# Seteamos la variable de morir averdadero
	_died = true

# Función para encontrar el slimeGreen más cercano al jugador
func find_nearest_slime_green_player():
	var player_position = player.global_position
	var slimes = get_tree().get_nodes_in_group("slimeGreen")
	var nearest_slime = null
	var nearest_distance = 1000000  # Valor grande que representa una distancia máxima razonable
	
	for slime in slimes:
		var slime_global_position = slime.global_position
		var distance_to_player = slime_global_position.distance_to(player_position)
		
		if distance_to_player < nearest_distance:
			nearest_distance = distance_to_player
			nearest_slime = slime
	
	return nearest_slime

func create_magic_bullet(enemy_player: CharacterBody2D, type_element: String):
	var magic_bullet = magicBullet.instantiate()
	var copy_enemy_player = enemy_player.global_position
	
	if player.scale.x < 0:
		magic_bullet.scale = Vector2(-0.1, 0.1)
		magic_bullet.speed_ball = -320
	else:
		magic_bullet.scale = Vector2(0.1, 0.1)
		magic_bullet.speed_ball = 320
	
	magic_bullet.enemy_player = enemy_player
	magic_bullet.copy_enemy_player = copy_enemy_player
	magic_bullet.type_element = type_element
	magic_bullet.global_position = containerMagic.get_node("ShootPointer").global_position
	get_tree().call_group("scene_0", "add_child", magic_bullet)

