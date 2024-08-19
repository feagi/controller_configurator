extends PanelContainer
class_name Device

func setup(parameters: Array[BaseParameter]) -> void:
	var holder: VBoxContainer = $MarginContainer/VBoxContainer
	for parameter in parameters:
		holder.add_child(parameter)

func get_physical_ID() -> int:
	return get_index()
