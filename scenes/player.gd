extends CharacterBody2D


const SPEED = 100
const JUMP_VELOCITY = -300.0
const DASH_SPEED = 400

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
	if Input.is_key_pressed(KEY_K) and can_dash:
		if Input.is_key_pressed(KEY_A):
			velocity.x = DASH_SPEED;
			#velocity.x = move_toward(velocity.x, 0, SPEED)

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
	if area.name == "area_mask_2":
		can_dash = true;
