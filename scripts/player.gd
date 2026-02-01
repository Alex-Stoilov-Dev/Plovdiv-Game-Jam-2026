extends CharacterBody2D


const SPEED = 120
const JUMP_VELOCITY = -310.0

const DASH_SPEED = 900.0
var dashing = false
var has_dash_ability = false
var can_dash = true
var dash_timer: Timer
var dash_again_timer: Timer

var can_double_jump = false
var jumps = 2;

func _ready():
	dash_timer = Timer.new()
	dash_timer.wait_time = 0.2
	dash_timer.one_shot = true
	dash_timer.timeout.connect(_on_dash_time_timeout)
	add_child(dash_timer)
	
	dash_again_timer = Timer.new()
	dash_again_timer.wait_time = 1.0
	dash_again_timer.one_shot = true
	dash_again_timer.timeout.connect(_on_dash_again_timer_timeout)
	add_child(dash_again_timer)

@onready var animated_sprite = $AnimatedSprite2D
@onready var player = $CharacterBody2D

func _physics_process(delta: float) -> void:
	
	# 1. Add gravity
	if not is_on_floor():
		if not dashing:
			velocity += get_gravity() * delta
			animated_sprite.play("fall")
	else:
		jumps = 2
		
		if Input.is_action_just_pressed("dash") and can_dash and has_dash_ability:
			dashing = true
			can_dash = false
			$dash_timer.start()
			$dash_again_timer.start()
			animated_sprite.play("run")
			
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			# Normal First Jump
			velocity.y = JUMP_VELOCITY
			animated_sprite.play("jump")
			jumps -= 1 
			
		elif jumps > 0 and can_double_jump:
			# Double Jump (in the air)
			animated_sprite.play("double_jump")
			velocity.y = JUMP_VELOCITY
			jumps -= 1

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		if dashing:
			velocity.x = (-1 if animated_sprite.flip_h else 1) * DASH_SPEED
			velocity.y = 0
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if direction > 0:
		animated_sprite.flip_h = false
		animated_sprite.play("run")
	elif direction < 0:
		animated_sprite.flip_h = true
		animated_sprite.play("run")
		
	if direction > 0 and not is_on_floor():
		animated_sprite.flip_h = false
		animated_sprite.play("fall")
	elif direction < 0 and not is_on_floor():
		animated_sprite.flip_h = true
		animated_sprite.play("fall")
	if direction == 0:
		animated_sprite.play("idle")

	if dashing:
		var dash_dir = direction
		if dash_dir == 0:
			dash_dir = -1 if animated_sprite.flip_h else 1
		
		velocity.x = dash_dir * DASH_SPEED
		velocity.y = 0
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _on_area_2d_area_entered(area: Area2D):
	if area.name == "area_mask_1":
		can_double_jump = true;
	if area.name == "area_mask_2":
		can_dash = true;
		has_dash_ability = true;

#make it stop dashing
func _on_dash_time_timeout() -> void:
	dashing = false

func _on_dash_again_timer_timeout() -> void:
	can_dash = true
