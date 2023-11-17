extends AnimatedSprite2D

@export var character: CharacterBody2D # Referencia al personaje a mover

var jump: int = 220 # Capacidad de salto normal
var temporary_jump: int = 0 # Capacidad de salto temporal
var jump_timer: float = 0.0 # Tiempo transcurrido del salto temporal
var jump_duration: float = 1.0 # Duración del salto temporal en segundos

var _move: Node2D # Para poder deshabilitar el personaje


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Función de ejecución de físicas
func _physics_process(_delta):


# Escuchamos cuando un "cuerpo" entra al área del objeto
func _on_area2D_area_entered(body: Area2D) -> void
	if body.is_in_group("player"):
		temporary_jump = jump * 4 # Duplicamos la capacidad de salto
		jump_timer = 0.0

# Al recoger el objeto, hacemos animación de recoger, y al terminar activamos el personaje y liberamos memoria
func _pick_up():
	# Sumar items de inventario
	InventoryCanvas.add_item_by_name(animation)
	# Hacer animación y eliminar el item de la escena
	play("pick_up")
	await animation_finished
	_move.set_disabled(false)
	queue_free()

