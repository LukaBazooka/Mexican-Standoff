extends Node2D

#Instantiate bullet scene
@onready var bullet_scene = load("res://bullet.tscn")

#bullet constants
const BULLET_UP = -1
const BULLET_STRAIGHT = 0
const BULLET_DOWN = 2
const SPEED_Y = 150

#action sequences
#Key0 == draw, Key1 == up, key3== down , key4 == shoot, key5 == block
const HEAD_SEQUENCE = [KEY_0, KEY_1, KEY_4]
const BODY_SEQUENCE = [KEY_0, KEY_4]
const LEG_SEQUENCE = [KEY_0, KEY_3, KEY_4]
const BLOCK_SEQUENCE = [KEY_5]
const BLOCK_LEGS_SEQUENCE = [KEY_3, KEY_5]

var input_buffer = [] #handles user input
var duel = false #if true player inputs can be registered

#determines if block is successful
var body_blocked = false
var leg_blocked = false

#Player counters
var ammo = 5

#bullet physics
var random_y
var random_spin

#executes when scene is loaded
func _ready(): #not used however may be of use later
	pass

#when the time for rest is over and the duel begins
func _rest_timeout():
	duel = true #player can register inputs
	input_buffer.clear() #remove and previous inputs loaded into buffer

#when duel timer ends
func _duel_timeout():
	duel = false #player can no longer register inputs
	emit_signal("pass_up_l", 0) #clear player state in duel scene
	$charactersprite.play("idle")
	
	#resets head area2D so that bullets can be detected
	get_child(2).get_child(2).set_monitoring(true) 
	
	#rests block possibilties
	leg_blocked = false
	body_blocked = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$"../PlayerGUI/LeftPlayerGUI/VBoxContainer/AmmoLabel/AmmoValue".text = str(ammo)
	
	#handle player input
	if duel: #if we are taking player input
		if Input.is_action_just_pressed("left_player_draw"):
			handle_input(KEY_0)
			$charactersprite.play("draw")
		elif Input.is_action_just_pressed("left_player_up"):
			handle_input(KEY_1)
		elif Input.is_action_just_pressed("left_player_down"):
			handle_input(KEY_3)
		elif Input.is_action_just_pressed("left_player_shoot"):
			handle_input(KEY_4)
		elif Input.is_action_just_pressed("left_player_block"):
			handle_input(KEY_5)
		elif Input.is_action_just_pressed("left_player_reload"):
			emit_signal("pass_up_l", 0) #no damage done
			duel = false # stop from executing different states
			ammo += 1
			$charactersprite.play("reload")
			


func handle_input(key):
	input_buffer.append(key)
	#matches input sequence to any action sequences
	#if there is a match pass it to the duel scene, and stop taking player input
	if duel: #if we are taking player input
		if input_buffer == BLOCK_LEGS_SEQUENCE:
			emit_signal("pass_up_l", 3) 
			duel = false
			
		elif input_buffer == BLOCK_SEQUENCE:
			emit_signal("pass_up_l", 2)
			duel = false
			
		elif input_buffer == HEAD_SEQUENCE:
			if ammo > 0:
				emit_signal("pass_up_l", 4)
			duel = false
			
		elif input_buffer == BODY_SEQUENCE:
			if ammo > 0:
				emit_signal("pass_up_l", 5)
			duel = false

		elif input_buffer == LEG_SEQUENCE:
			if ammo > 0:
				emit_signal("pass_up_l", 6)
			duel = false


#excuted on pass down from duel scene
func shoot(state):
	$charactersprite.play("shoot")
	if state == 4: #headshot
		spawn_bullet(BULLET_UP)
		get_child(3).get_child(1).set_disabled(false)
	elif state == 5: #body shot
		spawn_bullet(BULLET_STRAIGHT)
	else: #legshot
		spawn_bullet(BULLET_DOWN)


func spawn_bullet(direction):
	if ammo >= 1:
		#create bullet instance
		var bullet_instance = bullet_scene.instantiate() 
		bullet_instance.position = $gunpoint.position
		add_child(bullet_instance) #add to player scene
		
		#set so that bullet can collide with other bullets
		bullet_instance.linear_velocity.y = SPEED_Y * direction
		ammo -= 1

#upon blocked collison
func rebound(obj):
	randomize()
	random_y = randi_range(-700, 700)
	random_spin = randi_range(-100, 100)
	obj.linear_velocity.x *= -1
	obj.linear_velocity.y += random_y
	obj.angular_velocity = random_spin


#executed once bullet enters body area2d 
func _on_body_collisoion_bullet_entered(area):
	if body_blocked:
		rebound(area.get_parent())
	else:
		#bullet landed on current player
		area.get_parent().queue_free() #delete bullet instance
		#notify duel scnee that body has collided so health can be handled
		emit_signal("lp_bullet_collided")

#executed once passed down from duel scene
#determines which block state and removes possiblity of headshot
func _on_node_2d_lp_block_state(data):
	if data == 2:
		body_blocked = true
	elif data == 3:
		leg_blocked = true
	#regardless of block state headshot cannot occur
	#set head area2d so bullets cannot be detected
	get_child(2).get_child(2).set_monitoring(false)

#executed once bullet enters leg area2d 
func _on_leg_collision_area_entered(area):
	if leg_blocked:
		rebound(area.get_parent())
	else:
		#bullet landed on current player
		area.get_parent().queue_free() #delete bullet instance
		#notify duel scnee that body has collided so health can be handled
		emit_signal("lp_bullet_collided")
		


#executed once bullet entered head area2d
func _on_head_collison_bullet_entered(area):
	#notify duel scnee that body has collided so health can be handled
	emit_signal("lp_bullet_collided")
	area.get_parent().queue_free() #delete bullet instance



signal pass_up_l(data)
signal lp_bullet_collided()

