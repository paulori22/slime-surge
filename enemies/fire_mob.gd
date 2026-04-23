extends "res://enemies/enemy_base.gd"

const FIRE_DAMAGE: float = 5.0

var player_in_range: bool = false


func _configure_stats() -> void:
	max_health = 60.0
	experience_value = 20


func _enemy_ready() -> void:
	%FireSlime.play_walk()
	$BurnZone/Timer.timeout.connect(_on_timer_timeout)


func play_hurt() -> void:
	%FireSlime.play_hurt()


func _on_burn_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		$BurnZone/Timer.start()


func _on_burn_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		$BurnZone/Timer.stop()


func _on_burn_zone_body_shape_entered(_body_id: int, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	pass


func _on_timer_timeout() -> void:
	if player_in_range:
		GameEvents.player_took_damage.emit(FIRE_DAMAGE)
		player.fire_damage_effect()
