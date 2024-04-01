extends Control

#BUTTONS SCRIPT!

func _on_back_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")

func _on_game_rules_pressed():
	get_tree().change_scene_to_file("res://game_rules.tscn")
