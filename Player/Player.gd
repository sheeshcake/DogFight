extends KinematicBody2D

const BULLET = preload("res://Player/Bullet.tscn")
const GUI = preload("res://Player/GUI/MobileControls.tscn")



var direction = "left"
var status = "idle"
var is_sprite_flipped = false
var is_dead = false
var velocity = Vector2()
var on_ground = false
var landing_pos = Vector2()

slave func setPosition(pos,dir,tar_pos):
	position = pos
	direction = dir
	self.get_node("Target").position = tar_pos
	if direction == "left":
		$Sprite.set_flip_h(true)
	if direction == "right":
		$Animation.set_flip_h(false)
	if $HealthBar.value <= 0:
		self.hide()

sync func is_damage(damage):
	$HealthBar.value -= damage
	check_if_dead(is_dead)

sync func is_shooting(stat):
	if stat == "shoot":
		var bullet = BULLET.instance()
		bullet.set_bullet_direction(direction)
		get_parent().add_child(bullet)
		bullet.position = $Target.global_position

func check_if_dead(val):
	if val:
		$Animation.play("dead")
		$Label2.text = "U DEAD VOVO!!!!"
		$Rematch.show()
		self.hide()

master func shutItDown():
  #Send a shutdown command to all connected clients, including this one
	rpc("shutDown")
  
sync func shutDown():
	get_tree().quit()

func set_label_name(name):
	$NickName.set_text(name)
  

func _physics_process(delta):
	update()
	var moveByX = 0
	var moveByY = 0
	if(is_network_master()) && !$HealthBar.value <= 0:
		$Animation.play("idle")
		if Input.is_action_pressed("ui_left"):
			moveByX = -5
			velocity.x = -100
			direction = "left"
			$Animation.set_flip_h(true)
			if is_sprite_flipped == true:
				$Target.position.x *= -1
				is_sprite_flipped = false
			
		if Input.is_action_pressed("ui_right"):
			moveByX = 5
			velocity.x = 100
			direction = "right"
			$Animation.set_flip_h(false)
			if is_sprite_flipped == false:
				$Target.position.x *= -1
				is_sprite_flipped = true
		
		if Input.is_action_pressed("ui_up"):
			moveByY = -5
			velocity.y = -100
		
		if Input.is_action_pressed("ui_down"):
			moveByY = 5
			velocity.y = 100
		
		if Input.is_key_pressed(KEY_Q):
			shutItDown()
		
		if Input.is_action_just_pressed("ui_shoot"):
			status = "shoot"
			$Animation.play("shooting")
		rpc_unreliable("setPosition",Vector2(position.x - moveByX, position.y),direction,$Target.position)
		rpc_unreliable("is_shooting",status)
		status = "idle"
		
	if self.is_on_floor():
		landing_pos = position
		on_ground = true
	
	
	if !on_ground && landing_pos.distance_to(position) <= 300:
		velocity.y = 0
		on_ground = false
	if $HealthBar.value <= 0:
		$Label2.text = "U DEAD VOVO!!!!"
		$Animation.hide()
	velocity = move_and_slide(velocity)
	#translate(Vector2(moveByX,moveByY))



func set_this_camera(cam):
	if cam:
		if globals.player_type == "Host":
			#$Target.position *= -1
			is_sprite_flipped = true
		var gui = GUI.instance()
		add_child(gui)
		$Camera2D.make_current()
	else:
		$Target.position.x *= -1
		$HealthBar.hide()
		$Label.hide()



func _on_Player_draw():
	draw_circle($Target.position, 10, Color(0,1,0))

