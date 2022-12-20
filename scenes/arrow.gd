extends CharacterBody3D
var speed = -10000
var timer = 0
func _process(delta):
	timer += delta
	velocity = Vector3(0,-timer,speed)
	move_and_collide(velocity)
	#translate_object_local(Vector3.FORWARD * speed * delta + Vector3.DOWN * 9.8 * timer)
	if timer > 2:
		queue_free()
#func _on_Bullet_body_entered(body):
	#if body.is_in_group("Box"):
	#	body.damage(5)
	#	queue_free()
