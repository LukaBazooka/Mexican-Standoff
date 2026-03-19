#class_name ControlsMenu
extends Control

#@onready var play_button: Button = $Panel/Play

#func _ready() -> void:
	#play_button.pressed.connect(_on_play_pressed)

#func _on_play_pressed() -> void:
	#get_tree().change_scene_to_file("res://Duel.tscn")
