extends Area2D

@onready var timer = $Timer

func _on_body_entered(_body):
	# Изтрихме reload_current_scene()
	# Сега този скрипт не прави нищо и оставя Player.gd да се погрижи за смъртта
	pass
