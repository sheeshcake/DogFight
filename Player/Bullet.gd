extends Area2D

const DAMAGE = 10

var direction = "left"
var velocity = Vector2()


func set_bullet_direction(dir):
	direction = dir


func _physics_process(delta):
	if direction == "left":
		$Sprite.set_flip_h(false)
		velocity.x = -10
	elif direction == "right":
		$Sprite.set_flip_h(true)
		velocity.x = 10
	translate(velocity)



func _on_Bullet_body_entered(body):
	print(body.name)
	if not body.is_a_parent_of(self) &&  str(body.name) != "TileMap":
		body.is_damage(DAMAGE)
		queue_free()
