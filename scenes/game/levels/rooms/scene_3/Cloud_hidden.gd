extends Sprite2D


@onready var parent = $"."
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	var parent_node = get_parent().get_child(0)
	if body.is_in_group("player"):
		parent_node.self_modulate = Color("#c5c5c500")


func _on_area_2d_body_exited(body):
	var parent_node = get_parent().get_child(0)
	if body.is_in_group("player"):
		parent_node.self_modulate = Color("#ffffff")
