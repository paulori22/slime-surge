extends Area2D

func _ready() -> void:
	GameEvents.player_stats_updated.connect(update_fire_rate)
	update_fire_rate()

func _physics_process(delta: float) -> void:
	var enemies_in_range = get_overlapping_bodies()
	if enemies_in_range.size() > 0:
		var target_enemy = enemies_in_range.front()
		look_at(target_enemy.global_position)

func shoot():
	var count = PlayerData.projectile_count
	var spread = deg_to_rad(30.0) 

	# Handle the logic based on the number of bullets
	if count <= 1:
		# Just one bullet? Shoot it exactly where the gun is pointing.
		spawn_bullet(0)
	else:
		# Multiple bullets? Spread them out.
		var start_offset = -spread / 2.0
		var angle_step = spread / (count - 1)

		for i in range(count):
			var current_offset = start_offset + (i * angle_step)
			spawn_bullet(current_offset)

# Helper function to keep the code clean
func spawn_bullet(offset: float):
	const BULLET = preload("res://bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = %ShootingPoint.global_position
	new_bullet.global_rotation = global_rotation + offset
	get_tree().root.add_child(new_bullet)

func _on_timer_timeout() -> void:
	shoot()

func update_fire_rate():
	var wait_time = 1.0 / PlayerData.get_fire_rate()
	%ShootTimer.wait_time = wait_time
