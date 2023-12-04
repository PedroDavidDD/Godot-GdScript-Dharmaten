extends Control

var time: float = 0.0
var seconds: int = 0
var minutes: int = 0
var msec: int = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time+=delta
	msec = fmod(time,1)*100
	seconds = fmod(time,60)
	minutes = fmod(time,3600) / 60
	$Min.text = "%02d:" % minutes
	$Sec.text = "%02d." % seconds
	$Msec.text = "%03d" % msec
