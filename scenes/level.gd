extends Node2D

class_name Level

var bottles: Array[Bottle]
var current_bottles_count: int = 0
var start_position: Vector2 = Vector2(200, 300)
const BOTTLE = preload("res://scenes/bottle.tscn")

var selected_bottle: Bottle = null

const colour_code_map = {
	'R': Bottle.WaterColor.RED,
	'G': Bottle.WaterColor.GREEN,
	'B': Bottle.WaterColor.BLUE,
	'O': Bottle.WaterColor.ORANGE,
	'Y': Bottle.WaterColor.YELLOW,
}

func add_bottle_to_scene(bottle: Bottle):
	var bottle_position = start_position + (Vector2(100, 0) * current_bottles_count)
	bottle.position = bottle_position
	add_child(bottle)
	
	current_bottles_count += 1
	
func _init(level_code: String):
	var bottle_codes = level_code.split(' ')
	
	for bottle_code in bottle_codes:
		var bottle = BOTTLE.instantiate()
		bottle.set_name("Bottle_%d" % current_bottles_count)
		for colour_code in bottle_code:
			var colour = colour_code_map.get(colour_code)
			bottle.add_unit(colour)
		bottles.append(bottle)
		add_bottle_to_scene(bottle)
	
	# Randomize
	#var bottles_with_space: Array[Bottle] = []
	#
	#var num_shuffles = 15
	#for i in range(num_shuffles):
		#var source_bottle = bottles[i % current_bottles_count]
		#if source_bottle.is_empty():
			#continue
		#
		#var target_bottle: Bottle = bottles_with_space.pick_random()
		#
		#source_bottle.force_pour_into(target_bottle, 1)
		#
		## add source bottle, we just poured from it
		#if source_bottle not in bottles_with_space:
			#bottles_with_space.append(source_bottle)
		#
		## if target is full and was in bottles_with_space, remove it
		#if not target_bottle.has_space() and target_bottle in bottles_with_space:
			#bottles_with_space.erase(target_bottle)

func _ready():
	SignalManager.bottle_selected.connect(handle_bottle_selected)
	SignalManager.bottle_complete.connect(handle_bottle_completed)
	
func is_complete() -> bool:
	for bottle in bottles:
		# bottle should either be empty or fully sorted
		if not bottle.is_empty():
			if not bottle.is_fully_sorted():
				return false
	return true
		
func handle_bottle_selected(bottle_index: int):
	if selected_bottle:
		var target_bottle = bottles[bottle_index]
		if selected_bottle != target_bottle:
			selected_bottle.pour_into(target_bottle)
		selected_bottle.position += Vector2(0, 50)
		selected_bottle = null
	else:
		if bottles[bottle_index].is_fully_sorted() or bottles[bottle_index].is_empty():
			return
		selected_bottle = bottles[bottle_index]
		selected_bottle.position += Vector2(0, -50)
	if is_complete():
		SignalManager.level_complete.emit()

func handle_bottle_completed(bottle: Bottle):
	bottle.set_complete()
