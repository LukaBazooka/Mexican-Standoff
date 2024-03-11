extends RigidBody2D

var speed = 1600

func _ready():
	gravity_scale = 0
	linear_velocity = Vector2(speed, 0)
