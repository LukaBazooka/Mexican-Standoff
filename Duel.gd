extends Node2D

const HEALTH = 100
const HEAD_SHOT = 100
const BODY_SHOT = 50
const LEG_SHOT = 34
const NO_DMG = 0


var left_health = HEALTH
var right_health = HEALTH
var actively_handle_state = false
var handle_first = false
var current_state_arr = [0, 0]

const STATE_DICT = {
[0, 0]: [NO_DMG, NO_DMG],[1, 0]: [NO_DMG, NO_DMG], [2, 0]: [NO_DMG, NO_DMG], [3, 0]: [NO_DMG, NO_DMG], [4, 0]: [NO_DMG, HEAD_SHOT], [5, 0]: [NO_DMG, BODY_SHOT], [6, 0]: [NO_DMG, LEG_SHOT], #No actoin
[0, 1]: [NO_DMG, NO_DMG], [1, 1]: [NO_DMG, NO_DMG], [2, 1]: [NO_DMG, NO_DMG], [3, 1]: [NO_DMG, NO_DMG], [4, 1]: [NO_DMG, HEAD_SHOT], [5, 1]: [NO_DMG, BODY_SHOT], [6, 1]: [NO_DMG, LEG_SHOT], #Reload
[0, 2]: [NO_DMG, NO_DMG],[1, 2]: [NO_DMG, NO_DMG], [2, 2]: [NO_DMG, NO_DMG], [3, 2]: [NO_DMG, NO_DMG], [4, 2]: [NO_DMG, NO_DMG], [5, 2]: [NO_DMG, BODY_SHOT], [6, 2]: [NO_DMG, NO_DMG], #legs bloc
[0, 3]: [NO_DMG, NO_DMG], [1, 3]: [NO_DMG, NO_DMG], [2, 3]: [NO_DMG, NO_DMG], [3, 3]: [NO_DMG, NO_DMG], [4, 3]: [NO_DMG, NO_DMG], [5, 3]: [NO_DMG, NO_DMG], [6, 3]: [NO_DMG, LEG_SHOT], #Block upper
[0, 4]: [HEAD_SHOT, NO_DMG],[1, 4]: [HEAD_SHOT, NO_DMG], [2, 4]: [NO_DMG, NO_DMG], [3, 4]: [NO_DMG, NO_DMG], [4, 4]: [NO_DMG, NO_DMG], [5, 4]: [HEAD_SHOT, BODY_SHOT], [6, 4]: [HEAD_SHOT, LEG_SHOT], #headshot
[0, 5]: [BODY_SHOT, NO_DMG], [1, 5]: [BODY_SHOT, NO_DMG], [2, 5]: [BODY_SHOT, NO_DMG], [3, 5]: [NO_DMG, NO_DMG], [4, 5]: [BODY_SHOT, HEAD_SHOT], [5, 5]: [BODY_SHOT, BODY_SHOT], [6, 5]: [BODY_SHOT, LEG_SHOT], #Bodyshot
[0, 6]: [LEG_SHOT, NO_DMG], [1, 6]: [LEG_SHOT, NO_DMG], [2, 6]: [NO_DMG, NO_DMG], [3, 6]: [LEG_SHOT, NO_DMG], [4, 6]: [LEG_SHOT, HEAD_SHOT], [5, 6]: [LEG_SHOT, BODY_SHOT], [6, 6]: [LEG_SHOT, LEG_SHOT] #leg shot
}
"""
action states	
0 = nothing		[lp_state, rp_state] = [lp_dmg_taken, rp_dmg_taken]
1 = reload 
2 = upper block	
3 = lower block
4 = headshot
5 = bodyshot
6 = legshot

"""

var lp_state = 0
var rp_state = 0

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
	$PlayerGUI/LeftPlayerGUI/VBoxContainer/HealthLabel/HealthValue.text = str(left_health)
	$PlayerGUI/RightPlayerGUI/VBoxContainer/HealthLabel/HealthValue.text = str(right_health)
	_update_health_gui()
	
	if not $Rest_Timer.is_stopped():
		rest_label.text = "Rest: %01d" % time_left_rest()
	
	if not $DuelTimer.is_stopped():
		$Duel_Display.text = "Duel: %01d" % time_left_duel()


