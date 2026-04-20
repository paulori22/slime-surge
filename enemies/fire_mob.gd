extends CharacterBody2D

const EXP: int = 20

var health = 60.0

var is_dead: bool
var player_in_range: bool = false
const FIRE_DAMAGE: float = 5.0

@onready var player = get_node("/root/Game/Player")
@export_range(0, 1.0) var drop_item_rate: float = 0.05 # 5% chance

# Add the reference to the label scene at the top
const DAMAGE_LABEL_SCENE = preload("res://ui/damage_label.tscn")

func _ready() -> void:
	%FireSlime.play_walk()
	$BurnZone/Timer.timeout.connect(_on_timer_timeout)

func _on_burn_zone_body_entered(body):
	print("On burn zone: ", body.name)
	if body.is_in_group("player"):
		player_in_range = true
		$BurnZone/Timer.start() # Start burning when player enters

func _on_burn_zone_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		$BurnZone/Timer.stop() # Stop burning when player leaves

func _on_timer_timeout():
	print("Timeout reached: ", player_in_range)
	if player_in_range:
		# Damage the player
		GameEvents.player_took_damage.emit(FIRE_DAMAGE)
		player.fire_damage_effect()

func _physics_process(delta: float) -> void:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * 300.0
		move_and_slide()

func take_damage():
	if is_dead: return # Stop if already dying
	var damage = PlayerData.get_damage()
	health -= damage
	spawn_damage_number(damage)
	%FireSlime.play_hurt()
	if health <= 0:
		is_dead = true # Set the flag immediately
		# We tell Godot: "Wait until this physics frame is done, then run die()"
		die.call_deferred()

func die():
	GameEvents.enemy_died.emit()
	# 1. Spawn the smoke effect
	const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")
	var smoke = SMOKE_SCENE.instantiate()
	get_parent().add_child(smoke)
	smoke.global_position = global_position
	
	spawn_experience_gem()
	check_if_drop_item()

	# 3. Finally, remove the mob safely
	queue_free()
	
func spawn_experience_gem():
	# 2. Spawn the experience gem
	var experience_gem = preload("res://experience_gem.tscn").instantiate()
	get_parent().add_child(experience_gem)
	experience_gem.global_position = global_position

func check_if_drop_item():
	var roll = randf()
	if roll < drop_item_rate:
		var random_item_data = PlayerData.get_random_item()
		if random_item_data:
			spawn_item(random_item_data)

func spawn_item(item_resource: Item):
	var item_scene = preload("res://items/dropped_item.tscn").instantiate()
	item_scene.data = item_resource
	get_parent().add_child(item_scene)
	item_scene.global_position = global_position
	
func spawn_damage_number(value: int):
	var label = DAMAGE_LABEL_SCENE.instantiate()
	# Add to the Game world, not the Mob (so it stays put if the mob moves)
	get_parent().add_child(label)
	
	# Position it slightly above the mob
	label.global_position = global_position + Vector2(-20, -40)
	
	# Give it a tiny bit of random horizontal offset so numbers don't stack perfectly
	label.global_position.x += randf_range(-10, 10)
	
	label.set_damage(value)
