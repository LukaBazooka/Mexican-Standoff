extends Sprite2D
var dancing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !dancing:
		dance()

	

func dance():
	dancing = true
	var rep = 10
	
	while rep != 0:
		flip_h = !flip_h
		await get_tree().create_timer(0.2).timeout
		rep -= 1
	await get_tree().create_timer(0.2).timeout
	flip_h = false
	await get_tree().create_timer(0.1).timeout
	flip_h = true
	await get_tree().create_timer(0.1).timeout
	flip_h = false
	await get_tree().create_timer(0.2).timeout
	flip_h = true
	await get_tree().create_timer(0.2).timeout
	flip_h = false
	await get_tree().create_timer(0.2).timeout
	flip_h = true
	await get_tree().create_timer(0.2).timeout
	flip_h = false
	
	await get_tree().create_timer(1).timeout
	dancing = false
