extends Line2D


var length = 50
var point = Vector2()

func _process(delta):
	global_position = Vector2()
	global_rotation = 0
	
	
	
	point = get_parent().global_position
	while get_point_count() > length:
		remove_point(0)
