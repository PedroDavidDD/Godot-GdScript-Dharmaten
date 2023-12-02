extends Node2D

@onready var player = $".." # Referencia al personaje a mover
@onready var main_animation := $"../Animation" # Referencia al sprite del personaje
@onready var audio_player:= $"../AudioStreamPlayer2D" # Reproductor de audios
@onready var main_animation_effects= $"../Effects" # Sprite effectos Player

@onready var containerMagic := $"../ContainerMagic"
@export var magicBullet = preload("res://scenes/game/objects/balls/ball.tscn")

var collision: KinematicCollision2D
var velocity = 100 # Velocidad de movimiento en horizontal
var fast_velocity = 150
var can_shoot = true
# Mapa de movimientos del personaje
var _movements = {
	IDLE = "default",
	RUN = "run",
	HIT = "hit",
	DEAD_HIT = "dead_hit",
	ATTACK = "attack_2",
}
var _current_movement = _movements.IDLE # Variable de movimiento
var _died = false # Define si esta vovo o muerto
var attacking = false # Define si esta atacando
var _is_playing: String = "" # Define si se esta reproducionedo el sonido
var turn_side: String = "right" # Define si se esta reproducionedo el sonido
var can_shoot = true #Define si puede disparar

# Precargamos los sonidos de saltar
var _run_sound = preload("res://assets/sounds/running.mp3")
var _dead_sound = preload("res://assets/sounds/dead.mp3")
var _male_hurt_sound = preload("res://assets/sounds/male_hurt.mp3")
var _hit_sound = preload("res://assets/sounds/slash.mp3")

#conseguir llaves del player
var playerKeys = [] # C0, C20, ...

var direction = Vector2()

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
	velocity = 100
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
		_current_movement = _movements.RUN
	else:
		_current_movement = _movements.IDLE
	
	# Movimiento normal o rápido al presionar la tecla shif
	if Input.is_key_pressed(KEY_SHIFT):
		velocity = fast_velocity  
	
	# Cambiar estado: K
	if Input.is_action_just_pressed("change_element"):
<<<<<<< Updated upstream
		if type_element_value == (type_element.size() - 1):
			type_element_value = 0
		else:
			type_element_value += 1
		HealthDashboard.update_element_icon(type_element[type_element_value])
=======
		cycle_element_value()
		
	# Cuando se presiona la tecla J, atacamos
	if (nextBulletTime <= 0):
		if Input.is_action_pressed("attack"):
			use_elemental_skill()
			_current_movement = _movements.ATTACK
			nextBulletTime = cooldownBullet;
			can_shoot=false	
	else:
		nextBulletTime -= delta
>>>>>>> Stashed changes
	
	# Cuando se presiona la tecla J, atacamos
<<<<<<< Updated upstream
	if Input.is_action_just_pressed("attack"):
		var nearest_slime_green = find_nearest_slime_green_player()
		if nearest_slime_green:
			create_magic_bullet(nearest_slime_green, type_element[type_element_value])
=======
	if Input.is_action_pressed("attack") and can_shoot:
		use_elemental_skill()
		
	
	selected_elemental_skill_key_status = selected_elemental_skill_key+"_"+ status_icon
>>>>>>> Stashed changes
	
	_set_animation()
	# Activar colisiones y movimiento: move_and_collide
	collision = player.move_and_collide(direction * velocity * delta)
<<<<<<< Updated upstream
=======
	
	
func use_elemental_skill():
	var nearest_slime_green = find_nearest_slime_green_player()
	if nearest_slime_green && (elemental_skills_enabled[selected_elemental_skill_key]):
<<<<<<< Updated upstream
		create_magic_bullet(nearest_slime_green, selected_elemental_skill_key_status)
		if selected_elemental_skill_key_status == "water_enabled":
			var player_position = player.global_position
			var ball_behind = player_position #modificar aquí
			create_magic_bullet_at_position(ball_behind, selected_elemental_skill_key_status)
	can_shoot=false	
