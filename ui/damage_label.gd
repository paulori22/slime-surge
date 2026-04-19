extends Label

func set_damage(value: int):
	text = str(value)
	
	var tween = create_tween().set_parallel(true)
	
	# Use TRANS_SINE or TRANS_QUAD and EASE_OUT
	tween.tween_property(self, "position:y", position.y - 50, 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	# 2. Fade Out
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_delay(0.2)
	
	# 3. Scale up and down (Pop effect)
	scale = Vector2.ZERO
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.chain().tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	# 4. Cleanup when finished
	tween.chain().tween_callback(queue_free)
