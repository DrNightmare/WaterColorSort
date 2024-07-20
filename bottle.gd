extends Node2D

class_name Bottle

@onready var checkmark: Sprite2D = $Checkmark

enum WaterColor { RED, BLUE, GREEN, ORANGE, YELLOW }
var water_unit_textures = {
	WaterColor.RED: preload("res://assets/red_water_unit.png"),
	WaterColor.BLUE: preload("res://assets/blue_water_unit.png"),
	WaterColor.GREEN: preload("res://assets/green_water_unit.png"),
	WaterColor.ORANGE: preload("res://assets/orange_water_unit.png"),
	WaterColor.YELLOW: preload("res://assets/yellow_water_unit.png")
}

var max_units_count: int
var current_units: Array = []
var current_units_sprites: Array = []

var bottom_position_y_offset = 50

func _init(max_units_count_input: int = 4):
	max_units_count = max_units_count_input
	self.current_units = []

func print():
	print(" current units: ", current_units)

func is_empty():
	return current_units.size() == 0

func is_fully_sorted():
	if has_space():
		return false
	var first_colour = current_units[0]
	for unit in current_units:
		if unit != first_colour:
			return false
	return true

func has_space():
	var current_units_count = current_units.size()
	return current_units_count < max_units_count

func add_units(color: WaterColor, num_units: int):
	for unit in num_units:
		add_unit(color)

func add_unit(color: WaterColor):
	var current_units_count = current_units.size()
	if current_units_count >= max_units_count:
		print("Bottle is full, unable to add unit")
		return
	
	var water_unit_sprite = Sprite2D.new()
	# TODO make the texture below based on the color input, hardcoding for now
	water_unit_sprite.texture = water_unit_textures.get(color)
	var position_y_offset = bottom_position_y_offset - (32 * current_units_count)
	water_unit_sprite.position.y = position_y_offset
	add_child(water_unit_sprite)
	current_units_sprites.append(water_unit_sprite)

	current_units.append(color)
	if is_fully_sorted():
		SignalManager.bottle_complete.emit(self)
	
func _remove_unit() -> WaterColor:
	var top_colour = current_units.pop_back()

	var sprite_to_remove = current_units_sprites.pop_back()
	remove_child(sprite_to_remove)
	sprite_to_remove.queue_free()
	
	return top_colour

# use this for setup only, not in the game
func force_pour_into(target_bottle: Bottle, num_units: int):
	var current_units_count = current_units.size()
	if num_units > current_units_count:
		print("Source bottle does not contain enough units, unable to force pour")
		return
	
	# check if target bottle has enough space
	var target_empty_units: int = target_bottle.max_units_count - target_bottle.current_units.size()
	if num_units > target_empty_units:
		print("Target bottle does not contain enough space, unable to force pour")
		return
		
	for i in range(num_units):
		var top_colour = _remove_unit()
		target_bottle.add_unit(top_colour)
		
func pour_into(target_bottle: Bottle):
	var current_units_count = current_units.size()
	if current_units_count == 0:
		print("Source bottle is empty, unable to pour")
		return
	
	# check if target bottle is full
	if target_bottle.current_units.size() == target_bottle.max_units_count:
		print("Target bottle is full, unable to pour")
		return
	
	# check if colors match for pouring
	var source_top_colour = current_units[-1]
	
	# hack to handle target bottle empty
	var target_top_colour = source_top_colour if target_bottle.is_empty() else target_bottle.current_units[-1]
	
	if source_top_colour != target_top_colour:
		print("Source and target colours are not the same, unable to pour")
		return
	
	# can pour, now figure out how many units can be poured
	# it will be min of number of same colour units in source, and the number of empty spaces in target
	
	var source_same_colour_count: int = 0
	for i in range(current_units_count - 1, -1, -1):
		if current_units[i] == source_top_colour:
			source_same_colour_count += 1
		else:
			break
	
	var target_empty_units: int = target_bottle.max_units_count - target_bottle.current_units.size()
	
	var units_to_pour: int = min(source_same_colour_count, target_empty_units)
	
	# transfer these many units to the target bottle
	for i in range(units_to_pour):
		# technically we already know the colour upfront, but just doing this for sanity
		var top_colour = _remove_unit()
		target_bottle.add_unit(top_colour)

func set_complete():
	checkmark.set_visible(true)
