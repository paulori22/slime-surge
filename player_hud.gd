extends CanvasLayer

func _ready() -> void:
	GameEvents.experience_gained.connect(_on_experience_gained)
	GameEvents.level_up.connect(_on_level_up)
	GameEvents.enemy_died.connect(_on_enemy_died)
	update_ui()
	

func _on_experience_gained(_amount: int) -> void:
	# We don't even need 'amount' here because PlayerData is already updating itself!
	update_level_system_ui()
	
func _on_level_up(_new_level: int):
	update_level_system_ui()
	
func _on_enemy_died():
	update_statics_ui()

func update_ui():
	update_level_system_ui()
	update_statics_ui()

func update_level_system_ui():
	# Access PlayerData directly
	var current = PlayerData.current_exp
	var goal = PlayerData.xp_next_level

	%CurrentLevelValue.text = str(PlayerData.current_level)
	%ExperienceLabel.text = str(current) + " / " + str(goal)

	# Calculate percentage
	var percentage = (float(current) / goal) * 100
	%ProgressBar.value = percentage

func update_statics_ui():
	#Statics
	var enemies_killed = PlayerData.enemies_killed
	%CurrentKilledEnemiesValue.text = str(enemies_killed)
