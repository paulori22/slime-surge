extends Area2D

@export var data: Item

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func _ready():
	if data:
		# 1. Set the Visuals
		sprite.texture = data.icon
		sprite.scale = Vector2(data.sprite_scale, data.sprite_scale)
		
		# 2. Set the Collision
		# Important: We access the 'shape' property of the CollisionShape2D node
		if collision_shape.shape is CircleShape2D:
			collision_shape.shape = collision_shape.shape.duplicate()
			collision_shape.shape.radius = data.collision_radius

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		apply_effect(body)
		queue_free()

func apply_effect(body: Node2D):
	match data.type:
		Item.ItemType.HEAL:
			# Direct access to player's health variable
			body.current_health += data.value
			body.update_current_health_bar_value()
			
		Item.ItemType.MAGNET:
			# Signal all experience gems to fly to the player
			print("Magnet called!")
			get_tree().call_group("experience_gems", "start_magnet", body)
