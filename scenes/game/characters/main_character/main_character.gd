extends CharacterBody2D

const PPM = 32
const ESCALA_SPRITES = 1
const DISTANCIA_COLISION = 2

var direccion = Vector2()
var rapidez = 100
#var rapidez = 2.0 * ESCALA_SPRITES * PPM

@onready var animated_sprite = $Animation
var joystick : Joystick

func _ready():
	pass

func _input(event):
	if joystick != null and is_instance_valid(joystick):
		direccion = joystick.direccion
	else:
		direccion.x = Input.get_axis("ui_left", "ui_right")
		direccion.y = Input.get_axis("ui_up", "ui_down")
		direccion = direccion.normalized()
	calcular_flip_h()

func calcular_flip_h():
	if not is_zero_approx(direccion.x):
		animated_sprite.flip_h = direccion.x < 0
		if animated_sprite.flip_h:
			animated_sprite.position.x = -0 * ESCALA_SPRITES - DISTANCIA_COLISION
		else:
			animated_sprite.position.x = 0


func _physics_process(delta):
	velocity = direccion * rapidez
	move_and_slide()

func recibir_joystick(j : Joystick):
	joystick = j

