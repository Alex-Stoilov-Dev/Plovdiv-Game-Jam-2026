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
var jumps = 2
var is_dead = false 

@onready var animated_sprite = $AnimatedSprite2D
@onready var death_label = $CanvasLayer/DeathLabel 
@onready var camera = $Camera2D # Референция към твоята камера

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Конфигурация на таймерите
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
	
	if death_label:
		death_label.visible = false

func _physics_process(delta: float) -> void:
	if is_dead:
		# Спираме физиката напълно, за да не пада под мапа
		velocity = Vector2.ZERO
		return

	if not is_on_floor():
		if not dashing:
			velocity += get_gravity() * delta
	else:
		jumps = 2 

	# АВТОМАТИЧНА ПРОВЕРКА ЗА ПАДАНЕ В ДУПКА (ако няма FallZone)
	if position.y > 1500: # Ако падне твърде ниско
		die()

	# DASH ЛОГИКА
	var dash_pressed = Input.is_action_just_pressed("dash") or Input.is_key_pressed(KEY_SHIFT)
	if dash_pressed and can_dash and has_dash_ability:
		dashing = true
		can_dash = false
		dash_timer.start()
		dash_again_timer.start()

	# JUMP ЛОГИКА
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			animated_sprite.play("jump")
			jumps -= 1 
		elif jumps > 0 and can_double_jump:
			velocity.y = JUMP_VELOCITY
			animated_sprite.play("double_jump")
			jumps -= 1

	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if dashing:
		var dash_dir = -1 if animated_sprite.flip_h else 1
		velocity.x = dash_dir * DASH_SPEED
		velocity.y = 0
	else:
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		_update_animations(direction)

	move_and_slide()

func _update_animations(direction):
	if is_on_floor():
		if direction != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")
	else:
		if velocity.y > 0:
			animated_sprite.play("fall")

@warning_ignore("return_value_discarded")
	
func _input(event):
	if is_dead and get_tree().paused:
		if (event is InputEventMouseButton and event.pressed) or event.is_action_pressed("ui_accept"):
			get_tree().paused = false 
			get_tree().reload_current_scene()

func apply_shake():
	if camera:
		for i in range(10):
			camera.offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
			await get_tree().create_timer(0.02, true, false, true).timeout
		camera.offset = Vector2.ZERO

func die():
	if is_dead: return
	is_dead = true
	
	# СПИРАМЕ ГЕРОЯ ВЕДНАГА
	velocity = Vector2.ZERO
	
	apply_shake()
	
	# Анимация на завъртане
	var tween = create_tween()
	tween.tween_property(animated_sprite, "rotation", deg_to_rad(90), 0.2)
	
	# Малко изчакване преди паузата
	await get_tree().create_timer(0.3, true, false, true).timeout
	
	if death_label:
		death_label.text = "U DIE\nClick to Restart"
		death_label.show() 
	
	get_tree().paused = true

func _on_area_2d_area_entered(area: Area2D):
	if area.name == "area_mask_1":
		can_double_jump = true
	if area.name == "area_mask_2":
		has_dash_ability = true
		can_dash = true

	# Подобрена проверка за смърт
	var area_name = area.name.to_lower()
	if area_name.contains("spikes") or area_name.contains("killerzone") or area_name.contains("fallzone") or area.name == "Area2D":
		die()
		
	if area.name == "Portal":
		# Провери дали името на сцената за левел 2 е точно такова
		get_tree().change_scene_to_file("res://scenes/level_2.tscn")

func _on_dash_time_timeout() -> void:
	dashing = false

func _on_dash_again_timer_timeout() -> void:
	can_dash = true
