extends Node

@export var pipe_scene : PackedScene
@onready var bird: Bird = $Bird
@onready var ground: StaticBody2D = $Ground
@onready var game_over_scene: CanvasLayer = $GameOver

var game_running : bool
var game_over : bool
var scroll
const SCROLL_SPEED : int = 4
var screen_size : Vector2i
var ground_height : int
var pipes : Array
const PIPE_DELAY : int = 100
const PIPE_RANGE : int = 200

func _ready():
	screen_size = get_window().size
	ground_height = ground.get_node("Sprite2D").texture.get_height()
	bird.collision.connect(bird_hit)
	bird.scored.connect(scored)
	new_game()
	
func _process(delta):
	if(game_running):
		check_top()
		scroll_ground()
		move_pipes()
	
	
func _input(event):
	if game_over:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not game_running:
			start_game()
		bird.flap()	
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if bird.flying:
			bird.dive()

func new_game():
	game_running = false
	game_over = false
	GameData.Score = 0
	$ScoreLabel.text = "Score: " + str(GameData.Score)
	scroll = 0
	game_over_scene.hide()
	clear_pipes()
	
	generate_pipes()
	bird.reset()

func start_game():
	game_running = true
	$PipeSpawnTimer.start()

func scroll_ground():
	if game_running:
		scroll += SCROLL_SPEED
	if scroll >= screen_size.x:
		scroll = 0
	$Ground.position.x = -scroll
	
func generate_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = (screen_size.y - ground_height) / 2  + randi_range(-PIPE_RANGE, PIPE_RANGE)
	add_child(pipe)
	pipe.add_to_group("Pipes")
	pipes.append(pipe)
	
func scored():
	GameData.Score += 1
	$ScoreLabel.text = "Score: " + str(GameData.Score)
	
func check_top():
	if bird.position.y < 0:
		stop_game()
	
func stop_game():
	$PipeSpawnTimer.stop()
	game_over_scene.show()
	bird.flying = false
	bird.falling = true
	game_running = false
	game_over = true
	
func move_pipes():
	for pipe in pipes:
		pipe.position.x -= SCROLL_SPEED
	
func bird_hit():
	stop_game()
	
func _on_pipe_spawn_timer_timeout():
	generate_pipes()

func _on_game_over_restart() -> void:
	new_game()

func clear_pipes()-> void:
	get_tree().call_group("Pipes", "queue_free")
	pipes.clear()
