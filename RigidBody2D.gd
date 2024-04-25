extends RigidBody2D



const SPEED = 1500
var prev_global_position = Vector2() 
var line_points := []  

func _ready():
	gravity_scale = 0
	linear_velocity = Vector2(SPEED, 0)
	
	prev_global_position = global_position  # Initialize the previous position
	queue_redraw()  # Ensure that _draw is called
	

func _on_bullet_timer_timeout():
	queue_free()

# when two bullets slide into eachother
func after_collision_other_bullet(area):
	#if collided with another bullet and both bullets going for headshot
	if linear_velocity.y < 0 and area.get_parent() is RigidBody2D and area.get_parent().linear_velocity.y < 0 : 
		area.set_collision_layer(0)
		$Area2D.set_collision_layer(0)
		



func _integrate_forces(state):

	var current_global_position = global_position
	if prev_global_position.distance_to(current_global_position) > 1:
		# Only store points if there's a significant change in position
		line_points.append(prev_global_position)
		line_points.append(current_global_position)
		prev_global_position = current_global_position  # Update for the next frame
		if line_points.size() > 2:
			# Remove the oldest segment to keep the trail a fixed length
			line_points.pop_front()
			line_points.pop_front()
		queue_redraw()  # Queue redraw to update the drawing

func _draw():
	for i in range(0, line_points.size(), 2):
		# Draw all segments of the trail
		print(line_points)
		draw_line(line_points[i], line_points[i + 1], Color(1, 0, 0), 2)
