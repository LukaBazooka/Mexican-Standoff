extends Node2D

#Instantiated Scenes
@onready var bullet_scene = load("res://bullet.tscn")

#USE TO ESTABLISH HEALTH
#healthbar.health = health
const BULLET_UP = -1
const BULLET_STRAIGHT = 0
const BULLET_DOWN = 2
#Key0 == draw, key4 == shoot
var head_sequence = [KEY_0, KEY_1, KEY_4]
var body_sequence = [KEY_0, KEY_4]
var leg_sequence = [KEY_0, KEY_3, KEY_4]

#key5 == block
var block_sequence = [KEY_5]
var block_legs_sequence = [KEY_3, KEY_5]
var input_buffer = []
var duel = false
var body_blocked = false
var leg_blocked = false

#Player counters
var ammo = 5
var health = 100
var random_y
var random_spin

var countdown_value = 3

func _ready():
	pass
	

func _rest_timeout():
	duel = true
	input_buffer.clear()
	

func _duel_timeout():
	duel = false
	emit_signal("pass_up_l", 0)
	# idle anim
	$charactersprite.play("idle")
	get_child(2).get_child(2).set_monitoring(true)
	leg_blocked = false
	body_blocked = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$"../PlayerGUI/LeftPlayerGUI/VBoxContainer/AmmoLabel/AmmoValue".text = str(ammo)
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
			#$charactersprite.play("shoot")
			#spawn_bullet()
				
		elif Input.is_action_just_pressed("left_player_block"):
			handle_input(KEY_5)
		elif Input.is_action_just_pressed("left_player_reload"):
			emit_signal("pass_up_l", 0) #no damage done
			duel = false # stop from executing different states
			ammo += 1
			$charactersprite.play("reload")
			


func handle_input(key):
	input_buffer.append(key)
	if duel:
		if input_buffer == block_legs_sequence:
			emit_signal("pass_up_l", 3) 
			duel = false
			print("block legs")
			
		elif input_buffer == block_sequence:
			emit_signal("pass_up_l", 2)
			duel = false
			
		elif input_buffer == head_sequence:
			emit_signal("pass_up_l", 4)
			duel = false
			$charactersprite.play("shoot")
			spawn_bullet(BULLET_UP)
			
		elif input_buffer == body_sequence:
			emit_signal("pass_up_l", 5)
			duel = false
			$charactersprite.play("shoot")
			spawn_bullet(BULLET_STRAIGHT)
		
			
		elif input_buffer == leg_sequence:
			emit_signal("pass_up_l", 6)
			duel = false
			$charactersprite.play("shoot")
			spawn_bullet(BULLET_DOWN)
			

		

signal pass_up_l(data)



func spawn_bullet(direction):
	if ammo >= 1:
		var bullet_instance = bullet_scene.instantiate()
		bullet_instance.position = $gunpoint.position
		add_child(bullet_instance)
		get_child(3).get_child(1).set_disabled(false)
		bullet_instance.linear_velocity.y = 200 * direction
		ammo -= 1


func rebound(obj):
	randomize()
	random_y = randi_range(-700, 700)
	random_spin = randi_range(-100, 100)
	obj.linear_velocity.x *= -1
	obj.linear_velocity.y += random_y
	obj.angular_velocity = random_spin



func _on_body_collisoion_bullet_entered(area):
	if body_blocked:
		rebound(area.get_parent())
	else:
		area.get_parent().queue_free()



func _on_node_2d_lp_block_state(data):
	if data == 2:
		body_blocked = true
	elif data == 3:
		leg_blocked = true
	get_child(2).get_child(2).set_monitoring(false)


func _on_leg_collision_area_entered(area):
	if leg_blocked:
		rebound(area.get_parent())
	else:
		area.get_parent().queue_free()
		


# simulate impact for head
func _on_head_collison_bullet_entered(area):

	area.get_parent().queue_free()

