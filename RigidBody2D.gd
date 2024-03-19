extends RigidBody2D



const SPEED = 1500


func _ready():
	gravity_scale = 0
	linear_velocity = Vector2(SPEED, 0)
	

func _on_bullet_timer_timeout():
	queue_free()


func after_collision_other_bullet(area):
	#make sure area is bullet and we are going for a headshot
	if linear_velocity.y < 0 and area.get_parent() is RigidBody2D: 
		area.set_collision_layer(0)
		$Area2D.set_collision_layer(0)
		