#	else: 
#		print("necesitas desbloquear la habilidad: "+str(selected_elemental_skill_key))
=======
		create_magic_bullet(nearest_slime_green, selected_elemental_skill_key)
		if selected_elemental_skill_key == "water":
			var player_position = player.global_position
			var ball_behind = player_position
			create_magic_bullet_at_position(ball_behind, selected_elemental_skill_key)
		if selected_elemental_skill_key == "flame_water":
			var player_position = player.global_position
			var ball_behind = player_position + Vector2(10,0)
			create_magic_bullet_at_position(ball_behind, selected_elemental_skill_key)
		print(str(selected_elemental_skill_key))
>>>>>>> Stashed changes

func cycle_element_value():
	if type_element_value == (elemental_skills_enabled.size() - 1):
		type_element_value = 0
	else:
		type_element_value += 1
	selected_elemental_skill_key = elemental_skills_enabled.keys()[type_element_value]
>>>>>>> Stashed changes

# Controla la animación según el movimiento del personaje
func _set_animation():
	# Si esta atacando no interrumpimos la animació	
	if attacking:
		return
	# Personaje murio
	if _died:
		main_animation.play(_movements.DEAD_HIT)
		return
	elif _current_movement == _movements.ATTACK:
		# Atacamos
		attacking = true
		main_animation.play(_movements.ATTACK)
		#weapon.get_node("AnimatedSprite2D").play("default")
		_play_sound(_hit_sound)
	elif _current_movement == _movements.RUN:
		if btnRight:
			# Movimiento hacia la derecha (animación "correr" no volteada)
			main_animation.flip_h = false
		elif btnLeft:
			# Movimiento hacia la izquierda (animación "correr" volteada)
			main_animation.flip_h = true
		main_animation.play(_movements.RUN)
	else:
		# Movimiento por defecto (animación de "reposo")
		main_animation.play(_movements.IDLE)
		# Pausamos el sonido
		audio_player.stop()
		_is_playing = ""

func _play_sound(sound):
	# Pausamos el sonido
	audio_player.stop()
	# Reproducimos el sonido
	audio_player.stream = sound
	audio_player.play()


# Recibir daño
func hit(value: int):
	if _died:
		return
	attacking = false
	HealthDashboard.remove_life(value)
	_play_sound(_male_hurt_sound)
	#main_animation.play("HIT")
	
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
	
func create_magic_bullet_at_position(position: Vector2, type_element:String):
<<<<<<< Updated upstream
	var magic_bullet = magicBullet.instantiate()
	if player.scale.x < 0:
		magic_bullet.scale = Vector2(-0.05, 0.05)
	else:
		magic_bullet.scale = Vector2(0.05, 0.05)
	magic_bullet.type_element = type_element
	magic_bullet.global_position = position
	get_tree().call_group("scene_0", "add_child", magic_bullet)	

func _on_animation_frame_changed():
	pass


func _on_bullet_time_timeout():
=======
	#Rastro bala agua
	if selected_elemental_skill_key == "water":
		var magic_bullet = magicBullet.instantiate()
		if player.scale.x < 0:
			magic_bullet.scale = Vector2(-0.05, 0.05)
		else:
			magic_bullet.scale = Vector2(0.05, 0.05)
		magic_bullet.type_element = type_element
		magic_bullet.global_position = position
		get_tree().call_group("scene_0", "add_child", magic_bullet)	
	#Bala doble fuegoagua
	"""if selected_elemental_skill_key == "flame_water":
		var magic_bullet = magicBullet.instantiate()
		if player.scale.x < 0:
			magic_bullet.scale = Vector2(-0.1, 0.1)
			magic_bullet.speed_ball = 320
		else:
			magic_bullet.scale = Vector2(0.1, 0.1)
			magic_bullet.speed_ball = -320
		magic_bullet.type_element = type_element
		magic_bullet.global_position = position
		get_tree().call_group("scene_0", "add_child", magic_bullet)"""
		
		

func _on_animation_frame_changed():
	pass
	



func _on_timer_timeout():
>>>>>>> Stashed changes
	can_shoot = true # Replace with function body.
