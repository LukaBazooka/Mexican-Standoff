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
var handled_death = false
var current_state_arr = [0, 0]
var duel_time
var rest_time

@onready var blood_splatter = load("res://blood_splatter.tscn")

const STATE_DICT = {
[0, 0]: [NO_DMG, NO_DMG],[1, 0]: [NO_DMG, NO_DMG], [2, 0]: [NO_DMG, NO_DMG], [3, 0]: [NO_DMG, NO_DMG], [4, 0]: [NO_DMG, HEAD_SHOT], [5, 0]: [NO_DMG, BODY_SHOT], [6, 0]: [NO_DMG, LEG_SHOT], #No actoin
[0, 1]: [NO_DMG, NO_DMG], [1, 1]: [NO_DMG, NO_DMG], [2, 1]: [NO_DMG, NO_DMG], [3, 1]: [NO_DMG, NO_DMG], [4, 1]: [NO_DMG, HEAD_SHOT], [5, 1]: [NO_DMG, BODY_SHOT], [6, 1]: [NO_DMG, LEG_SHOT], #Reload
[0, 2]: [NO_DMG, NO_DMG],[1, 2]: [NO_DMG, NO_DMG], [2, 2]: [NO_DMG, NO_DMG], [3, 2]: [NO_DMG, NO_DMG], [4, 2]: [NO_DMG, NO_DMG], [5, 2]: [NO_DMG, NO_DMG], [6, 2]: [NO_DMG, LEG_SHOT], #block uppper
[0, 3]: [NO_DMG, NO_DMG], [1, 3]: [NO_DMG, NO_DMG], [2, 3]: [NO_DMG, NO_DMG], [3, 3]: [NO_DMG, NO_DMG], [4, 3]: [NO_DMG, NO_DMG], [5, 3]: [NO_DMG, BODY_SHOT], [6, 3]: [NO_DMG, NO_DMG], #leg block
[0, 4]: [HEAD_SHOT, NO_DMG],[1, 4]: [HEAD_SHOT, NO_DMG], [2, 4]: [NO_DMG, NO_DMG], [3, 4]: [NO_DMG, NO_DMG], [4, 4]: [NO_DMG, NO_DMG], [5, 4]: [HEAD_SHOT, BODY_SHOT], [6, 4]: [HEAD_SHOT, LEG_SHOT], #headshot
[0, 5]: [BODY_SHOT, NO_DMG], [1, 5]: [BODY_SHOT, NO_DMG], [2, 5]: [NO_DMG, NO_DMG], [3, 5]: [BODY_SHOT, NO_DMG], [4, 5]: [BODY_SHOT, HEAD_SHOT], [5, 5]: [BODY_SHOT, BODY_SHOT], [6, 5]: [BODY_SHOT, LEG_SHOT], #Bodyshot
[0, 6]: [LEG_SHOT, NO_DMG], [1, 6]: [LEG_SHOT, NO_DMG], [2, 6]: [LEG_SHOT, NO_DMG], [3, 6]: [NO_DMG, NO_DMG], [4, 6]: [LEG_SHOT, HEAD_SHOT], [5, 6]: [LEG_SHOT, BODY_SHOT], [6, 6]: [LEG_SHOT, LEG_SHOT] #leg shot
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


@onready var rest_timer = $Rest_Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	rest_timer.start()
	left_health = HEALTH
	right_health = HEALTH
	
	#Hide Mouse Cursor
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$PlayerGUI/LeftPlayerGUI/VBoxContainer/HealthLabel/HealthValue.text = str(left_health)
	$PlayerGUI/RightPlayerGUI/VBoxContainer/HealthLabel/HealthValue.text = str(right_health)
	_update_lp_health_gui()
	_update_rp_health_gui()
	
	duel_time = $DuelTimer.time_left
	rest_time = $Rest_Timer.time_left



func new_round():
	$Rest_Timer.start()


func _on_rest_timer_timeout():
	$DuelTimer.start()
	$LeftPlayer._rest_timeout()
	$RightPlayer._rest_timeout()
	actively_handle_state = true
	handle_first = true
	$PlayerGUI/DrawPopup.visible = true
	$PlayerGUI/DrawPopup/Timer.start()
	
	#hide campfire
	$BlueCampfire.hide()
	$PinkCampfire.hide()


func _on_duel_timer_timeout():
	$Action_finish.start()
	$LeftPlayer._duel_timeout()
	$RightPlayer._duel_timeout()
	actively_handle_state = false
	
	#show campfire
	$BlueCampfire.show()
	$PinkCampfire.show()

#staers timer for time alowed between user inputs
func handle_first_state():
	$StateTimer.start()
	handle_first = false #ensures can't be called twice in the same round


func handle_second_state(): 
	#effectively sets wait time to 0 so _on_state_timer_timeout() can be executed
	$StateTimer.set_wait_time(0.0001) #Note the wait time must be rest to its intial value later

#handles lp state once they have been passed up
func _on_left_player_pass_up_l(data):
	lp_state = data
	state_transfer("lp", data)

#handles rp state once they have been passed up
func _on_right_player_pass_up_r(data):
	rp_state = data
	state_transfer("rp", data)

#loads damage to be done for each player from state dict to current_state_arr
func _on_state_timer_timeout():
	actively_handle_state =  false
	current_state_arr = STATE_DICT.get([lp_state, rp_state], [0, 0])
	$StateTimer.set_wait_time(0.5) #resets wait time appropriatly



#only executes once a bullet has entered area2d in left player
func _on_left_player_lp_bullet_collided():
	var blood_instance = blood_splatter.instantiate() 
	blood_instance.position = $LeftPlayer/bloodpoint.position
	blood_instance.z_index += 5
	add_child(blood_instance) #add to scene
	
	#$LeftPlayer/charactersprite.play("hit")
	
	left_health -= current_state_arr[0]
	if lp_state == 4: #possiblity that bullet collides if too opp too slow
		left_health -= 100
		
	if left_health <= 0:
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
		$LeftPlayer/charactersprite.play("death")
		$DeathScreen.visible = true
		$DeathScreen/RightPlayerWins.visible = true
		if not handled_death:
			handle_death()

#only executes once a bullet has entered area2d in right player
func _on_right_player_rp_bullet_collided():
	var blood_instance = blood_splatter.instantiate() 
	blood_instance.position = $RightPlayer/bloodpoint.position
	blood_instance.z_index += 5
	add_child(blood_instance) #add to scene
	
	right_health -= current_state_arr[1]
	if rp_state == 4: #possiblity that bullet collides if too opp too slow
		right_health -= 100
		
	if right_health <= 0:
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
		$RightPlayer/charactersprite.play("death")
		$DeathScreen.visible = true
		$DeathScreen/LeftPlayerWins.visible = true
		if not handled_death:
			handle_death()

func handle_death():
	handled_death = true
	$DeathScreen.visible = true
	$Rest_Timer.stop()
	$Action_finish.stop()
	$DuelTimer.stop()
	
	await get_tree().create_timer(0.05).timeout
	if left_health <= 0 and right_health <= 0:
		await get_tree().create_timer(0.6).timeout
		$DeathScreen.visible = false
		$LeftPlayer/charactersprite.play("reverse_death")
		$RightPlayer/charactersprite.play("reverse_death")
		
		left_health = 1
		right_health = 1
		$Rest_Timer.start()
		
		await get_tree().create_timer(0.6).timeout
		$LeftPlayer/charactersprite.play("idle")
		$RightPlayer/charactersprite.play("idle")
	else: 
		#only one player died
		#tear_down makes sure no collisions can happen
		tear_down()
		if left_health > 0:
			$LeftPlayer/charactersprite.play("win_anim")
		elif right_health > 0:
			$RightPlayer/charactersprite.play("win_anim")
		await get_tree().create_timer(0.6).timeout
	handled_death = false



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
			

func _update_lp_health_gui():
	if left_health <= 0:
		$PlayerGUI/LeftPlayerGUI/Hearts/left_heart1/HeartSprite.animation = "heartempty"
		$PlayerGUI/LeftPlayerGUI/Hearts/left_heart2/HeartSprite.animation = "heartempty"
		$PlayerGUI/LeftPlayerGUI/Hearts/left_heart3/HeartSprite.animation = "heartempty"
	elif left_health == 16:
		$PlayerGUI/LeftPlayerGUI/Hearts/left_heart1/HeartSprite.animation = "halfheart"
		$PlayerGUI/LeftPlayerGUI/Hearts/left_heart2/HeartSprite.animation = "heartempty"
		$PlayerGUI/LeftPlayerGUI/Hearts/left_heart3/HeartSprite.animation = "heartempty"
	elif left_health == 32:
		$PlayerGUI/LeftPlayerGUI/Hearts/left_heart1/HeartSprite.animation = "heartfull"
		$PlayerGUI/LeftPlayerGUI/Hearts/left_heart2/HeartSprite.animation = "heartempty"
		$PlayerGUI/LeftPlayerGUI/Hearts/left_heart3/HeartSprite.animation = "heartempty"
	elif left_health == 50:# one body shot
		$PlayerGUI/LeftPlayerGUI/Hearts/left_heart1/HeartSprite.animation = "heartfull"
		$PlayerGUI/LeftPlayerGUI/Hearts/left_heart2/HeartSprite.animation = "halfheart"
		$PlayerGUI/LeftPlayerGUI/Hearts/left_heart3/HeartSprite.animation = "heartempty"
	elif left_health == 66: # 2 hearts, 1 leg shot
		$PlayerGUI/LeftPlayerGUI/Hearts/left_heart1/HeartSprite.animation = "heartfull"
		$PlayerGUI/LeftPlayerGUI/Hearts/left_heart2/HeartSprite.animation = "heartfull"
		$PlayerGUI/LeftPlayerGUI/Hearts/left_heart3/HeartSprite.animation = "heartempty"

	else: #full health
		$PlayerGUI/LeftPlayerGUI/Hearts/left_heart1/HeartSprite.animation = "heartfull"
		$PlayerGUI/LeftPlayerGUI/Hearts/left_heart2/HeartSprite.animation = "heartfull"
		$PlayerGUI/LeftPlayerGUI/Hearts/left_heart3/HeartSprite.animation = "heartfull"

func _update_rp_health_gui():
	if right_health <= 0:
		$PlayerGUI/RightPlayerGUI/Hearts/left_heart1/HeartSprite.animation = "heartempty"
		$PlayerGUI/RightPlayerGUI/Hearts/left_heart2/HeartSprite.animation = "heartempty"
		$PlayerGUI/RightPlayerGUI/Hearts/left_heart3/HeartSprite.animation = "heartempty"
	elif right_health == 16:
		$PlayerGUI/RightPlayerGUI/Hearts/left_heart1/HeartSprite.animation = "halfheart"
		$PlayerGUI/RightPlayerGUI/Hearts/left_heart2/HeartSprite.animation = "heartempty"
		$PlayerGUI/RightPlayerGUI/Hearts/left_heart3/HeartSprite.animation = "heartempty"
	elif right_health == 32:
		$PlayerGUI/RightPlayerGUI/Hearts/left_heart1/HeartSprite.animation = "heartfull"
		$PlayerGUI/RightPlayerGUI/Hearts/left_heart2/HeartSprite.animation = "heartempty"
		$PlayerGUI/RightPlayerGUI/Hearts/left_heart3/HeartSprite.animation = "heartempty"
	elif right_health == 50:
		$PlayerGUI/RightPlayerGUI/Hearts/left_heart1/HeartSprite.animation = "heartfull"
		$PlayerGUI/RightPlayerGUI/Hearts/left_heart2/HeartSprite.animation = "halfheart"
		$PlayerGUI/RightPlayerGUI/Hearts/left_heart3/HeartSprite.animation = "heartempty"
	elif right_health == 66:
		$PlayerGUI/RightPlayerGUI/Hearts/left_heart1/HeartSprite.animation = "heartfull"
		$PlayerGUI/RightPlayerGUI/Hearts/left_heart2/HeartSprite.animation = "heartfull"
		$PlayerGUI/RightPlayerGUI/Hearts/left_heart3/HeartSprite.animation = "heartempty"
	else:
		$PlayerGUI/RightPlayerGUI/Hearts/left_heart1/HeartSprite.animation = "heartfull"
		$PlayerGUI/RightPlayerGUI/Hearts/left_heart2/HeartSprite.animation = "heartfull"
		$PlayerGUI/RightPlayerGUI/Hearts/left_heart3/HeartSprite.animation = "heartfull"



signal lp_block_state
signal lp_shoot
signal rp_block_state
signal rp_shoot

#Retry button clicked on duel end/deathscreen
func _on_retry_pressed():
	get_tree().reload_current_scene()

#When "DUEL" Goes away
func _on_timer_timeout():
	$PlayerGUI/DrawPopup.visible = false

#used for finishing actions and animations before next round
func _on_action_finish_timeout():
	$Rest_Timer.start()
	$LeftPlayer._action_timeout()
	$RightPlayer._action_timeout()


func tear_down():
	#called when game over
	# clears all bullets and collison shapes
	if $LeftPlayer.get_child_count() == 4:
		$LeftPlayer.get_child(3).queue_free()
	$LeftPlayer.get_child(2).queue_free()
	
	if $RightPlayer.get_child_count() == 4:
		$RightPlayer.get_child(3).queue_free()
	$LeftPlayer.get_child(2).queue_free()
