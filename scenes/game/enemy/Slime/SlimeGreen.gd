extends CharacterBody2D

# Variables de animación de la poción y audio
@export var character: CharacterBody2D # Referencia al personaje a mover
@export var main_animation: AnimatedSprite2D # Referencia al sprite del personaje

@onready var _animation := $EnemyAnimation
@onready var _raycast_terrain := $Area2D/RayCastTerrain

var animation = {
	IDLE = "idle",
	RUN = "run",
	JUMP = "jump",
	FALL = "fall",
}

# Acciones del Enemigo
@export_enum(
	"idle",
	"run",
	"jump",
	"fall",
) var _current_movement: String

# Dirección de movimiento del Enemigo
@export_enum(
	"left",
	"right",
	"active",
) var moving_direction: String

# Definición de parametros de física
var _gravity = 650 # Gravedad para el personaje
# Definición de dirección de movimientos
var _moving_left = true
# La muerte del slime
var _died = false # Define si esta vovo o muerto

var jump = 220 # Capacidad de salto, entre mayor el número más se puede saltar
var _is_jumping = false # Indicamos que el personaje está saltando
var _jump_count = 0 # Contador de saltos realizados

func _ready():
	if not _current_movement:
		_current_movement = animation.JUMP
	# Si no hay un personaje, deshabilitamos la función: _physics_process
	if not character:
		set_physics_process(false)
	# animacion
	_init_state()

func _init_state():
	# Animación de estado inicial
	velocity.x = 0
	_animation.play(_current_movement)

# _animation.play(animation.RUN)
func _process(delta):
	if (_died): 
		velocity.x = 0
		return
	# Si la animación es de correr, aplicamos el movimiento
	if _current_movement == animation.RUN:
		print("_move_character(delta)")
		# _turn()
	# Si la animación es de idle, aplicamos el movimiento
	elif _current_movement == animation.IDLE:
		_move_idle()
	# Jump
	elif _current_movement == animation.JUMP:
		_jumpSlime()
	
	# Iniciamos el movimiento
	move_and_slide()
	
	_apply_gravity(delta)
	

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		print(body.name, " slime: body")

		var player = body
		var player_script = player.get_node("MainCharacterMovement")
		var jumpBefore = player_script.jump

		if player_script:			
			player_script.hit(1)
			player_script.jump = jumpBefore + 100
			await get_tree().create_timer(2).timeout
			player_script.jump = jumpBefore 
		else:
			print("Player: null")
		# HealthDashboard.add_life(5)
		self.queue_free()  # Liberamos la memoria

func _jumpSlime():
	if not _raycast_terrain.is_colliding():
		_is_jumping = true
	await get_tree().create_timer(0.2).timeout
	_current_movement = animation.FALL
	_animation.play(_current_movement)
	

# Función que aplica gravedad de caída o salto
func _apply_gravity(delta):
	var v = velocity
	
	# El salto solo se ejecuta 1 vez, en ese momento hacemos que el personaje salte
	if _current_movement == animation.JUMP and not _died:
		# Saltamos, solo si el personaje no ha muerto
		v.y = -jump
	else:
		# Aplicación de gravedad (aceleración en la caida)
		v.y += _gravity * delta
		# Después de un salto, validamos cuando volvemos a tocar el suelo para poder volver a saltar
		if _raycast_terrain.is_colliding():
			# Reseteamos variables de salto
			_is_jumping = false
			_current_movement = animation.IDLE
			_animation.play(_current_movement)
			await get_tree().create_timer(.1).timeout
			_current_movement = animation.JUMP
			_animation.play(_current_movement)
	# Aplicamos el vector de velocidad al personaje
	velocity = v

func _move_idle():
	# Aplicamos la gravidad
	velocity.y += _gravity
	# Aplicamos la dirección de movimiento
	velocity.x = 0

func die():
	# Seteamos la variable de morir averdadero
	_died = true


