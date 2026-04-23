extends "res://enemies/enemy_base.gd"


func _enemy_ready() -> void:
	%Slime.play_walk()


func play_hurt() -> void:
	%Slime.play_hurt()
