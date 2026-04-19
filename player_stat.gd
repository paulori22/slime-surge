extends Resource
class_name PlayerStats

@export var max_health: float = 100.0

@export_group("Attack")
@export var fire_rate: float = 1.0
@export var projectile_count: int = 1
@export var damage: float = 10.0

@export_group("Movement")
@export var move_speed: float = 600.0

@export_group("Utility")
@export var pickup_range: float = 100.0
