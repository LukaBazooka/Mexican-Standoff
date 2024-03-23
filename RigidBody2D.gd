extends RigidBody2D



const SPEED = 2000


func _ready():
	gravity_scale = 0
	linear_velocity = Vector2(SPEED, 0)
	

func _on_bullet_timer_timeout():
	queue_free()

# when two bullets slide into eachother
func after_collision_other_bullet(area):
	#if collided with another bullet and both bullets going for headshot
	if linear_velocity.y < 0 and area.get_parent() is RigidBody2D and area.get_parent().linear_velocity.y < 0 : 
		area.set_collision_layer(0)
		$Area2D.set_collision_layer(0)
		


