extends CollisionShape2D

func _on_area_mask_2_body_entered(body: Node2D) -> void:
	print(self.name)
	queue_free()
