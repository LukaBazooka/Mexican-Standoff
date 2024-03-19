extends RigidBody2D



var speed = 1500



func _ready():
	gravity_scale = 0
	linear_velocity = Vector2(speed, 0)
	




func _on_bullet_timer_timeout():
	queue_free()
