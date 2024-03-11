extends Node2D

const HEALTH = 100
const HEAD_SHOT = 100
const BODY_SHOT = 50
const LEG_SHOT = 34

var left_health = HEALTH
var right_health = HEALTH


var lp_state = 0
var rp_state = 0

var countdown_value = 3
@onready var rest_label = $Rest_Display
@onready var rest_timer = $Rest_Timer
@onready var duel_label = $Duel_Display
# Called when the node enters the scene tree for the first time.
func _ready():
	rest_timer.start()
	left_health = HEALTH
	right_health = HEALTH

func time_left_rest():
	var second = int(rest_timer.time_left) % 60
	return [second]
	
	
func time_left_duel():
	var second = int($DuelTimer.time_left) % 60
	return [second]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not $Rest_Timer.is_stopped():
		rest_label.text = "%02d" % time_left_rest()
	
	if not $DuelTimer.is_stopped():
		$Duel_Display.text = "%02d" % time_left_duel()
		
		if not $DuelTimer.is_stopped():
			handle_headshot()
			handle_bodyshot()
			handle_legshot()
	
	

func new_round():
	$Rest_Timer.start()

func _on_rest_timer_timeout():
	if left_health == 0 and right_health == 0:
		left_health = 1
		right_health = 1
	if left_health == 0:
		print("Left player dead")
	if right_health == 0:
		print("Right player dead")
	$DuelTimer.start()
	
	$LeftPlayer._rest_timeout()
	$RightPlayer._rest_timeout()
	


func _on_duel_timer_timeout():
	new_round()
	$LeftPlayer._duel_timeout()
	$RightPlayer._duel_timeout()
	

func handle_headshot():
	if rp_state == 4 and lp_state == 4:
		print("collide")
	
	if rp_state == 4:
		if lp_state == 2 or lp_state == 3:
			print("rp misses lp")
		else:
			print("lp gets headshot")
	if lp_state == 4:
		if rp_state == 2 or rp_state == 3:
			print("lp misses rp")
		else:
			print("rp gets headshot") 

func handle_bodyshot():
	if lp_state == 5 and rp_state == 5:
		print("both players get body shot")
		
	elif lp_state == 5:
		if rp_state == 3:
			print("rp blocks")
		else:
			print("rp gets body shot")
			
	elif rp_state == 5:
		if lp_state == 3:
			print("lp blocks")
		else:
			print("lp gets body shot")

func handle_legshot():
	if lp_state == 6 and rp_state == 6:
		print("both players get shot in the leg")
	elif lp_state == 6:
		if rp_state == 2:
			print("rp blocked legs")
		else:
			print("rp gets shot in legs")
			
	elif rp_state == 6:
		if lp_state == 2:
			print("lp blocked legs")
			
		else:
			print("lp gets shot in legs")


func _on_left_player_pass_up_l(data):
	print("baba")
	lp_state = data


func _on_right_player_pass_up_r(data):
	rp_state = data
