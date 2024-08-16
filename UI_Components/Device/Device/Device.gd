extends PanelContainer
class_name Device

func setup(parameters: Array[Control]) -> void:
	var holder: VBoxContainer = $VBoxContainer
	for parameter in parameters:
		holder.add_child(parameter)

func get_physical_ID() -> int:
	return get_index()
