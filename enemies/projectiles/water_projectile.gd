extends Area2D

@export var speed: float = 400.0
@export var damage: float = 10.0

var direction: Vector2 = Vector2.ZERO

# 1. Start the movement
func _ready():
	# If direction wasn't set externally, default to moving right
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT

	# Connect the collision and timeout signals
	body_entered.connect(_on_body_entered)
	$Timer.timeout.connect(_on_timer_timeout)

# 2. Handle movement
func _physics_process(delta: float):
	# Move in a straight line
	global_position += direction * speed * delta

# 3. Handle collision (Hitting the Player)
func _on_body_entered(body: Node2D):
	# Our Mask ensures this is likely the Player, but double-check group
	if body.is_in_group("player"):
		GameEvents.player_took_damage.emit(damage)
		pop()

# 4. Handle time limit (Bubble pops after 3 seconds)
func _on_timer_timeout():
	pop()

# 5. Cleanup/Visuals
func pop():
	# 1. Stop processing to avoid double impacts
	set_physics_process(false)
	disconnect("body_entered", _on_body_entered)
	
	# Optional: Add a pop particle effect here
	
	# 2. Remove from scene
	queue_free()
