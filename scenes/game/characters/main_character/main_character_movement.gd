extends Node2D
## Controlador de movimiento y animación de un personaje.
##
## Detecta eventos de teclado para poder mover un personaje por un escenario
## y ajustar animaciones según el movimiento
## Movimiento básica de personaje: https://docs.google.com/document/d/1c9XXznR1KBJSr0jrEWjYIqfFuNGCGP2YASkXsFgEayU/edit
class_name Player

@export var character: CharacterBody2D # Referencia al personaje a mover
@export var main_animation: AnimatedSprite2D # Referencia al sprite del personaje
@export var effect_animation_sword: AnimatedSprite2D # Referencia al sprite del personaje
@export var audio_player: AudioStreamPlayer2D # Reproductor de audios
@onready var _collision := $"../AreaSword/CollisionShape2D" # Colicionador de espada
@onready var main_animation_effects= $"../Effects" # Sprite effectos Player
@onready var weapon := $"../Weapon" # Scena del gancho

var gravity = 650 # Gravedad para el personaje
var velocity = 100 # Velocidad de movimiento en horizontal
var jump = 220 # Capacidad de salto, entre mayor el número más se puede saltar
# Mapa de movimientos del personaje
var _movements = {
	IDLE = "default",
	IDLE_WITH_SWORD = "idle_with_sword",
	LEFT_WITH_SWORD = "left_with_sword",
	RIGHT_WITH_SWORD = "run_with_sword",
	JUMP_WITH_SWORD = "jump_with_sword",
	FALL_WITH_SWORD = "fall_with_sword",
	HIT_WITH_SWORD = "hit_with_sword",
	DEAD_HIT = "dead_hit",
	ATTACK = "attack_2",
	BOMB = "attack_3",
	TELEPORT = "teleport",
	TELEPORT_EFFECT = "teleport_effect",
	FLY = "fly",
}
var _current_movement = _movements.IDLE # Variable de movimiento
var _is_jumping = false # Indicamos que el personaje está saltando
var _max_jumps = 2 # Máximo número de saltos
var _jump_count = 0 # Contador de saltos realizados
var _died = false # Define si esta vovo o muerto
var attacking = false # Define si esta atacando
var bombing = false # Define si esta atacando
var _is_playing: String = "" # Define si se esta reproducionedo el sonido
var turn_side: String = "right" # Define si se esta reproducionedo el sonido

# Precargamos los sonidos de saltar
var _jump_sound = preload("res://assets/sounds/jump.mp3")
var _run_sound = preload("res://assets/sounds/running.mp3")
var _dead_sound = preload("res://assets/sounds/dead.mp3")
var _male_hurt_sound = preload("res://assets/sounds/male_hurt.mp3")
var _hit_sound = preload("res://assets/sounds/slash.mp3")

#conseguir llaves del player
var playerKeys = [] # C0, C20, ...

# Teleport
var canTeleport = true
var _is_teleporting = false
@export var teleportSpeed = 100
var _teleport_sound = preload("res://assets/sounds/teleport.wav")

# Disparar cada 1s
var isShootBall: bool = false

# Player mueve hacia el gancho
var canPlayerMove: bool = false
var player_movement_speed: int = 100.0 

# Define una variable para controlar si la función player_to_ball está activa o no
var isPlayerToBallActive = false

# Función de inicialización
func _ready():
	main_animation.play(_current_movement)
	# Si no hay un personaje, deshabilitamos la función: _physics_process
	if not character:
		set_physics_process(false)

# Función de ejecución de físicas
func _physics_process(_delta):
	_move(_delta)

func _unhandled_input(event):
	# Cuando se presiona la tecla x, atacamos	
	if event.is_action_released("hit"):
		character.velocity.x = 0
		_current_movement = _movements.ATTACK
	# Cuando se presiona la tecla b, lanzamos bomba
	elif event.is_action_released("bomb"):
		_current_movement = _movements.BOMB
	_set_animation()

