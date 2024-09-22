extends Node

#Preloads Obstacles
var Bullet_Scene = preload('res://Cenes/bullet.tscn')
var Trap_Scene = preload('res://Cenes/trap.tscn') 
var Rock_Scene = preload('res://Cenes/rock.tscn')
var obstacle_types := [Rock_Scene, Trap_Scene]
var obstacles : Array
var Bullet_hights := [200,390]
 
# Game variables
#High score
var high_score : int
# Start Pos
const RHINO_START_POS := Vector2i(350,485)
const CAM_START_POS := Vector2i(576,324)
# Score
var score : int
const SCORE_MODIFIER : int = 15
# Speed
var speed : float
const START_SPEED : float = 1.0 
const MAX_SPEED : int = 6
const SPEED_MODIFIER : int = 5000
#Size
var screen_size : Vector2i
var ground_height : int
#Running
var game_running : bool
#Obstacles 
var last_obs
#Difficulty 
var difficulty
const MAX_DIFFICULTY : int = 2


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_Game) 
	new_Game()

func new_Game():
#reset variables
	#Starting varibles
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	
 	#delete all obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
#reset the nodes
	$Rhino.position = RHINO_START_POS
	$Rhino.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	
	#reset hud and game over screen
	$HUD.get_node("StartLabel").show()
	$GameOver.hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	if game_running:
		speed = START_SPEED + score / SCORE_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficlty()
		
		#generates obstacles
		generate_obs()
		
		#moves Rhino and camera
		$Rhino.position.x += speed
		$Camera2D.position.x += speed
		
		#update score
		score += speed
		show_score()
		
		#update ground position
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
		
		#remove obstacles that have gone off screen
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
				
	else: #if "ui_accept" is pressed hide the start lable.
		if Input.is_action_pressed("ui_accept"): 
			game_running = true
			$HUD.get_node("StartLabel").hide() 


func generate_obs():
	#generates the ground obstacles
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(200, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1 
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 260) + 10
			last_obs = obs
			add_obs(obs, obs_x, obs_y)

	#additionally random chance to spawn a bullet
	
		if difficulty ==  MAX_DIFFICULTY:
			if (randi() % 2 ) == 0:

				#generate bullet obstacles

				obs = Bullet_Scene.instantiate()
				var obs_x : int = screen_size.x + score + 100
				var obs_y : int = Bullet_hights[randi() % Bullet_hights.size()]
				add_obs(obs, obs_x, obs_y)

func add_obs(obs ,x ,y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

#Removes the obstacles after it passed and went of screen

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

#If the rhino hits the obstacle it goes to the game over screen.

func  hit_obs(body):
	if body.name == "Rhino":
		game_over()

#Showes the score

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)

#Checks for the high score

func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIER)

# Adjust the difficlty

func adjust_difficlty():
	difficulty= score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

#Game_over screen
 
func game_over():
	check_high_score() 
	get_tree().paused = true
	game_running = false
	$GameOver.show()
