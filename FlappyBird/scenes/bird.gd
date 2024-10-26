class_name Bird

extends CharacterBody2D
signal collision
signal scored

var gravity : int = PhysicsData.Gravity
var max_fall_speed : int = PhysicsData.Terminal_Velocity

const Dive_Speed: int = 400
const Flap_Strength: float = -300.0
const Max_Upward_Velocity: float = -700.0
var flying : bool = false
var falling : bool = false
const Start_position = Vector2(100, 400)

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready():
	reset()
	
func reset():
	falling = false
	flying = false
	position = Start_position
	set_rotation(0)

# Se llama todos los frames, delta es el tiempo desde el frame anterior
func _physics_process(delta):
	if flying or falling:
		velocity.y += gravity * delta
		
		if velocity.y > max_fall_speed:
			velocity.y = max_fall_speed
		if flying:
			set_rotation(deg_to_rad(velocity.y * 0.05))
			$AnimatedSprite2D.play()
		elif falling:
			set_rotation(PI/2)
			$AnimatedSprite2D.stop()
		move_and_collide(velocity * delta)
	else:
		$AnimatedSprite2D.stop()
		
func flap():
	velocity.y += Flap_Strength * (1.0 + clamp(velocity.y / max_fall_speed, 0.0, 1.0))

	if velocity.y < Max_Upward_Velocity:
		velocity.y = Max_Upward_Velocity

	flying = true

func dive():
	velocity.y = Dive_Speed  
	falling = true  


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Collision"):
		collision.emit()
	elif area.is_in_group("Score"):
		scored.emit()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Collision"):
		collision.emit()