# Función de movimiento general del personaje
func _move(delta):
	# Cuando se presiona la tecla (flecha izquierda), movemos el personaje a la izquierda
	if Input.is_action_pressed("izquierda"):
		character.velocity.x = -velocity
		_current_movement = _movements.LEFT_WITH_SWORD	
		turn_side = "left"
		
		weapon.scale.x = -1
	# Cuando se presiona la tecla (flecha derecha), movemos el personaje a la derecha
	elif Input.is_action_pressed("derecha"):
		character.velocity.x = velocity
		_current_movement = _movements.RIGHT_WITH_SWORD
		turn_side = "right"
		
		weapon.scale.x = 1
	# Cuando no presionamos teclas, no hay movimiento	
	else:
		character.velocity.x = 0
		_current_movement = _movements.IDLE
	
	# Cuando se presiona la tecla (espacio), hacemos animación de salto
	if Input.is_action_just_pressed("saltar"):
		if character.is_on_floor():
			_current_movement = _movements.JUMP_WITH_SWORD
			_is_jumping = true
			_jump_count += 1 # Sumamos el primer salto
		elif _is_jumping and _jump_count < _max_jumps:
			_current_movement = _movements.JUMP_WITH_SWORD
			_jump_count += 1 # Sumamos el segundo salto
	
	# Cuando se presiona la tecla (f), hacemos animación de Dash
	if canTeleport and Input.is_action_just_pressed("teleport"):
		_current_movement = _movements.TELEPORT
		teleport()
	
	if Input.is_action_pressed("clic"):
		if !isShootBall:
			weapon.get_node("AnimatedSprite2D").play("pistola")
			shootBall()
			isShootBall = true
			await get_tree().create_timer(0.5).timeout
			isShootBall = false
	
	SkillPlayerToBall(character, delta)
	
	_apply_gravity(delta)
	
	if _died: # Si el personaje murió, no se podrá mover en el eje X
		character.velocity.x = 0
	
	_set_animation()
	# Función de godot para mover y aplicar física y colisiones
	character.move_and_slide()


# Controla la animación según el movimiento del personaje
func _set_animation():
	# Si esta atacando no interrumpimos la animació	
	if attacking or bombing:
		return
	# Personaje murio
	if _died:
		main_animation.play(_movements.DEAD_HIT)
		return
	if _is_jumping:	
		# Movimiento de salto (animación de "salto")
		if character.velocity.y >= 0:
			# Estamos cayendo
			main_animation.play(_movements.FALL_WITH_SWORD)
		else:
			# Estamos subiendo
			main_animation.play(_movements.JUMP_WITH_SWORD)
	elif _current_movement == _movements.ATTACK:
		# Atacamos
		attacking = true
		main_animation.play(_movements.ATTACK)
		weapon.get_node("AnimatedSprite2D").play("default")
		_play_sound(_hit_sound)
		# Agregamos el effecto especial
		_play_sword_effect()
	elif _current_movement == _movements.TELEPORT:
		main_animation.play(_movements.TELEPORT)
	elif _current_movement == _movements.BOMB:
		# Lanzamos bomba
		bombing = true
		main_animation.play(_movements.BOMB)
	elif _current_movement == _movements.RIGHT_WITH_SWORD:
		# Movimiento hacia la derecha (animación "correr" no volteada)
		main_animation.play(_movements.RIGHT_WITH_SWORD)
		main_animation.flip_h = false
		_collision.position.x = abs(_collision.position.x)
	elif _current_movement == _movements.LEFT_WITH_SWORD:
		# Movimiento hacia la izquierda (animación "correr" volteada)
		main_animation.play(_movements.RIGHT_WITH_SWORD)
		main_animation.flip_h = true
		_collision.position.x = - abs(_collision.position.x)
	elif _current_movement == _movements.FLY:
		main_animation.play(_movements.FLY)
	else:
		# Movimiento por defecto (animación de "reposo")
		main_animation.play(_movements.IDLE)
		# Pausamos el sonido
		audio_player.stop()
		_is_playing = ""

func teleport():
	_is_teleporting = true
	canTeleport = false
	# Reproducimos la animación del teleport
	do_animation()
	await get_tree().create_timer(1).timeout
	_is_teleporting = false
	await get_tree().create_timer(1.3).timeout
	canTeleport = true
	
func do_animation():
	_play_sound(_teleport_sound)
	main_animation_effects.play(_movements.TELEPORT_EFFECT)
	
# Función que aplica gravedad de caída o salto
func _apply_gravity(delta):
	var v = character.velocity
	
	# El salto solo se ejecuta 1 vez, en ese momento hacemos que el personaje salte
	if _current_movement == _movements.JUMP_WITH_SWORD and not _died:
		# Saltamos, solo si el personaje no ha muerto
		v.y = -jump
	# El salto solo se ejecuta 1 vez, en ese momento hacemos que el personaje salte
	elif _current_movement == _movements.TELEPORT and not _died:
		if (v.x < 0):
			v.x = -5 * teleportSpeed * gravity * delta
		else:
			v.x = 5 * teleportSpeed * gravity * delta
		v.y = -teleportSpeed
	else:
		# Aplicación de gravedad (aceleración en la caida)
		v.y += gravity * delta
		# Después de un salto, validamos cuando volvemos a tocar el suelo para poder volver a saltar
		if character.is_on_floor():
			# Reseteamos variables de salto
			_is_jumping = false
			_jump_count = 0
	
	# Aplicamos el vector de velocidad al personaje
	character.velocity = v

