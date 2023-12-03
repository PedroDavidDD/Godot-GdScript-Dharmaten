extends CharacterBody2D

# Variables de animación de la poción y audio
@export var slime_character: CharacterBody2D # Referencia al personaje a mover
@export var main_animation: AnimatedSprite2D # Referencia al sprite del personaje

@onready var _animation := $EnemyAnimation
@onready var audio_player:= $AudioStreamPlayer2D # Reproductor de audios

@onready var ray_cast_hit = $RayCast2D # Raycast
@onready var timer_hit = $Timer 

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
var speedSlime = 100
var player = null
var playerMove = null
var _died = false
var wave = 0

var _orbe = preload("res://scenes/game/enemy/Orbe/orbe.tscn")
var _male_hurt_sound = preload("res://assets/sounds/slime_death.mp3")

var slime_life = 2
var canAttack = false

func _ready():
	if not _current_movement:
		_current_movement = animation.RUN
	# animacion
	_init_state()
	

func _init_state():
	# Animación de estado inicial
	_animation.play(_current_movement)

func _process(delta):
	
	player = get_tree().get_nodes_in_group("player")[0]
	playerMove = player.get_node("MainCharacterMovement")
	# Apuntar el Ray_cast al Player
	_aim()
	# Si esta lejos del Player, movimiento
	slime_to_player(delta)
	# Si esta cerca, pasó 0.4s y el Player no esta muerto, atacar
	if _current_movement == animation.ATTACKING && !playerMove._died:
		check_player_collision()
	
	_animation.play(_current_movement)
	# Iniciamos el movimiento
	move_and_slide()

func _on_area_2d_body_entered(body):
#	contrl + k
#	if body.is_in_group("player"):
#		attacking()
	pass

func attacking():
	if canAttack:
		playerMove.hit(1)

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
#	audio_player.stop()
	# Reproducimos el sonido
	audio_player.stream = sound
	audio_player.play()

func die():
	createOrbe()
	self.queue_free()

func createOrbe():
	var shoot_orbe = _orbe.instantiate()
	if shoot_orbe.scale.x < 0:
		shoot_orbe.scale = Vector2(-1, 1)
	else:
		shoot_orbe.scale = Vector2(1, 1)
	shoot_orbe.global_position = global_position
	get_parent().get_parent().add_child(shoot_orbe)

func slime_to_player(delta):
	if playerMove:
		var target_position = playerMove.global_position
		var distance_threshold = 30
		var direction = global_position.direction_to(target_position)
		var move_amount = direction * speedSlime * delta
		
		if global_position.distance_to(target_position) > distance_threshold:
			global_position += move_amount
			canAttack = false
			_current_movement = animation.RUN
		else:
			canAttack = true
			_current_movement = animation.ATTACKING

func _aim():
	ray_cast_hit.target_position =  to_local(player.position)

func check_player_collision():
	if ray_cast_hit.get_collider() == player and timer_hit.is_stopped():
		timer_hit.start()
	elif ray_cast_hit.get_collider() != player and not timer_hit.is_stopped():
		timer_hit.stop()

func _on_timer_timeout():
	attacking()
