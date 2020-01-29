extends KinematicBody2D

# Up/Down movement
const MAX_TIME_MOVE = 0.9
const SPEED_MOVE = 25

const FLY_SPEED = 600
var FLY_SPEED_MAX = 600

const DISTANCE_MIN = 5
const DISTANCE_MAX = 50

var velocity = Vector2()

var time_move = 0
var up = false
var check_y = true
var check_x = true
var activated = false
var show = true
signal pet_activated

func _process(delta):
	
	Player.hasPet = false
	
	#Waiting for the girl
	if !activated : 
		$CollisionShape2D_Pet.disabled = true
		up_down(delta)
		waitGirl(Player)
	#Is with the girl
	else: 
		#Is controlled
		if Input.is_key_pressed(KEY_F):
			$CollisionShape2D_Pet.disabled = false
			$Camera2D_Pet.make_current()
			controlled(delta)
			$Sprite.show()
			show = true
			check_y = true
			check_x = true
			velocity = move_and_slide(velocity, Vector2(0, -1))
		
		#Isn't controlled
		else:
			$Camera2D_Pet.clear_current()
			$CollisionShape2D_Pet.disabled = true
			
			#Is moving to the girl
			if show:
				$Sprite.show()
				show = true
				autonomous(Player)
				velocity = move_and_slide(velocity, Vector2(0, -1))
			#Is on the girl's hands
			else:
				Player.hasPet = true
				position = Player.position

func waitGirl(player):
	if player.position.x < position.x + 30 && player.level == 2 && player.world == 1:
		_activate()
	
func controlled(delta):
		
	var walk_left = Input.is_action_pressed("ui_left")
	var walk_right = Input.is_action_pressed("ui_right")
	var walk_up = Input.is_action_pressed("ui_up")
	var walk_down = Input.is_action_pressed("ui_down")
	
	# Don't move X
	var dontMoveX = (walk_right && walk_left) || (!walk_right && !walk_left)
	if dontMoveX:
		velocity.x = 0
		
	# Don't move Y
	var dontMoveY = (walk_down && walk_up) || (!walk_down && !walk_up)
	if dontMoveY:
		up_down(delta)
	
	# Left
	if walk_left:
		velocity.x -= FLY_SPEED
		$Sprite.flip_h = true
		
	# Right
	if walk_right:
		velocity.x += FLY_SPEED
		$Sprite.flip_h = false
		
	# Up
	if walk_up:
		velocity.y -= FLY_SPEED
		
	# Down
	if walk_down:
		velocity.y += FLY_SPEED
		
	checkVelocityX()
	checkVelocityY()

# When the pet just protect the Player
func autonomous(var player):
	var playerPos = Player.position
	var playerLookRight = Player.look_right
	
	if check_y:
		if (position.y - playerPos.y) < DISTANCE_MIN:
			velocity.y = FLY_SPEED
		elif (position.y - playerPos.y) > DISTANCE_MAX:
			velocity.y = -FLY_SPEED
		else:
			position.y = Player.position.y
			check_y = false
	
	# Look right
	if playerLookRight :
		$Sprite.flip_h = false
		# Too far left
		if (position.x - playerPos.x) < DISTANCE_MIN:
			velocity.x = FLY_SPEED
		# Too far right
		elif (position.x - playerPos.x) > DISTANCE_MAX:
			velocity.x = -FLY_SPEED
		# Just good
		else :
			check_x = false
			
	# Look left
	if !playerLookRight:
		$Sprite.flip_h = true
		# Too far left
		if (playerPos.x - position.x) > DISTANCE_MAX:
			velocity.x = FLY_SPEED
		# Too far right
		elif (playerPos.x - position.x) < DISTANCE_MIN:
			velocity.x = -FLY_SPEED
		# Just good
		else :
			check_x = false
	
	if !check_x && !check_y :
		$Sprite.hide()
		velocity.x = 0
		velocity.y = 0
		show = false
	
# Make the up/down constant movement
func up_down(delta):
	time_move += delta
	
	if up:
		velocity.y = SPEED_MOVE
	else:
		velocity.y = -SPEED_MOVE
		
	if time_move >= MAX_TIME_MOVE:
		up = !up
		time_move = 0
	
	velocity = move_and_slide(velocity, Vector2(0, -1))

func checkVelocityX():
	if velocity.x < -FLY_SPEED_MAX:
		velocity.x = -FLY_SPEED_MAX
	elif velocity.x > FLY_SPEED_MAX:
		velocity.x = FLY_SPEED_MAX
	
func checkVelocityY():
	if velocity.y < -FLY_SPEED_MAX:
		velocity.y = -FLY_SPEED_MAX
	elif velocity.y > FLY_SPEED_MAX:
		velocity.y = FLY_SPEED_MAX
		
func _activate():
	activated = true
	$StaticHover.stop()
	emit_signal("pet_activated")
	
func _deactivate():
	activated = false