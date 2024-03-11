extends Node2D

const HEALTH = 100
const HEAD_SHOT = 100
const BODY_SHOT = 50
const LEG_SHOT = 34
const NO_DMG = 0


var left_health = HEALTH
var right_health = HEALTH
var actively_handle_state = false

var state_dict = {
[0, 0]: [NO_DMG, NO_DMG],[1, 0]: [NO_DMG, NO_DMG], [2, 0]: [NO_DMG, NO_DMG], [3, 0]: [NO_DMG, NO_DMG], [4, 0]: [NO_DMG, HEAD_SHOT], [5, 0]: [NO_DMG, BODY_SHOT], [6, 0]: [NO_DMG, LEG_SHOT], #No actoin
[0, 1]: [NO_DMG, NO_DMG], [1, 1]: [NO_DMG, NO_DMG], [2, 1]: [NO_DMG, NO_DMG], [3, 1]: [NO_DMG, NO_DMG], [4, 1]: [NO_DMG, HEAD_SHOT], [5, 1]: [NO_DMG, BODY_SHOT], [6, 1]: [NO_DMG, LEG_SHOT], #Reload
[0, 2]: [NO_DMG, NO_DMG],[1, 2]: [NO_DMG, NO_DMG], [2, 2]: [NO_DMG, NO_DMG], [3, 2]: [NO_DMG, NO_DMG], [4, 2]: [NO_DMG, NO_DMG], [5, 2]: [NO_DMG, BODY_SHOT], [6, 2]: [NO_DMG, NO_DMG], #legs bloc
[0, 3]: [NO_DMG, NO_DMG], [1, 3]: [NO_DMG, NO_DMG], [2, 3]: [NO_DMG, NO_DMG], [3, 3]: [NO_DMG, NO_DMG], [4, 3]: [NO_DMG, NO_DMG], [5, 3]: [NO_DMG, NO_DMG], [6, 2]: [NO_DMG, LEG_SHOT], #Block upper
[0, 4]: [HEAD_SHOT, NO_DMG],[1, 4]: [HEAD_SHOT, NO_DMG], [2, 4]: [NO_DMG, NO_DMG], [3, 4]: [NO_DMG, NO_DMG], [4, 4]: [NO_DMG, NO_DMG], [5, 4]: [HEAD_SHOT, BODY_SHOT], [6, 4]: [HEAD_SHOT, LEG_SHOT], #headshot
[0, 5]: [BODY_SHOT, NO_DMG], [1, 5]: [BODY_SHOT, NO_DMG], [2, 5]: [BODY_SHOT, NO_DMG], [3, 5]: [NO_DMG, NO_DMG], [4, 5]: [BODY_SHOT, HEAD_SHOT], [5, 5]: [BODY_SHOT, BODY_SHOT], [6, 5]: [BODY_SHOT, LEG_SHOT], #Bodyshot
[0, 6]: [LEG_SHOT, NO_DMG], [1, 6]: [LEG_SHOT, NO_DMG], [2, 6]: [NO_DMG, NO_DMG], [3, 6]: [LEG_SHOT, NO_DMG], [4, 6]: [LEG_SHOT, HEAD_SHOT], [5, 6]: [LEG_SHOT, BODY_SHOT], [6, 6]: [LEG_SHOT, LEG_SHOT] #leg shot
}


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
			pass
			
	
	

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
	actively_handle_state = true
	


func handle_state():
	actively_handle_state = false
	$StateTimer.start()

	


func _on_left_player_pass_up_l(data):
	lp_state = data
	
	if actively_handle_state:
		handle_state()


func _on_right_player_pass_up_r(data):
	rp_state = data
	
	if actively_handle_state:
		handle_state()


func _on_state_timer_timeout():
	var state_arr = state_dict.get([lp_state, rp_state], [0, 0])
	left_health -= state_arr[0]
	right_health -= state_arr[1]
	
