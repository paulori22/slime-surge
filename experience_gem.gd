extends Area2D

@export var experience_value: int = 10
var player = null
var speed = 0
var is_collected: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	add_to_group("experience_gems")
	_update_gem_color()


func _update_gem_color() -> void:
	# Map XP to tint (base texture is green; modulate shifts hue/sat for higher drops).
	const MIN_XP := 5.0
	const MAX_XP := 90.0
	var t: float = clampf((float(experience_value) - MIN_XP) / (MAX_XP - MIN_XP), 0.0, 1.0)
	var lo := Color.from_hsv(0.36, 0.42, 1.0)
	var hi := Color.from_hsv(0.78, 0.85, 1.0)
	sprite.modulate = lo.lerp(hi, t)

func start_magnet(target_player):
	player = target_player

func _physics_process(delta):
	# Optional: Simple "Magnet" effect if player is close
	if player:
		speed += 20.0 * delta
		global_position = global_position.move_toward(player.global_position, speed)


func _on_body_entered(body: Node2D) -> void:
	# 2. Check if it's already been collected
	if is_collected:
		return

	if body.is_in_group("player"):
		is_collected = true # 3. Lock it immediately
		GameEvents.experience_gained.emit(experience_value)
		
		# 4. Use call_deferred to ensure the physics engine is finished with the object
		queue_free()
