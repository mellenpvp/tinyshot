extends Control
func _ready():
	visible = false
	$main.visible = false
	$network.visible = false
func _process(delta):
	if Input.is_action_just_pressed("menu"):
		if visible == false:
			visible = true
			$main.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		else:
			visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
