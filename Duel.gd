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

var countdown_value = 3
@onready var rest_label = $Rest_Display
@onready var rest_timer = $Rest_Timer
@onready var duel_label = $Duel_Display
# Called when the node enters the scene tree for the first time.
func _ready():
	rest_timer.start()

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
		handle_collision()
		handle_lp_input()
		handle_rp_input()
			

func reset():
	$Rest_Timer.start()
	left_health = HEALTH
	right_health = HEALTH
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
	


func _on_duel_timer_timeout():
	reset()

func handle_lp_input():
	if Input.is_action_pressed("left_player_draw"):
		check_rp_block()
		if Input.is_action_pressed("left_player_up") and Input.is_action_just_pressed("left_player_shoot"):
			#upper
			if rp_upper_block:
				print("Right Player Blocks Head")
				
			else:
				print("Right player gets headshot")
				right_health -= HEAD_SHOT
				
		if Input.is_action_pressed("left_player_straight") and Input.is_action_just_pressed("left_player_shoot"):
			#left player shoots straight
			
			if rp_upper_block:
				print("Right Player Blocks Torso")
				
			else:
				print("Right player gets shot in the torso")
				right_health -= BODY_SHOT
		
		if Input.is_action_pressed("left_player_down") and Input.is_action_just_pressed("left_player_shoot"):
			#left player shoots Down
			
			if rp_lower_block:
				print("Right Player Blocks Legs")
				
			else:
				print("Right player gets shot in the legs")
				right_health -= LEG_SHOT
			
	if Input.is_action_pressed("left_player_block"):
		if Input.is_action_pressed("left_player_down"):
			lp_lower_block = true
			
		else:
			lp_upper_block = true

func handle_rp_input():
	if Input.is_action_pressed("right_player_draw"):
		if Input.is_action_pressed("right_player_up") and Input.is_action_just_pressed("right_player_shoot"):
		# right player shoots up
			if lp_upper_block:
				print("Left Player Blocks Head")
				
			else:
				print("Left player gets headshot")
				left_health -= HEAD_SHOT
		if Input.is_action_pressed("right_player_straight") and Input.is_action_just_pressed("right_player_shoot"):
			#right player shoots straihgt
			if lp_upper_block:
				print("Left Player Blocks Torso")
				
			else:
				print("Left player gets shot in the torso")
				left_health -= BODY_SHOT
		
		if Input.is_action_pressed("right_player_down") and Input.is_action_just_pressed("right_player_shoot"):
			if lp_lower_block:
				print("Left Player Blocks Legs")
				
			else:
				print("Left player gets shot in the legs")
				left_health -= LEG_SHOT
			
		
func check_rp_block():
	if Input.is_action_pressed("right_player_block"):
		if Input.is_action_pressed("right_player_down"):
			rp_lower_block = true
			
		else:
			rp_upper_block = true
	

func handle_collision():
	if Input.is_action_pressed("left_player_draw") and  Input.is_action_pressed("right_player_draw"):
		if Input.is_action_pressed("left_player_up") and Input.is_action_pressed("right_player_up"):
			if Input.is_action_pressed("left_player_shoot") and Input.is_action_pressed("right_player_shoot"):
				print("Bullets collid mid-air")
