extends Node2D

@onready var animation_sprite := $AnimatedSprite2D

var speed_ball: int

var is_ball_moving: bool = true

var enemy_player: CharacterBody2D = null
var copy_enemy_player: Vector2 = Vector2.ZERO
var elapsed_time: float = 0.2
var growth_speed: float = 2.0

# Elementos de la magia
var type_element: String = "flame_enabled"
var list_damage_type_element = {
	"flame": 2,
	"water": 1,
	"darkness": 3,
	"flame_water": 4,
}
var damage_bullet = 0

func _ready():
	animation_sprite.play(type_element)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	animation_sprite.play(type_element)
#	print(type_element)
	
	choose_damage()
	
	if is_ball_moving:
		slime_to_player(delta)
		if type_element=="flame_water":
			grow_over_time(delta)

func _on_visible_on_screen_enabler_2d_screen_exited():
	die()

func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy"):
#		print(body.get_name())
		body.hit(damage_bullet)
		await get_tree().create_timer(1).timeout
		die()

func choose_damage():
	if type_element:
		damage_bullet = list_damage_type_element[type_element.split("-")[0]]
	else:
		damage_bullet = 0

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
			
func grow_over_time(delta):
	elapsed_time += delta
	var growth_factor = growth_speed * elapsed_time
	scale = Vector2(0.2,0.2) * growth_factor	

func die():
	self.queue_free()
 
