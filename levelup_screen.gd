extends CanvasLayer

@export var title: String = "Upgrade Name"
@export var description: String = "Increases something..."
@export var stat_to_change: String = "fire_rate" # Must match variable name in PlayerData
@export var change_amount: float = 0.1
@export var is_percentage: bool = false

func _ready():
	# 1. Pause the game world while this screen is open
	get_tree().paused = true
	# 2. Setup the 3 cards (Logic for picking random upgrades goes here)
	setup_cards()

func setup_cards():
	var upgrades = PlayerData.get_random_upgrade_options(3)
	for i in upgrades.size():
		var upgrade = upgrades[i]
		var upgrade_btn = %UpgradeGrid.get_child(i)
		update_upgrade_card(upgrade,upgrade_btn)
		#upgrade_btn.text = upgrade.title + "\n" + upgrade.description
		upgrade_btn.pressed.connect(_on_upgrade_selected.bind(upgrade))

func update_upgrade_card(upgrade: Upgrade, upgradeBtn: Button):
	var btn_container = upgradeBtn.get_child(0)
	var title = btn_container.find_child('Title')
	var description = btn_container.find_child('Description')
	title.text = upgrade.title
	description.text = upgrade.description
	
func _on_upgrade_selected(upgrade: Upgrade):
	PlayerData.apply_upgrade(upgrade)
	# 1. Reset the flag
	PlayerData.is_levelup_screen_active = false
	# 2. Check if we should unpause FIRST 
	# (We check if a new screen is about to be opened)
	if PlayerData.levels_pending <= 0:
		get_tree().paused = false
	# 3. Try to trigger the next screen
	# If this triggers, it will set paused = true again immediately
	PlayerData.show_levelup_if_ready()
	# 4. Kill this screen
	queue_free()
