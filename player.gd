extends CharacterBody2D

signal health_depleted


func _ready() -> void:
	GameEvents.player_stats_updated.connect(update_pickup_range)
	update_pickup_range()
	update_health_bar()
	GameEvents.level_up.connect(update_max_health_bar_value)
	#Need to unbind the ammount so update_current_health_bar_value works
	GameEvents.player_took_damage.connect(update_current_health_bar_value.unbind(1))

func update_pickup_range():
	%PickupRangeCollisionShape.shape.radius = PlayerData.pickup_range

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	velocity = direction * PlayerData.move_speed
	move_and_slide()
	var animation = %HappyBoo;
	if velocity.length() > 0.0:
		animation.play_walk_animation()
	else:
		animation.play_idle_animation()

	const DAMAGE_RATE = 5.0
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		var damage = DAMAGE_RATE * overlapping_mobs.size() * delta
		GameEvents.player_took_damage.emit(damage)
		if PlayerData.current_health <= 0.0:
			health_depleted.emit()

func update_health_bar():
	update_current_health_bar_value()
	update_max_health_bar_value()

func update_current_health_bar_value():
	%HealthBar.value = PlayerData.current_health

func update_max_health_bar_value():
	%HealthBar.max_value = PlayerData.max_health

func _on_pickup_range_area_entered(area):
	if area.has_method("start_magnet"):
		area.player = self # Tell the gem to start following the player

func fire_damage_effect():
	%HappyBoo.modulate = Color(1, 0, 0) # Flash Red
	await get_tree().create_timer(0.1).timeout
	%HappyBoo.modulate = Color(1, 1, 1) # Back to normal
