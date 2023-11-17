extends Node2D
var speed: int

var is_ball_moving: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("ball")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_ball_moving:
		global_position.x += speed * delta

func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()


func _on_area_2d_body_entered(body):
	if not body.is_in_group("player"):
		var player = get_tree().get_nodes_in_group("player")[0].get_node("MainCharacterMovement")
		# Detener el movimiento del objeto
		is_ball_moving = false
		if player:
			player.canPlayerMove = true
	else:
		queue_free()
