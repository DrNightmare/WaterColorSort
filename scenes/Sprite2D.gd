extends Sprite2D

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if get_rect().has_point(get_local_mouse_position()):
			if event.button_index == MOUSE_BUTTON_LEFT:
				var bottle_index = get_parent().get_name().split('_')[1].to_int()
				SignalManager.bottle_selected.emit(bottle_index)