func die():
	# Seteamos la variable de morir averdadero
	_died = true
	GameManager.level_start = false

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
		# Animación de golpe


func _on_animation_animation_finished():
	# Validamos si la animación es de morir
	if main_animation.get_animation() == 'dead_hit':
		# Validamos si el sonido ya esta sonando
		if _is_playing != "_dead_sound":
			_is_playing = "_dead_sound"
			# Reproducimos el sonido
			_play_sound(_dead_sound)
	elif main_animation.get_animation() == _movements.ATTACK:
		attacking = false
	elif main_animation.get_animation() == _movements.BOMB:
		bombing = false


func _on_animation_frame_changed():	
	# Si la animación es de atacar habilitamos el colicionador
	if main_animation.animation == "attack_2" and main_animation.frame == 1:
		_collision.set_deferred("disabled", false)
	else:
		# Si la animación no es de atacar deshabilitamos el colicionador
		_collision.set_deferred("disabled", true)
		
	if main_animation.animation == _movements.JUMP_WITH_SWORD:
		# Validamos si el sonido ya esta sonando
		if _is_playing != "_jump_sound":
			_is_playing = "_jump_sound"
			# Reproducimos el sonido
			_play_sound(_jump_sound)
	if (
		main_animation.animation == _movements.RIGHT_WITH_SWORD 
		or main_animation.animation == _movements.LEFT_WITH_SWORD 
	):
		# Validamos si el sonido ya esta sonando
		if _is_playing != "_run_sound":
			_is_playing = "_run_sound"
			# Reproducimos el sonido
			_play_sound(_run_sound)


func _on_audio_stream_player_2d_finished():
	if audio_player.stream == _dead_sound:
		# Qitamos al personaje principal de la excena
		self.get_parent().queue_free()
		# Reiniciamos el juego despues de 2 segundos
		SceneTransition.reload_scene()
		
		
func _play_sound(sound):
	# Pausamos el sonido
	audio_player.stop()
	# Reproducimos el sonido
	audio_player.stream = sound
	audio_player.play()
	
func set_disabled(disabled: bool):
	set_physics_process(not disabled)
	
func set_idle():
	# Movimiento por defecto (animación de "reposo")
	main_animation.play(_movements.IDLE_WITH_SWORD)
	# Pausamos el sonido
	audio_player.stop()
	
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

func shootBall():
	var shoot_ball = weapon.ball.instantiate()
	if turn_side == "left":
		shoot_ball.scale = Vector2(-0.5, 0.5)
		shoot_ball.speed = -320
	else:
		shoot_ball.scale = Vector2(0.5, 0.5)
		shoot_ball.speed = 320
	shoot_ball.global_position = weapon.get_node("Direction").global_position
	get_tree().call_group("scene_0", "add_child", shoot_ball)

func player_to_ball(character, delta):
	var player_ball = get_parent().get_parent().get_node("Ball")
	if player_ball and canPlayerMove:
		var ultima_ball = get_tree().get_nodes_in_group("ballGroup").back()
		var target_position = ultima_ball.global_position
		var distance_threshold = 20

		var direction = (target_position - character.global_position).normalized()
		var move_amount = direction * player_movement_speed * delta
		
		if character.global_position.distance_to(target_position) > distance_threshold:
			character.global_position += move_amount
			# Desactivar la gravedad en el eje Y
			character.velocity.y = 0
			_current_movement = _movements.FLY
			weapon.get_node("AnimatedSprite2D").self_modulate = Color("#c5c5c500")
		else:
			canPlayerMove = false
			ultima_ball.is_ball_moving = true
			_current_movement = _movements.IDLE
			weapon.get_node("AnimatedSprite2D").self_modulate = Color("#ffffff")
			ultima_ball.queue_free()

func SkillPlayerToBall(character, delta):
	# Verifica si se presiona la tecla 'G'
	if Input.is_action_pressed("isGancho") && !_is_jumping:
		# Activa o desactiva la función player_to_ball
		isPlayerToBallActive = not isPlayerToBallActive
	# Ejecuta la función player_to_ball si la variable isPlayerToBallActive está en True
	if isPlayerToBallActive:
		player_to_ball(character, delta)
		HealthDashboard.label_SkillGancho.text = "[1]"
	else:
		HealthDashboard.label_SkillGancho.text = "[0]"
		weapon.get_node("AnimatedSprite2D").self_modulate = Color("#ffffff")
