extends "res://enemies/enemy_base.gd"


func _configure_stats() -> void:
	max_health = 250.0
	experience_value = 80
	move_speed = 200.0


func _enemy_ready() -> void:
	%Slime.play_walk()


func play_hurt() -> void:
	%Slime.play_hurt()
