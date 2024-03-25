extends ProgressBar

@onready var duel_scene : Node2D = get_tree().get_first_node_in_group("duel")


func _ready():
	pass
	
func _process(delta):
		value = duel_scene.rest_time
		
		if duel_scene.rest_time == 0:
			self.visible = false
		else:
			self.visible = true

	


