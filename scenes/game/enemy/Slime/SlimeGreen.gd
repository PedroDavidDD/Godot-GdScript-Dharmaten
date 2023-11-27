extends CharacterBody2D

# Variables de animación de la poción y audio
@export var slime_character: CharacterBody2D # Referencia al personaje a mover
@export var main_animation: AnimatedSprite2D # Referencia al sprite del personaje

@onready var _animation := $EnemyAnimation
@onready var _raycast_terrain := $Area2D/RayCastTerrain
@onready var audio_player:= $AudioStreamPlayer2D # Reproductor de audios

var animation = {
	IDLE = "idle",
	RUN = "run",
	JUMP = "jump",
	FALL = "fall",
	ATTACKING = "attack",
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
var isMoving = true
var speedSlime = 100
var player = null
var _died = false
var wave = 0




var _orbe = preload("res://scenes/game/enemy/Orbe/orbe.tscn")
var _male_hurt_sound = preload("res://assets/sounds/male_hurt.mp3")

var slime_life = 2

func _ready():
	if not _current_movement:
		_current_movement = animation.RUN
	# Si no hay un personaje, deshabilitamos la función: _physics_process
	if not slime_character:
		set_physics_process(false)
	# animacion
	_init_state()
	

func _init_state():
	# Animación de estado inicial
	_animation.play(_current_movement)
	
# _animation.play(animation.RUN)
func _process(delta):
	
	player = get_tree().get_nodes_in_group("player")[0].get_node("MainCharacterMovement")
	
	# Si la animación es de correr, aplicamos el movimiento
	if _current_movement == animation.RUN:
		slime_to_player(delta)
	# Atacar si esta cerca del colider
	elif _current_movement == animation.ATTACKING:
		isMoving = false
	
	#_animation.play(_current_movement)
	# Iniciamos el movimiento
	move_and_slide()
	

			
	

func _on_area_2d_body_entered(body):
#	contrl + k
	if body.is_in_group("player"):
		_current_movement = animation.ATTACKING
		attacking()

func attacking():
	player.hit(1)
	_current_movement = animation.RUN

# Recibir daño
func hit(value: int):
	if _died:
		return
	
	slime_life -= value
	if slime_life < 0:
		slime_life = 0
	
	_play_sound(_male_hurt_sound)
	_animation.play("hit")
	# Bajamos vida y validamos si el personaje ha perdido
	if slime_life == 0:
		die()
	else:
		pass

func _play_sound(sound):
	# Pausamos el sonido
	audio_player.stop()
	# Reproducimos el sonido
	audio_player.stream = sound
	audio_player.play()

func die():
	createOrbe()
	self.queue_free()  # Liberamos la memoria

func createOrbe():
	var shoot_orbe = _orbe.instantiate()
	if shoot_orbe.scale.x < 0:
		shoot_orbe.scale = Vector2(-1, 1)
	else:
		shoot_orbe.scale = Vector2(1, 1)
	shoot_orbe.global_position = global_position
	get_parent().get_parent().add_child(shoot_orbe)

func slime_to_player(delta):
	if player and isMoving:
		var target_position = player.global_position
		var distance_threshold = 30
		var direction = global_position.direction_to(target_position)
		var move_amount = direction * speedSlime * delta
		
		if global_position.distance_to(target_position) > distance_threshold:
			global_position += move_amount

