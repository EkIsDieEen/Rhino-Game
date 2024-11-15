extends CharacterBody2D

const GRAVITY : int = 4200
const JUMP_SPEED : int = -1600 (((I cahnged the jump speed so that the rhino jumps higher increasing the odds that the rhino will hit the bullet)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("Idle") # Tells the code to play the idle animation
		else:
			$RunCol.disabled = false
			if Input.is_action_pressed("Jump"): # jump = spacebar, up key or w
				velocity.y = JUMP_SPEED
				$JumpSound.play()
			elif Input.is_action_pressed("Duck"): # duck = down key or s
				$AnimatedSprite2D.play("Duck") # Tells the code to play the Duck animation
				$RunCol.disabled = true
			else:
				$AnimatedSprite2D.play("Run") # Tells the code to play the Run animation
	else:
		$AnimatedSprite2D.play("Jump") # Tells the code to play the Jump animation
		
	move_and_slide()
