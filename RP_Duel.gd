extends Node2D


@onready var bullet_scene = load("res://bullet.tscn")
@onready var duel_scene : Node2D = get_tree().get_first_node_in_group("duel")



#USE TO ESTABLISH HEALTH
#healthbar.health = health

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
const AIM_UP = [KEY_0, KEY_1]
const AIM_DOWN = [KEY_0, KEY_3]
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

#banana chance
var banana_chance 


#executes when scene is loaded
func _ready(): #not used however may be of use later
	pass

#when the time for rest is over and the duel begins
func _rest_timeout():
	duel = true #player can register inputs
	input_buffer.clear() #remove and previous inputs loaded into buffer
	$charactersprite.play("idle")
	
	
#when duel timer ends
func _duel_timeout():
	duel = false #player can no longer register inputs
	
	#resets head area2D so that bullets can be detected
	get_child(2).get_child(2).set_monitoring(true)

	
	#rests block possibilties
	leg_blocked = false
	body_blocked = false

#players animations and actions finsihed
func _action_timeout():
	emit_signal("pass_up_r", 0) #clear player state in duel scene
	$charactersprite.play("rest_anim")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$"../PlayerGUI/RightPlayerGUI/VBoxContainer/AmmoLabel/AmmoValue".text = str(ammo)

	#handle player input
	if duel:
		if Input.is_action_just_pressed("right_player_draw"):
			handle_input(KEY_0)
			$charactersprite.play("draw")
			banana_draw()
		elif Input.is_action_just_pressed("right_player_up"):
			handle_input(KEY_1)
		elif Input.is_action_just_pressed("right_player_down"):
			handle_input(KEY_3)
		elif Input.is_action_just_pressed("right_player_shoot"):
			handle_input(KEY_4)
		elif Input.is_action_just_pressed("right_player_block"):
			handle_input(KEY_5)
		elif Input.is_action_just_pressed("right_player_reload"):
			emit_signal("pass_up_r", 1) #no damage done
			duel = false # stop from executing different states
			if ammo + 1 > 6:
				ammo = 6
			else:
				ammo += 1
			$charactersprite.play("reload")



func handle_input(key):
	input_buffer.append(key)
	#matches input sequence to any action sequences
	#if there is a match pass it to the duel scene, and stop taking player input
	if duel: #if we are taking player input
		if input_buffer == BLOCK_LEGS_SEQUENCE:
			emit_signal("pass_up_r", 3) 
			duel = false

		elif input_buffer == BLOCK_SEQUENCE:
			emit_signal("pass_up_r", 2)
			duel = false

		elif input_buffer == HEAD_SEQUENCE:
			if ammo > 0:
				emit_signal("pass_up_r", 4)
			duel = false

		elif input_buffer == BODY_SEQUENCE:
			if ammo > 0:
				emit_signal("pass_up_r", 5)
			duel = false

		elif input_buffer == LEG_SEQUENCE:
			if ammo > 0:
				emit_signal("pass_up_r", 6)
			duel = false
			
		elif input_buffer == AIM_UP:
			$charactersprite.play("aim_up")
			$gunpoint.position.y -= 60
			
		elif input_buffer == AIM_DOWN:
			$charactersprite.play("aim_down")
			$gunpoint.position.y += 60



func spawn_bullet(direction):
	if ammo >= 1:
		#create bullet instance
		#by default bullet instance will not be able to detect other bullets
		var bullet_instance = bullet_scene.instantiate()
		bullet_instance.position = $gunpoint.position
		bullet_instance.z_index += 5
		add_child(bullet_instance) #add to player scene
		#opposite direction of default velocity
		bullet_instance.linear_velocity.x *= -1
		bullet_instance.linear_velocity.y = SPEED_Y * direction
		ammo -= 1
		if direction ==  BULLET_UP:
			get_child(3).get_child(0).set_rotation_degrees(280)
			
		elif direction == BULLET_DOWN:
			get_child(3).get_child(0).set_rotation_degrees(260)
		

#upon blocked collison
func rebound(obj):
	randomize()
	random_y = randi_range(-700, 700)
	random_spin = randi_range(-100, 100)
	obj.linear_velocity.x *= -1
	obj.linear_velocity.y += random_y
	obj.angular_velocity = random_spin


#executed once passed down from duel scene
#determines which block state and removes possiblity of headshot
func _on_node_2d_rp_block_state(data):
	if data == 2:
		body_blocked = true
		$charactersprite.play("duck_up")
		
	elif data == 3:
		leg_blocked = true
		$charactersprite.play("duck_down")
	get_child(2).get_child(2).set_monitoring(false)
	

#excuted on pass down from duel scene
func shoot(state):
	
	if state == 4: #headshot
		spawn_bullet(BULLET_UP)
		#allows  bullets to collide if both players go for headshots
		get_child(3).get_child(1).set_disabled(false) 
		$charactersprite.play("shoot_up")
	elif state == 5: #bodyshot
		spawn_bullet(BULLET_STRAIGHT)
		$charactersprite.play("shoot")
	elif state == 6: #legshot
		spawn_bullet(BULLET_DOWN)
		$charactersprite.play("shoot_down")
	$gunpoint.position.y = 256

#executed once bullet enters body area2d 
func _on_body_collisoion_area_entered(area):
	emit_signal("rp_bullet_collided")
	if body_blocked:
		rebound(area.get_parent())
	else:
		area.get_parent().queue_free()

#executed once bullet enters leg area2d 
func _on_leg_collision_bullet_entered(area):
	emit_signal("rp_bullet_collided")
	if leg_blocked:
		rebound(area.get_parent())
	else:
		area.get_parent().queue_free()

#executed once bullet entered head area2d
func _on_head_collison_bullet_entered(area):
	emit_signal("rp_bullet_collided")
	area.get_parent().queue_free()

func banana_draw():
	randomize()
	banana_chance = randi_range(1, 30)
	if banana_chance == 1:
		$charactersprite.play("banana_draw")
		duel = false
		if ammo + 2 > 6:
			ammo = 6
		else:
			ammo += 2
		#_update_selection_gui()

signal pass_up_r(data)
signal rp_bullet_collided()
