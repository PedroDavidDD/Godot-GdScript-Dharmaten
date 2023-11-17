extends Node2D

@export var ball = preload("res://scenes/game/objects/balls/ball.tscn")

# Función de inicialización
func _ready():
	$AnimatedSprite2D.play("default")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
