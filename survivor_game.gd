extends Node2D

const MOB_SCENE := preload("res://enemies/mob.tscn")
const WATER_MOB_SCENE := preload("res://enemies/water_mob.tscn")
const FIRE_MOB_SCENE := preload("res://enemies/fire_mob.tscn")
const BOSS_SCENE := preload("res://enemies/boss_slime.tscn")

const MAX_LIVE_SPAWNED_ENEMIES: int = 220

@onready var path_follow: PathFollow2D = %PathFollow2D
@onready var spawn_timer: Timer = $Timer
@onready var enemies_container: Node2D = $Enemies

var game_time_sec: float = 0.0
var _boss_spawn_count: int = 0


func _ready() -> void:
	spawn_timer.wait_time = _spawn_interval_sec()


func _process(delta: float) -> void:
	if get_tree().paused:
		return
	game_time_sec += delta


func _spawn_interval_sec() -> float:
	var minutes: float = game_time_sec / 60.0
	var base: float = lerpf(1.15, 0.22, clampf(minutes / 12.0, 0.0, 1.0))
	return maxf(0.12, base * randf_range(0.85, 1.15))


func _enemies_per_tick() -> int:
	var minutes: float = game_time_sec / 60.0
	var n: int = 1 + int(minutes / 0.75)
	n += int(minutes / 3.0)
	return mini(MAX_LIVE_SPAWNED_ENEMIES, n)


func _pick_enemy_scene() -> PackedScene:
	var t: float = game_time_sec
	var w_mob: float = maxf(8.0, 48.0 - t * 0.06)
	var w_water: float = maxf(0.0, (t - 40.0) * 0.35)
	var w_fire: float = maxf(0.0, (t - 110.0) * 0.28)
	var w_boss: float = maxf(0.0, (t - 240.0) * 0.012)
	var total: float = w_mob + w_water + w_fire + w_boss
	var roll: float = randf() * total
	roll -= w_mob
	if roll <= 0.0:
		return MOB_SCENE
	roll -= w_water
	if roll <= 0.0:
		return WATER_MOB_SCENE
	roll -= w_fire
	if roll <= 0.0:
		return FIRE_MOB_SCENE
	return BOSS_SCENE


func _maybe_force_milestone_boss() -> void:
	var every: float = 300.0
	var idx: int = int(game_time_sec / every)
	if idx <= _boss_spawn_count:
		return
	if enemies_container.get_child_count() >= MAX_LIVE_SPAWNED_ENEMIES - 1:
		return
	_boss_spawn_count = idx
	var boss: Node2D = BOSS_SCENE.instantiate()
	path_follow.progress_ratio = randf()
	boss.global_position = path_follow.global_position
	enemies_container.add_child(boss)


func spawn_enemy_at_edge(scene: PackedScene) -> void:
	if enemies_container.get_child_count() >= MAX_LIVE_SPAWNED_ENEMIES:
		return
	var enemy: Node2D = scene.instantiate()
	path_follow.progress_ratio = randf()
	enemy.global_position = path_follow.global_position
	enemies_container.add_child(enemy)


func spawn_mob() -> void:
	spawn_enemy_at_edge(MOB_SCENE)


func _spawn_wave() -> void:
	_maybe_force_milestone_boss()
	var count: int = _enemies_per_tick()
	for i in count:
		if enemies_container.get_child_count() >= MAX_LIVE_SPAWNED_ENEMIES:
			break
		spawn_enemy_at_edge(_pick_enemy_scene())


func _on_timer_timeout() -> void:
	return
	_spawn_wave()
	spawn_timer.wait_time = _spawn_interval_sec()


func _on_player_health_depleted() -> void:
	spawn_timer.stop()
	%GameOver.visible = true
	get_tree().paused = true
