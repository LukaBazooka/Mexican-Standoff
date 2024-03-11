extends Node2D

var bullet_scene = preload("res://bullet.tscn")

#Key0 == draw, key4 == shoot
var head_sequence = [KEY_0, KEY_1, KEY_4]
var body_sequence = [KEY_0, KEY_2, KEY_4]
var leg_sequence = [KEY_0, KEY_3, KEY_4]

#key5 == block
var block_sequence = [KEY_5, KEY_1]
var block_legs_sequence = [KEY_5, KEY_3]
var input_buffer = []
var lp_action_available = false
var duel = false

var ammo = 0

var countdown_value = 3

func _ready():
	#spawn_bullet()
	pass

func _rest_timeout():
	duel = true
	input_buffer.clear()
	

func _duel_timeout():
	duel = false
	# idle anim
	$charactersprite.play("idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if duel:
		if Input.is_action_just_pressed("left_player_draw"):
			handle_input(KEY_0)
			#draw anim
			$charactersprite.play("draw")
			
		elif Input.is_action_just_pressed("left_player_up"):
			handle_input(KEY_1)
		elif Input.is_action_just_pressed("left_player_straight"):
			handle_input(KEY_2)
		elif Input.is_action_just_pressed("left_player_down"):
			handle_input(KEY_3)
		elif Input.is_action_just_pressed("left_player_shoot"):
			handle_input(KEY_4)
			$charactersprite.play("shoot")
			#spawn_bullet()
			if ammo >= 1:
				#spawn_bullet()
				ammo -= 1
				
		elif Input.is_action_just_pressed("left_player_block"):
			handle_input(KEY_5)
		elif Input.is_action_just_pressed("left_player_reload"):
			#handle_input(KEY_6)
			#reload anim
			$charactersprite.play("reload")



func handle_input(key):
	input_buffer.append(key)
	if duel:
		if input_buffer == block_legs_sequence:
			emit_signal("pass_up_l", 2) 
			duel = false
			print("block legs")
			
		elif input_buffer == block_sequence:
			emit_signal("pass_up_l", 3)
			duel = false
			print("Blcok")
			
		elif input_buffer == head_sequence:
			emit_signal("pass_up_l", 4)
			duel = false
			print("headshot")
			
		elif input_buffer == body_sequence:
			emit_signal("pass_up_l", 5)
			duel = false
			print("body shot")
			
		elif input_buffer == leg_sequence:
			emit_signal("pass_up_l", 6)
			duel = false
			print("leg shot")
		

signal pass_up_l(data)

#func spawn_bullet():
#	var bullet_instance = bullet_scene.instance()
#	bullet_instance.position = $gunpoint.position
#	add_child(bullet_instance)

