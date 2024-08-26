extends OptionButton
class_name IODropDown

var _string_to_ID: Array[StringName] = []

func set_to_unselected() -> void:
	selected = -1

func add_device_type(device_type_name: StringName) -> void:
	_string_to_ID.append(device_type_name)
	add_item(device_type_name)

func get_selected_text() -> StringName:
	return _string_to_ID[get_selected()]

func toggle_disabled_item_by_name(device_type_name: StringName, is_option_disabled: bool) -> void:
	var ID: int = _get_index_by_device_type_name(device_type_name)
	if ID == -1:
		return
	set_item_disabled(ID, is_option_disabled)
	

## Returns the index of the given device type name. returns -1 if none exists
func _get_index_by_device_type_name(device_type_name: StringName) -> int:
	return _string_to_ID.find(device_type_name)
