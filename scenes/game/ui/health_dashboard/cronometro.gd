extends Control

var time: float = 0.0
var seconds: int = 0
var minutes: int = 0
var msec: int = 0
var check 
var active= false
var reset 
var stopping
var time_running = true
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check = get_tree().get_nodes_in_group("menu")
	check = check[0].survival
	if check:
		active=true
	
	if active:
		reset = get_tree().get_nodes_in_group("player")
		stopping = get_tree().get_nodes_in_group("player")
		
		if reset.size() > 0:
			reset = reset[0].get_node("MainCharacterMovement").cron_reset
			if reset:
				reset_timer()
		
		if time_running:		
			time+=delta
			msec = fmod(time,1)*100
			seconds = fmod(time,60)
			minutes = fmod(time,3600) / 60
			$Min.text = "%02d:" % minutes
			$Sec.text = "%02d." % seconds
			$Msec.text = "%03d" % msec
		
		if stopping.size()>0:
			stopping = stopping[0].get_node("MainCharacterMovement").stop_cronometer
			if stopping:
				stop_timer()

func reset_timer() -> void:
	time = 0.0
	seconds = 0
	minutes = 0
	msec = 0
	$Min.text = "00:"
	$Sec.text = "00."
	$Msec.text = "000"
	time_running = true

func stop_timer() -> void:
	time_running = false

	
	
	
