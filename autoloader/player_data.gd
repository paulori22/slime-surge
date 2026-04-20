extends Node

const LEVELUP_SCREEN = preload("res://levelup_screen.tscn")

# --- New Queue Variables ---
var levels_pending: int = 0
var is_levelup_screen_active: bool = false
# ---------------------------

#Player level
var current_exp: int = 0
var current_level: int = 1
var xp_next_level: int = 5 # Starting requirement

# This holds the "base" stats from your file
@export var base_stats: PlayerStats = preload("res://base_player_stats.tres")
var max_health: float
var current_health: float

@export_group("Attack")
var fire_rate: float
var fire_rate_multiplier: float
var projectile_count: int
var damage: float
var damage_multiplier: float

@export_group("Movement")
var move_speed: float

@export_group("Utility")
var pickup_range: float

@export_group("Statics")
var enemies_killed: int = 0

func _ready():
	reset_to_base_stats()
	GameEvents.experience_gained.connect(_on_exp_gained)
	GameEvents.enemy_died.connect(_on_enemy_died)
	GameEvents.player_took_damage.connect(_on_took_damage)

func reset_to_base_stats():
	max_health = base_stats.max_health
	current_health = max_health
	fire_rate = base_stats.fire_rate
	fire_rate_multiplier = 1.0
	projectile_count = base_stats.projectile_count
	damage = base_stats.damage
	damage_multiplier = 1.0
	move_speed = base_stats.move_speed
	pickup_range = base_stats.pickup_range

func _on_exp_gained(amount: int):
	current_exp += amount
	while current_exp >= xp_next_level:
		# Instead of instantiating here, we prepare the level
		prepare_level_up()
	
	# After checking all XP, try to show the first screen
	show_levelup_if_ready()

func prepare_level_up():
	current_exp -= xp_next_level 
	current_level += 1
	levels_pending += 1 # Add to the queue

	if current_level <= 20:
		xp_next_level += 10
	elif current_level <= 40:
		xp_next_level += 13
	else:
		xp_next_level += 16

	GameEvents.level_up.emit(current_level)
	print("LEVEL PENDING! Level: ", current_level, " Pending: ", levels_pending)

func show_levelup_if_ready():
	# If a screen is already open or no levels are waiting, stop
	if is_levelup_screen_active or levels_pending <= 0:
		return
	# PAUSE THE GAME HERE
	get_tree().paused = true

	is_levelup_screen_active = true
	levels_pending -= 1
	
	var screen = LEVELUP_SCREEN.instantiate()
	get_tree().root.add_child(screen)

func get_damage() -> float:
	return damage * damage_multiplier

func get_fire_rate() -> float:
	return fire_rate * fire_rate_multiplier

func apply_upgrade(upgrade: Upgrade):
	if upgrade.is_percentage:
		# Example: set("fire_rate", get("fire_rate") * 1.1)
		var current_val = get(upgrade.stat_to_change)
		set(upgrade.stat_to_change, current_val * (1.0 + upgrade.change_amount))
	else:
		# Example: projectile_count += 1
		var current_val = get(upgrade.stat_to_change)
		set(upgrade.stat_to_change, current_val + upgrade.change_amount)	

	# SPECIAL LOGIC: If we increased max_health, heal the player by that amount
	if upgrade.stat_to_change == "max_health":
		current_health += upgrade.change_amount
		# Ensure we don't accidentally exceed the new max if using complex math
		current_health = clamp(current_health, 0, max_health)
	GameEvents.player_stats_updated.emit()

# Preload the entire library at once
const MASTER_POOL = preload("res://upgrades/main_upgrade_pool.tres")

func get_random_upgrade_options(amount: int) -> Array[Upgrade]:
	var available = MASTER_POOL.upgrades.duplicate()
	available.shuffle()
	
	# Returns the first 'amount' of upgrades (e.g., 3)
	return available.slice(0, amount)

func _on_enemy_died():
	enemies_killed += 1

@export_group("Drops")
@export var drop_table: Array[Item] = []
func get_random_item() -> Item:
	var total_weight = 0
	for item in drop_table:
		total_weight += item.drop_weight
	
	var roll = randi_range(0, total_weight)
	var current_weight = 0
	
	for item in drop_table:
		current_weight += item.drop_weight
		if roll <= current_weight:
			return item
			
	return null

func _on_took_damage(amount: float):
	current_health -= amount
