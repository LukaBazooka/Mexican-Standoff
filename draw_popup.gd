extends Control

@onready var _draw_sound: AudioStreamPlayer2D = $Draw
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _notification(notification: int) -> void:
	if notification == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree():
		_draw_sound.play()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
