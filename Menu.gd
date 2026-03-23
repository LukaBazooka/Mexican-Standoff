extends Control


@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

const MUZZLE_FLASH_DURATION: float = 0.1
@onready var muzzle_flash: Sprite2D = $MuzzleFlash
var muzzle_flash_time_left: float = 0.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	set_process(true)
	muzzle_flash.centered = true
	muzzle_flash.visible = false

func _process(delta: float) -> void:
	muzzle_flash.position = get_local_mouse_position()
	if muzzle_flash_time_left > 0.0:
		muzzle_flash_time_left -= delta
		if muzzle_flash_time_left <= 0.0:
			muzzle_flash_time_left = 0.0
			muzzle_flash.visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			sound.play()
			muzzle_flash.visible = true
			muzzle_flash_time_left = MUZZLE_FLASH_DURATION

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://game_rules.tscn")
	#get_tree().change_scene_to_file("res://Duel.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://options_menu.tscn")

func _on_instructions_pressed() -> void:
	get_tree().change_scene_to_file("res://Move_List.tscn")

func _on_practice_pressed() -> void:
	get_tree().change_scene_to_file("res://left_practice.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
