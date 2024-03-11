extends Node2D

#Key0 == draw, key4 == shoot
var head_sequence = [KEY_0, KEY_1, KEY_4]
var body_sequence = [KEY_0, KEY_2, KEY_4]
var leg_sequence = [KEY_0, KEY_3, KEY_4]

#key5 == block
var block_sequence = [KEY_5, KEY_1]
var block_legs_sequence = [KEY_5, KEY_3]
var input_buffer = []

var duel = false

var countdown_value = 3
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _rest_timeout():
	duel = true
	input_buffer.clear()
	

func _duel_timeout():
	duel = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if duel:
		if Input.is_action_just_pressed("right_player_draw"):
			handle_input(KEY_0)
		elif Input.is_action_just_pressed("right_player_up"):
			handle_input(KEY_1)
		elif Input.is_action_just_pressed("right_player_straight"):
			handle_input(KEY_2)
		elif Input.is_action_just_pressed("right_player_down"):
			handle_input(KEY_3)
		elif Input.is_action_just_pressed("right_player_shoot"):
			handle_input(KEY_4)
		elif Input.is_action_just_pressed("right_player_block"):
			handle_input(KEY_5)



func handle_input(key):
	input_buffer.append(key)
	if duel:
		if input_buffer == block_legs_sequence:
			#emit_signal("pass_up_r", 2) 
			pass_up_r.emit(2)
			duel = false
			print("block legs")
			
		elif input_buffer == block_sequence:
			#emit_signal("pass_up_r", 3)
			pass_up_r.emit(3)
			duel = false
			print("Blcok")
			
		elif input_buffer == head_sequence:
			#emit_signal("pass_up_r", 4)
			pass_up_r.emit(4)
			duel = false
			print("headshot")
			
		elif input_buffer == body_sequence:
			emit_signal("pass_up_r", 5)
			#pass_up_r.emit(5??
			duel = false
			print("body shot")
			
		elif input_buffer == leg_sequence:
			#emit_signal("pass_up_r", 6)
			pass_up_r.emit(6)
			duel = false
			print("leg shot")
		

signal pass_up_r(data)
