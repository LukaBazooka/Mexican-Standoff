extends Control

@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var muzzle_flash: Sprite2D = $MuzzleFlash

func _ready() -> void:
	set_process(true)
	muzzle_flash.centered = true

func _process(delta: float) -> void:
	muzzle_flash.position = get_local_mouse_position()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			sound.play()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Duel.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://options_menu.tscn")

func _on_instructions_pressed() -> void:
	get_tree().change_scene_to_file("res://Move_List.tscn")

func _on_practice_pressed() -> void:
	get_tree().change_scene_to_file("res://left_practice.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
