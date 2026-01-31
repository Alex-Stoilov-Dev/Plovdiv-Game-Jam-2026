extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var can_double_jump = true
var can_dash = false
var jumps = 2

func unlock_ability(ability_name: String):
	if ability_name == "double_jump":
		can_double_jump = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		print(jumps)
  		velocity.y = JUMP_VELOCITY
		if Input.is_action_just_pressed("ui_accept") and not is_on_floor() and jumps > 0:
			velocity.y = JUMP_VELOCITY
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()




func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_node(^"/root/area_mask_1"):
		can_double_jump = true
