extends Area2D

@export var experience_value: int = 10
var player = null
var speed = 0
var is_collected: bool = false

func _ready():
	add_to_group("experience_gems")

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
