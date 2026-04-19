extends Resource
class_name Upgrade

@export var title: String = "Upgrade Name"
@export var description: String = "Increases something..."
@export var stat_to_change: String = "fire_rate" # Must match variable name in PlayerData
@export var change_amount: float = 0.1
@export var is_percentage: bool = false
