extends Node

class_name LevelManager

var current_level: Level = null
var current_level_index: int = 0
# TODO load these from some file
var level_codes: PackedStringArray = []
@onready var level_number = $LevelNumber
@onready var level_complete_label: Label = $LevelComplete
@onready var level_transition_timer: Timer = $LevelTransitionTimer


func load_level(level_index: int):
	if level_index >= level_codes.size():
		return
		
	if current_level != null:
		current_level.queue_free()
	
	var current_level_code = level_codes[level_index]
	current_level = Level.new(current_level_code)
	current_level_index = level_index
	level_number.set_text('Level {level_number}'.format({ 'level_number': level_index + 1 }))
	
	add_child(current_level)

func load_next_level():
	current_level_index += 1
	load_level(current_level_index)
	
func reload_level():
	load_level(current_level_index)

func level_complete():
	level_complete_label.set_text('Level Complete!')
	level_transition_timer.start()

func _init():
	# Load level codes from file
	var file = FileAccess.open("res://levels.txt", FileAccess.READ)
	var content = file.get_as_text()
	level_codes = content.split('\n')

	SignalManager.level_complete.connect(level_complete)

func _ready():
	load_level(0)

func _on_level_transition_timer_timeout():
	print('Transitioning to next level')
	load_next_level()
