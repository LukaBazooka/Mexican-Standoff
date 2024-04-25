extends Line2D
class_name Trails



var queue : Array
var pos
var init_pos
@export var MAX_LENGTH : int


func _ready():
	init_pos = get_parent().position
	pos = Vector2(0, 0)
	queue.push_front(pos)
	
func _process(_delta):
	pos = _get_position() - init_pos

	#print("trail function: ", pos)

	queue.push_front(pos)
	
	#pos
	
	 
	
	if queue.size() > MAX_LENGTH:
		queue.pop_back()
	
	clear_points()
	
	for point in queue:
		add_point(point)
	for i in range(len(queue)):
		pass

func _get_position():
	return get_parent().global_position
