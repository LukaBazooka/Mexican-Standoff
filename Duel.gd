extends Node2D

const HEALTH = 100
const HEAD_SHOT = 100
const BODY_SHOT = 50
const LEG_SHOT = 34

var left_health = HEALTH
var right_health = HEALTH
var lp_upper_block = false
var rp_upper_block = false
var lp_lower_block = false
var rp_lower_block = false


var lp_action_available = false
var rp_action_availble = false

var lp_state 
var rp_state

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
		
		
	
	

func new_round():
	$Rest_Timer.start()
	lp_upper_block = false
	rp_upper_block = false
	lp_lower_block = false
	rp_lower_block = false
	




func _on_rest_timer_timeout():
	if left_health == 0 and right_health == 0:
		left_health = 1
		right_health = 1
	if left_health == 0:
		print("Left player dead")
	if right_health == 0:
		print("Right player dead")
	$DuelTimer.start()
	lp_action_available = true
	rp_action_availble = true
	
	$LeftPlayer._rest_timeout()
	$RightPlayer._rest_timeout()
	


func _on_duel_timer_timeout():
	new_round()
	$LeftPlayer._duel_timeout()
	$RightPlayer._duel_timeout()
	

func _on_left_player_pass_up(data):
	lp_state = data


func _on_right_player_pass_up(data):
	rp_state = data

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
		pass
