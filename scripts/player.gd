extends CharacterBody2D

const SPEED = 150
const JUMP_VELOCITY = -320.0
const DASH_SPEED = 400

var can_dash = false
var mask_acquired_1 = false
var mask_acquired_2 = false
var dash_duration = 0.2
var dashing = false
var jump_count = 2

enum STATE{
	IDLE,
	MOVING,
	JUMPING,
	FALLING,
	DASHING,
	SECOND_JUMP
}

enum FACING{
	LEFT = -1,
	RIGHT = 1
}

var active_state = STATE.IDLE

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	
	var direction := Input.get_axis("move_left","move_right")

	match active_state:
		STATE.IDLE:
			if Input.is_action_just_pressed("jump"):
				change_state(STATE.JUMPING)
				
			if direction:
				change_state(STATE.MOVING)
				
			if not is_on_floor():
				change_state(STATE.FALLING)
			
			if Input.is_action_just_pressed("dash") and can_dash:
				change_state(STATE.DASHING)
			
		STATE.MOVING:
			velocity.x = direction * SPEED
			if direction:
				animated_sprite.flip_h = direction < 0
				
			if not is_on_floor():
				change_state(STATE.FALLING)
				
			if direction == 0 and not is_on_floor() and jump_count < 1:
				change_state(STATE.FALLING)
				
			if direction == 0 and not is_on_floor() and jump_count > 1:
				if Input.is_action_just_pressed("jump"):
					change_state(STATE.SECOND_JUMP)
			if direction == 0 and is_on_floor():
				change_state(STATE.IDLE)
				
			if Input.is_action_just_pressed("jump"):
				change_state(STATE.JUMPING)
				
			if Input.is_action_just_pressed("dash") and can_dash:
				change_state(STATE.DASHING)
			
		STATE.JUMPING:
			velocity.x = direction * SPEED
			velocity += get_gravity() * delta

			if direction:
				animated_sprite.flip_h = direction < 0

			if Input.is_action_just_pressed("dash") and can_dash:
				change_state(STATE.DASHING)
			
			if Input.is_action_just_released("jump") or velocity.y >= 0:
				if mask_acquired_1:
					if Input.is_action_just_pressed("jump"):
						change_state(STATE.SECOND_JUMP)
					else:
						velocity.y = 0
						change_state(STATE.FALLING)
				else:
					velocity.y = 0
					change_state(STATE.FALLING)
			
		STATE.FALLING:
			velocity.x = direction * SPEED
			velocity += get_gravity() * delta
			
			if direction:
				animated_sprite.flip_h = direction < 0

			if is_on_floor():
				change_state(STATE.IDLE)
			
			if Input.is_action_just_pressed("dash") and can_dash:
				change_state(STATE.DASHING)
			if Input.is_action_just_pressed("jump") and jump_count >= 1:
				change_state(STATE.SECOND_JUMP)

		STATE.DASHING:
			velocity.y = 0
			if direction < 0:
				velocity.x = DASH_SPEED * FACING.LEFT
			else:
				velocity.x = DASH_SPEED * FACING.RIGHT
				
			if direction == 0: # If we go from idle to dash state we dash in the direction we are facing in idle 
				if animated_sprite.flip_h == true: # animated_sprite.flip_h returns true if we face left
					velocity.x = DASH_SPEED * FACING.LEFT
				else:
					velocity.x = DASH_SPEED * FACING.RIGHT
			dash_duration -= delta
			
			if dash_duration <= 0: dashing = false
			
			if dashing == false and not is_on_floor():
				change_state(STATE.FALLING)
			if dashing == false and is_on_floor(): 
				velocity.x = 0
				change_state(STATE.IDLE)
		STATE.SECOND_JUMP:
			velocity.x = direction * SPEED
			velocity += get_gravity() * delta

			if direction:
				animated_sprite.flip_h = direction < 0

			if Input.is_action_just_pressed("dash") and can_dash:
				change_state(STATE.DASHING)
			
			if Input.is_action_just_released("jump") or velocity.y >= 0:
				velocity.y = 0
				change_state(STATE.FALLING)
			
			if is_on_floor():
				change_state(STATE.IDLE)

	move_and_slide()

func change_state(to_state: STATE):
	active_state = to_state
	
	match active_state:
		STATE.IDLE:
			if mask_acquired_1:
				jump_count = 2
			else:
				jump_count = 1
			if mask_acquired_2:
				can_dash = true
			animated_sprite.play("idle")
			
		STATE.JUMPING:
			jump_count -= 1
			animated_sprite.play("jump")
			velocity.y = JUMP_VELOCITY
		
		STATE.MOVING:
			if mask_acquired_1:
				jump_count = 2
			else:
				jump_count = 1
			animated_sprite.play("run")
		
		STATE.FALLING:
			animated_sprite.play("fall")
		
		STATE.DASHING:
			animated_sprite.play("dash")
			dash_duration = 0.2
			dashing = true
			can_dash = false
		
		STATE.SECOND_JUMP:
			jump_count -= 1
			animated_sprite.play("double_jump")
			velocity.y = JUMP_VELOCITY

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "area_mask_1": 
		mask_acquired_1 = true
	if area.name == "area_mask_2": mask_acquired_2 = true
