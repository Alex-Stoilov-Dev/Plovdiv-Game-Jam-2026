extends Node2D

@onready var character = %AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	# Проверяваме дали човечето съществува
	if character:
		character.flip_h = true
		character.play("idel") 
		character.z_index = 10 
		character.global_position = Vector2(1485, 505)
	
	# Излизане от играта с ESC
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
