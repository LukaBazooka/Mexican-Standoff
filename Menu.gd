extends Control

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Duel.tscn")

func _on_options_pressed():
	get_tree().change_scene_to_file("res://options_menu.tscn")

func _on_instructions_pressed():
	get_tree().change_scene_to_file("res://Move_List.tscn")


func _on_practice_pressed():
	get_tree().change_scene_to_file("res://left_practice.tscn")


func _on_quit_pressed():
	get_tree().quit()


