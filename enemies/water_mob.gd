extends "res://enemies/enemy_base.gd"

const WATER_DAMAGE: float = 5.0
const SHOOT_INTERVAL_SEC: float = 2.0

const WATER_PROJECTILE_SCENE = preload("res://enemies/projectiles/water_projectile.tscn")

var player_in_range: bool = false

@onready var shoot_timer: Timer = $ShootRange/ShootTimer

func _configure_stats() -> void:
	max_health = 60.0
	experience_value = 20

func _enemy_ready() -> void:
	%WaterSlime.play_walk()
	shoot_timer.wait_time = SHOOT_INTERVAL_SEC
	shoot_timer.one_shot = false
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func play_hurt() -> void:
	%WaterSlime.play_hurt()

func _on_shoot_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		shoot_projectile()
		shoot_timer.start(SHOOT_INTERVAL_SEC)

func _on_shoot_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		shoot_timer.stop()

func _on_shoot_timer_timeout() -> void:
	if player_in_range:
		shoot_projectile()

func shoot_projectile():
	# 1. Instantiate the projectile
	var projectile = WATER_PROJECTILE_SCENE.instantiate()
	
	# 2. Add it to the Game world (parent of the slime) so it moves independently
	get_parent().add_child(projectile)
	
	# 3. Set starting position
	projectile.global_position = global_position
	
	# 4. Set the direction (pointing towards the player) and aim sprite once
	var dir_to_player = global_position.direction_to(player.global_position)
	projectile.direction = dir_to_player
	projectile.rotation = dir_to_player.angle() + PI
