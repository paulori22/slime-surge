extends Resource
class_name Item

enum ItemType { MAGNET, HEAL }

@export var title: String = ""
@export var type: ItemType
@export var value: float = 0.0 # Amount to heal
@export_range(0, 100) var drop_weight: int = 10 # Higher number = more common


@export var icon: Texture2D
@export var sprite_scale: float = 1.0
@export var collision_radius: float = 10.0
