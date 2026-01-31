extends CharacterBody2D


const SPEED = 100
const JUMP_VELOCITY = -300.0

var can_double_jump = false
var can_dash = true  
var jumps = 2;

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	
	# 1. Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jumps = 2

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			# Normal First Jump
			velocity.y = JUMP_VELOCITY
			jumps -= 1 
		elif jumps > 0 and can_double_jump:
			# Double Jump (in the air)
			velocity.y = JUMP_VELOCITY
			jumps -= 1
			print("Double jumped! Jumps left: ", jumps)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	move_and_slide()


func _on_area_2d_area_entered(area: Area2D):
	if area.name == "area_mask_1":
		can_double_jump = true;
