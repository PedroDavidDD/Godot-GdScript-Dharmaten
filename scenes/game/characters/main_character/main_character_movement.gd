extends Node2D

@onready var player = $".." # Referencia al personaje a mover
@onready var main_animation := $"../Animation" # Referencia al sprite del personaje
@onready var audio_player:= $"../AudioStreamPlayer2D" # Reproductor de audios
@onready var main_animation_effects= $"../Effects" # Sprite effectos Player

@onready var containerMagic := $"../ContainerMagic"
@export var magicBullet = preload("res://scenes/game/objects/balls/ball.tscn")
# movil
var joystick : Joystick
var direccion = Vector2()

var collision: KinematicCollision2D
var velocity = 100 # Velocidad de movimiento en horizontal
var fast_velocity = 150
var can_shoot = true
var stop_cronometer = false
var cron_reset= false
var check 

var resume_cron = load("res://scenes/game/ui/health_dashboard/cronometro.gd").new()
# Mapa de movimientos del personaje
var _movements = {
	IDLE = "default",
	FLY = "run",
	HIT = "hit",
	DEAD_HIT = "dead_hit",
	ATTACK = "attack_2",
}
var _current_movement = _movements.IDLE # Variable de movimiento
var _died = false # Define si esta vovo o muerto
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

# Keys
var btnUp = Input.is_action_pressed("arriba")
var btnDown = Input.is_action_pressed("abajo")
var btnLeft = Input.is_action_pressed("izquierda")
var btnRight = Input.is_action_pressed("derecha")
var btnfast = Input.is_action_pressed("fast")

# Variables sobre las habilidades elementales
var elemental_skills_enabled = {
	"water": true,
	"flame": false,
	"darkness": false,
	"flame_water": false,
	"lightning": false,
}
var type_element_value = 0
var selected_elemental_skill_key = elemental_skills_enabled.keys()[type_element_value]
var status_icon = "disabled"

# Cooldown del disparo
var nextBulletTime:float;
@export var cooldownBullet:float = 0.5;
# Cooldown del ataque2
var nextChargedTime:float;
@export var cooldownCharged:float = 3;

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
	btnfast = Input.is_action_pressed("fast")
	
	# movil
	if joystick != null and is_instance_valid(joystick):
		direccion = joystick.direccion
	else:
		direction = direction.normalized()
	# direction = direction.normalized()
	
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
		_current_movement = _movements.FLY
	else:
		_current_movement = _movements.IDLE
	
	# Correr rápido al presionar la tecla Shift
	if Input.is_action_pressed("fast"):
		velocity = fast_velocity  
	
	
	# Cuando se presiona la tecla K, cambiamos de habilidad
	if (elemental_skills_enabled[selected_elemental_skill_key]):
		status_icon = "enabled"
	else:
		status_icon = "disabled"
	HealthDashboard.update_element_icon( selected_elemental_skill_key, status_icon )
	
	# Seleccionar habilidad
	if Input.is_action_just_pressed("change_element"):
		cycle_element_value()
	
	if elemental_skills_enabled[selected_elemental_skill_key] && selected_elemental_skill_key == "lightning":
		# Cuando se presiona la tecla J, atacamos			
		if (nextChargedTime <= 0):
			if Input.is_action_pressed("attack"):
				lightning()
				nextChargedTime = cooldownCharged;
		else:
			nextChargedTime -= delta
	else:
		if (nextBulletTime <= 0):
			if Input.is_action_pressed("attack"):
				use_elemental_skill()
				nextBulletTime = cooldownBullet;
				can_shoot=false
		else:
			nextBulletTime -= delta
	
	
	_set_animation()
	# Activar colisiones y movimiento: move_and_collide
	collision = player.move_and_collide(direction * velocity * delta)

func lightning():
	if elemental_skills_enabled[selected_elemental_skill_key]:
		if selected_elemental_skill_key == "lightning":
			_current_movement = _movements.ATTACK
			$"../Lightning".visible = true 
			for i in range(4):
				var nombre_nodo = "Effects" + str(i)
				var nodo_hijo = get_node("../Lightning/" + nombre_nodo)
				if nodo_hijo:
					nodo_hijo.play("lightning")

func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy"):
		body.hit(5)
		body.queue_free()

func _on_effects_frame_changed():
	$"../Lightning/Area2D/CS_1".disabled  = false

func _on_effects_animation_finished():
	$"../Lightning/Area2D/CS_1".disabled  = true
	$"../Lightning".visible = false 

func use_elemental_skill():
	var nearest_slime_green = find_nearest_slime_green_player()
	if nearest_slime_green && (elemental_skills_enabled[selected_elemental_skill_key]):
		if selected_elemental_skill_key == "lightning":
			return
		create_magic_bullet(nearest_slime_green, selected_elemental_skill_key)			
		_current_movement = _movements.ATTACK
		if selected_elemental_skill_key == "water":
			var player_position = player.global_position
			var ball_behind = player_position
			create_magic_bullet_at_position(ball_behind, selected_elemental_skill_key)
#	else: 
#		print("necesitas desbloquear la habilidad: "+str(selected_elemental_skill_key))

func cycle_element_value():
	if type_element_value == (elemental_skills_enabled.size() - 1):
		type_element_value = 0
	else:
		type_element_value += 1
	selected_elemental_skill_key = elemental_skills_enabled.keys()[type_element_value]

# Controla la animación según el movimiento del personaje
func _set_animation():
	# Personaje murio: Reiniciar escena actual
	if _died:
		main_animation.play(_movements.DEAD_HIT)
		check = get_tree().get_nodes_in_group("menu")
		check = check[0].survival 
		if check:
			await get_tree().create_timer(3).timeout
		HealthDashboard.restart()
#		get_tree().change_scene_to_file("res://scenes/game/levels/rooms/scene_0/scene_0.tscn")
		get_tree().reload_current_scene()
		return
	elif _current_movement == _movements.ATTACK:
		# Atacamos
		main_animation.play(_movements.ATTACK)
		
		play_type_bullet_sound()
		
		_play_sound(_hit_sound)
		
	elif _current_movement == _movements.FLY:
		if btnRight:
			# Movimiento hacia la derecha (animación "correr" no volteada)
			main_animation.flip_h = false
		elif btnLeft:
			# Movimiento hacia la izquierda (animación "correr" volteada)
			main_animation.flip_h = true
		main_animation.play(_movements.FLY)
	else:
		# Movimiento por defecto (animación de "reposo")
		main_animation.play(_movements.IDLE)
		# Pausamos el sonido
		audio_player.stop()
		_is_playing = ""

func play_type_bullet_sound(): 
	if (elemental_skills_enabled[selected_elemental_skill_key]):
		_hit_sound = ResourceLoader.load("res://assets/sounds/"+ selected_elemental_skill_key +".mp3")
	else:
		_hit_sound = preload("res://assets/sounds/lock.mp3")

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
	HealthDashboard.remove_life(value)
	_play_sound(_male_hurt_sound)
	
	# Bajamos vida y validamos si el personaje ha perdido
	if HealthDashboard.life == 0:
		stop_cronometer = true
		die()
		await get_tree().create_timer(3).timeout
		stop_cronometer = false
		cron_reset = true
		
	else:
		pass

func die():
	# Seteamos la variable de morir a verdadero
	_died = true

# Función para encontrar el slimeGreen más cercano al player
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

func _on_animation_frame_changed():
	pass


func _on_timer_timeout():
	can_shoot=true

# movil
func recibir_joystick(j : Joystick):
	joystick = j


