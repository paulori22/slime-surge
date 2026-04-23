extends CharacterBody2D

@export var max_health: float = 30.0
@export var move_speed: float = 300.0
@export var experience_value: int = 10
@export_range(0, 1.0) var drop_item_rate: float = 0.05

var health: float
var is_dead: bool = false

@onready var player: Node2D = get_node("/root/Game/Player")

const DAMAGE_LABEL_SCENE = preload("res://ui/damage_label.tscn")
const EXPERIENCE_GEM_SCENE = preload("res://experience_gem.tscn")
const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")
const DROPPED_ITEM_SCENE = preload("res://items/dropped_item.tscn")


func _ready() -> void:
	_configure_stats()
	health = max_health
	_enemy_ready()


func _configure_stats() -> void:
	pass


func _enemy_ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	move_toward_player()


func move_toward_player() -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * move_speed
	move_and_slide()


func take_damage() -> void:
	if is_dead:
		return
	var damage = PlayerData.get_damage()
	health -= damage
	spawn_damage_number(damage)
	play_hurt()
	if health <= 0:
		is_dead = true
		die.call_deferred()


func play_hurt() -> void:
	pass


func die() -> void:
	GameEvents.enemy_died.emit()
	var smoke = SMOKE_SCENE.instantiate()
	get_parent().add_child(smoke)
	smoke.global_position = global_position
	spawn_experience_gem()
	check_if_drop_item()
	queue_free()


func spawn_experience_gem() -> void:
	var gem = EXPERIENCE_GEM_SCENE.instantiate()
	gem.experience_value = experience_value
	get_parent().add_child(gem)
	gem.global_position = global_position


func check_if_drop_item() -> void:
	if randf() >= drop_item_rate:
		return
	var random_item_data = PlayerData.get_random_item()
	if random_item_data:
		spawn_item(random_item_data)


func spawn_item(item_resource: Item) -> void:
	var item_scene = DROPPED_ITEM_SCENE.instantiate()
	item_scene.data = item_resource
	get_parent().add_child(item_scene)
	item_scene.global_position = global_position


func spawn_damage_number(value: int) -> void:
	var label = DAMAGE_LABEL_SCENE.instantiate()
	get_parent().add_child(label)
	label.global_position = global_position + Vector2(-20, -40)
	label.global_position.x += randf_range(-10, 10)
	label.set_damage(value)
