extends AnimatedSprite2D

var anim


func _ready():
	anim  = get_parent().get_animation()
	play(anim)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if anim != get_parent().get_animation():
		anim = get_parent().get_animation()
		play(anim)
	
	

