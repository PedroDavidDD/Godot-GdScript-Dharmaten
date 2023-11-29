extends CharacterBody2D

@export var golem_character: CharacterBody2D # Referencia al personaje a mover
@export var main_animation: AnimatedSprite2D # Referencia al sprite del personaje

@onready var _anim = $AnimatedSprite2D



func _ready():
	_anim.play("Walk")

func _physics_process(delta):
	pass
