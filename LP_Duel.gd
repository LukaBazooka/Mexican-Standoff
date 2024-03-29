extends Node2D

#Instantiate bullet scene
@onready var bullet_scene = load("res://bullet.tscn")
@onready var duel_scene : Node2D = get_tree().get_first_node_in_group("duel")

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
var input_box1 
var input_box2 
var input_box3

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
	$charactersprite.play("idle")
	duel = true #player can register inputs
	input_buffer.clear() #remove and previous inputs loaded into buffer
	clear_selection_UI() #clear input buffer UI

#when duel timer ends
func _duel_timeout():
	duel = false #player can no longer register inputs
	emit_signal("pass_up_l", 0) #clear player state in duel scene
	
	$charactersprite.play("rest_anim")
	
	if(duel_scene.left_health == 0):
		$charactersprite.play("death")
	
	#resets head area2D so that bullets can be detected
	get_child(2).get_child(2).set_monitoring(true) 
	
	#rests block possibilties
	leg_blocked = false
	body_blocked = false
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$"../PlayerGUI/LeftPlayerGUI/VBoxContainer/AmmoLabel/AmmoValue".text = str(ammo)
	_update_ammo_gui()
	
	#handle player input
	if duel: #if we are taking player input
		if Input.is_action_just_pressed("left_player_draw"):
			handle_input(KEY_0)
			$charactersprite.play("draw")
		elif Input.is_action_just_pressed("left_player_up"):
			handle_input(KEY_1)
			$charactersprite.play("aim_up")
		elif Input.is_action_just_pressed("left_player_down"):
			handle_input(KEY_3)
			$charactersprite.play("aim_down")
		elif Input.is_action_just_pressed("left_player_shoot"):
			handle_input(KEY_4)
		elif Input.is_action_just_pressed("left_player_block"):
			handle_input(KEY_5)
		elif Input.is_action_just_pressed("left_player_reload"):
			emit_signal("pass_up_l", 0) #no damage done
			duel = false # stop from executing different states
			ammo += 1
			$charactersprite.play("reload")
			
	_update_selection_gui()


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
	
	if state == 4: #headshot
		spawn_bullet(BULLET_UP)
		get_child(3).get_child(1).set_disabled(false)
		$charactersprite.play("shoot_up")
	elif state == 5: #body shot
		spawn_bullet(BULLET_STRAIGHT)
		$charactersprite.play("shoot")
	else: #legshot
		spawn_bullet(BULLET_DOWN)
		$charactersprite.play("shoot_down")


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

func _update_ammo_gui():
	if ammo == 0:
		$"../PlayerGUI/left_Bullet1/BulletSprite".animation = "emptybullet"
		$"../PlayerGUI/left_Bullet2/BulletSprite".animation = "emptybullet"
		$"../PlayerGUI/left_Bullet3/BulletSprite".animation = "emptybullet"
		$"../PlayerGUI/left_Bullet4/BulletSprite".animation = "emptybullet"
		$"../PlayerGUI/left_Bullet5/BulletSprite".animation = "emptybullet"
		$"../PlayerGUI/left_Bullet6/BulletSprite".animation = "emptybullet"
	elif ammo == 1:
		$"../PlayerGUI/left_Bullet1/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet2/BulletSprite".animation = "emptybullet"
		$"../PlayerGUI/left_Bullet3/BulletSprite".animation = "emptybullet"
		$"../PlayerGUI/left_Bullet4/BulletSprite".animation = "emptybullet"
		$"../PlayerGUI/left_Bullet5/BulletSprite".animation = "emptybullet"
		$"../PlayerGUI/left_Bullet6/BulletSprite".animation = "emptybullet"
	elif ammo == 2:
		$"../PlayerGUI/left_Bullet1/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet2/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet3/BulletSprite".animation = "emptybullet"
		$"../PlayerGUI/left_Bullet4/BulletSprite".animation = "emptybullet"
		$"../PlayerGUI/left_Bullet5/BulletSprite".animation = "emptybullet"
		$"../PlayerGUI/left_Bullet6/BulletSprite".animation = "emptybullet"
	elif ammo == 3:
		$"../PlayerGUI/left_Bullet1/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet2/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet3/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet4/BulletSprite".animation = "emptybullet"
		$"../PlayerGUI/left_Bullet5/BulletSprite".animation = "emptybullet"
		$"../PlayerGUI/left_Bullet6/BulletSprite".animation = "emptybullet"
	elif ammo == 4:
		$"../PlayerGUI/left_Bullet1/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet2/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet3/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet4/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet5/BulletSprite".animation = "emptybullet"
		$"../PlayerGUI/left_Bullet6/BulletSprite".animation = "emptybullet"
	elif ammo == 5:
		$"../PlayerGUI/left_Bullet1/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet2/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet3/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet4/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet5/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet6/BulletSprite".animation = "emptybullet"
	elif ammo == 6:
		$"../PlayerGUI/left_Bullet1/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet2/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet3/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet4/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet5/BulletSprite".animation = "bullet"
		$"../PlayerGUI/left_Bullet6/BulletSprite".animation = "bullet"

#Key0 == draw, Key1 == up, key3== down , key4 == shoot, key5 == block
func _update_selection_gui():
	if len(input_buffer) == 1:
		if input_buffer[0] == KEY_0:
			input_box1 = $"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox1/CAPS"
			$"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox1/CAPS".visible = true
		elif input_buffer[0] == KEY_1:
			input_box1 = $"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox1/W"
			$"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox1/W".visible = true
		elif input_buffer[0] == KEY_3:
			input_box1 =  $"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox1/S"
			$"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox1/S".visible = true
		elif input_buffer[0] == KEY_4:
			input_box1 = $"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox1/E"
			$"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox1/E".visible = true
		elif input_buffer[0] == KEY_5:
			input_box1 = $"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox1/D"
			$"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox1/D".visible = true
	elif len(input_buffer) == 2:
		if input_buffer[1] == KEY_0:
			input_box2 = $"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox2/CAPS"
			$"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox2/CAPS".visible = true
		elif input_buffer[1] == KEY_1:
			input_box2 = $"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox2/W"
			$"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox2/W".visible = true
		elif input_buffer[1] == KEY_3:
			input_box2 = $"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox2/S"
			$"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox2/S".visible = true
		elif input_buffer[1] == KEY_4:
			input_box2 = $"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox2/E"
			$"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox2/E".visible = true
		elif input_buffer[1] == KEY_5:
			input_box2 = $"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox2/D"
			$"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox2/D".visible = true
	elif len(input_buffer) == 3:
		if input_buffer[2] == KEY_0:
			input_box3 = $"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox3/CAPS"
			$"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox3/CAPS".visible = true
		elif input_buffer[2] == KEY_1:
			input_box3 = $"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox3/W"
			$"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox3/W".visible = true
		elif input_buffer[2] == KEY_3:
			input_box3 = $"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox3/S"
			$"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox3/S".visible = true
		elif input_buffer[2] == KEY_4:
			input_box3 = $"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox3/E"
			$"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox3/E".visible = true
		elif input_buffer[2] == KEY_5:
			input_box3 = $"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox3/D"
			$"../PlayerGUI/LeftPlayerGUI/HBoxContainer/emptybox3/D".visible = true
	
	
func clear_selection_UI():
	if input_box1 != null:
		input_box1.visible = false
	if input_box2 != null:
		input_box2.visible = false
	if input_box3 != null:
		input_box3.visible = false

signal pass_up_l(data)
signal lp_bullet_collided()



