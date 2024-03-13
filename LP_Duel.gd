extends Node2D

#Instantiated Scenes
@onready var bullet_scene = load("res://bullet.tscn")
@onready var healthbar = $"../GUI/HealthBar"


#USE TO ESTABLISH HEALTH
#healthbar.health = health
const BULLET_UP = -1
const BULLET_STRAIGHT = 0
const BULLET_DOWN = 1
#Key0 == draw, key4 == shoot
var head_sequence = [KEY_0, KEY_1, KEY_4]
var body_sequence = [KEY_0, KEY_2, KEY_4]
var leg_sequence = [KEY_0, KEY_3, KEY_4]

#key5 == block
var block_sequence = [KEY_5, KEY_1]
var block_legs_sequence = [KEY_5, KEY_3]
var input_buffer = []
var duel = false

#Player counters
var ammo = 5
var health = 100

var countdown_value = 3

func _ready():
	pass
	#health = 100
	#healthbar.init_health(health)

func _rest_timeout():
	duel = true
	input_buffer.clear()
	

func _duel_timeout():
	duel = false
	emit_signal("pass_up_l", 0)
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
			emit_signal("pass_up_l", 2) 
			duel = false
			
		elif input_buffer == block_sequence:
			emit_signal("pass_up_l", 3)
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
		get_child(2).get_child(1).set_disabled(false)
		bullet_instance.linear_velocity.y = 200 * direction
		ammo -= 1