func new_round():
	$Rest_Timer.start()
	if left_health == 0 and right_health == 0:
		left_health = 1
		right_health = 1
	if left_health <= 0:
		#print("Left player dead")
		$DeathScreen.visible = true
		pass
	if right_health <= 0:
		#print("Right player dead")
		$DeathScreen.visible = true
		pass

func _on_rest_timer_timeout():
	$DuelTimer.start()
	$LeftPlayer._rest_timeout()
	$RightPlayer._rest_timeout()
	actively_handle_state = true
	handle_first = true


func _on_duel_timer_timeout():
	new_round()
	$LeftPlayer._duel_timeout()
	$RightPlayer._duel_timeout()
	actively_handle_state = false
	

#staers timer for time alowed between user inputs
func handle_first_state():
	$StateTimer.start()
	handle_first = false #ensures can't be called twice in the same round

func handle_second_state(): 
	#effectively sets wait time to 0 so _on_state_timer_timeout() can be executed
	$StateTimer.set_wait_time(0.0001)
	actively_handle_state = false #no longer registeirng inputs
	if lp_state == 0 and rp_state == 0:
		pass

#handles lp state once they have been passed up
func _on_left_player_pass_up_l(data):
	lp_state = data
	state_transfer("lp", data)

#handles rp state once they have been passed up
func _on_right_player_pass_up_r(data):
	rp_state = data
	state_transfer("rp", data)

#loads damage to be donoe for each player from state dict to current_state_arr
func _on_state_timer_timeout():
	current_state_arr = STATE_DICT.get([lp_state, rp_state], [0, 0])

#only executes once a bullet has entered area2d in left player
func _on_left_player_lp_bullet_collided():
	left_health -= current_state_arr[0]
	if lp_state == 4: #possiblity that bullet collides if too opp too slow
		left_health -= 100

#only executes once a bullet has entered area2d in right player
func _on_right_player_rp_bullet_collided():
	right_health -= current_state_arr[1]
	if rp_state == 4: #possiblity that bullet collides if too opp too slow
		right_health -= 100

#passes to player their state for execution 
func pass_down_state(user, data):
	if data == 2 or data == 3:
		emit_signal(user + "_block_state", data)
	elif data > 3:
		emit_signal(user + "_shoot", data)

#determines if first or second player to submit input
func state_transfer(user, data):
	if actively_handle_state: #while we can register inputs
		if handle_first: #handle first player input
			handle_first_state()
			pass_down_state(user, data)
		else: #handle second player input
			pass_down_state(user, data)
			handle_second_state()
			

func _update_health_gui():
	if left_health <= 0:
		$left_heart1/HeartSprite.animation = "heartempty"
		$left_heart2/HeartSprite.animation = "heartempty"
		$left_heart3/HeartSprite.animation = "heartempty"
	if left_health <= 17 and left_health > 0:
		$left_heart1/HeartSprite.animation = "halfheart"
		$left_heart2/HeartSprite.animation = "heartempty"
		$left_heart3/HeartSprite.animation = "heartempty"
	if left_health <= 34 and left_health >= 17:
		$left_heart1/HeartSprite.animation = "heartfull"
		$left_heart2/HeartSprite.animation = "heartempty"
		$left_heart3/HeartSprite.animation = "heartempty"
	if left_health <= 49 and left_health >= 34:
		$left_heart1/HeartSprite.animation = "heartfull"
		$left_heart2/HeartSprite.animation = "halfheart"
		$left_heart3/HeartSprite.animation = "heartempty"
	if left_health <= 67 and left_health >= 49:
		$left_heart1/HeartSprite.animation = "heartfull"
		$left_heart2/HeartSprite.animation = "heartfull"
		$left_heart3/HeartSprite.animation = "heartempty"
	if left_health <= 83 and left_health >= 67:
		$left_heart1/HeartSprite.animation = "heartfull"
		$left_heart2/HeartSprite.animation = "heartfull"
		$left_heart3/HeartSprite.animation = "halfheart"
	if left_health <= 100 and left_health >= 83:
		$left_heart1/HeartSprite.animation = "heartfull"
		$left_heart2/HeartSprite.animation = "heartfull"
		$left_heart3/HeartSprite.animation = "heartfull"

signal lp_block_state
signal lp_shoot
signal rp_block_state
signal rp_shoot


func _on_retry_pressed():
	get_tree().reload_current_scene()
