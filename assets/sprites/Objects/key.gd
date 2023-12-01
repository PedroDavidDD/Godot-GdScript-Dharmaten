extends Sprite2D

var idKey = "C" + str(randi() % 100)  # Genera un número aleatorio entre 0 y 99 y lo concatena con "C".

@onready var textKey = $Control/Panel/TextKey
@onready var inv = $"/root/InventoryCanvas"
@onready var rune_light = $PointLight2D

@export var change_rune_light = false

func _ready():
	textKey.text = str(idKey)

func _process(delta):
	rune_light.visible = change_rune_light

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		var player_keys = body.get_node("MainCharacterMovement").playerKeys
		player_keys.push_back(idKey)
		inv.add_item_by_name("key")
		self.queue_free()
