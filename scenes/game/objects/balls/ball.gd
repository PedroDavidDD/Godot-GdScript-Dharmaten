extends Node2D
var speed_ball: int

var is_ball_moving: bool = true
var enemy_player: CharacterBody2D = null
var copy_enemy_player: Vector2 = Vector2.ZERO

func _ready():
	$AnimatedSprite2D.play("ball")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_ball_moving:
#		global_position.x += speed_ball * delta
		slime_to_player(delta)

func _on_visible_on_screen_enabler_2d_screen_exited():
	die()

func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy"):
#		print(body.get_name())
		body.hit(1)
		await get_tree().create_timer(1).timeout
		die()

func slime_to_player(delta):
	if enemy_player:
		var target_position = copy_enemy_player
		var distance_threshold = 10
		var direction = global_position.direction_to(target_position)
		var move_amount = direction * speed_ball * delta
		
		if global_position.distance_to(target_position) > distance_threshold:
			global_position += move_amount
		else: 
			die()

func die():
	self.queue_free()
