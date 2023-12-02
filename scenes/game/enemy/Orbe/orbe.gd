extends Area2D

@export_enum(
	"blood_orbe",
) var animation: String
# Definimos el sprite animado de la moneda
@onready var _animated_sprite = $AnimatedSprite2D
@onready var _audio_player = $AudioStreamPlayer2D # Reproductor de audios
@onready var _collider = $CollisionShape2D # Collider

var _trampolin_sound = preload("res://assets/sounds/Trampolim.wav")

@export_range(1, 10) var point_orbe = 2

# Función de carga del nodo
func _ready():
	if not animation:
		return
	
	# Cargamos las texturas de animación según el nombre configurado
	var _animation1 = "res://assets/sprites/Objects/orbe/yellow/"+ animation +".png"

	# Aplicamos la textura cargada a la animación
	_animated_sprite.sprite_frames.set_frame("idle", 0, load(_animation1))
	
	# Reproducimos la animación idle
	_animated_sprite.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("player") and not _collider.disabled:
		_collider.disabled = true
		# Reproducimos la animación de la moneda recogida
		do_animation()

func _on_body_exited(body):
	pass # Replace with function body.

func do_animation():
	# Validamos si la animación es de moneda
	_audio_player.stream = _trampolin_sound
	_audio_player.play()
	if animation == "blood_orbe":
		# Reproducimos la animación de la moneda
		_animated_sprite.play("blood_orbe_effect")
	# Aumenta la barra
	HealthDashboard.add_exp(point_orbe) 

func _on_animated_sprite_2d_animation_finished():
	# Esperamos 2 segundos 
	await get_tree().create_timer(2).timeout
	# Eliminamos el objeto recogido de la escena
	queue_free()
