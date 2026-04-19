extends Label

var time_elapsed: float = 0.0

func _process(delta: float) -> void:
	# 1. Add the time passed since the last frame
	time_elapsed += delta
	
	# 2. Update the visual text
	text = format_time(time_elapsed)

func format_time(time: float) -> String:
	# Calculate minutes and seconds
	var minutes: int = int(time / 60)
	var seconds: int = int(time) % 60
	
	# Use string formatting to ensure "00:00" style (e.g., 5 seconds becomes "05")
	# %02d means: "integer, at least 2 digits, fill with zero"
	return "%02d:%02d" % [minutes, seconds]
