extends PanelContainer
class_name Device

var _header: Label

func setup(parameters: Array[BaseParameter]) -> void:
	_header = $MarginContainer/VBoxContainer/Header/Label
	var holder: VBoxContainer = $MarginContainer/VBoxContainer
	for parameter in parameters:
		holder.add_child(parameter)
	refresh_device_ID_label()

func get_physical_ID() -> int:
	return get_index() - 1

func refresh_device_ID_label() -> void:
	_header.text = "Device " + str(get_physical_ID())

func export_as_dict() -> Dictionary:
	var holder: VBoxContainer = $MarginContainer/VBoxContainer
	var details: Dictionary = {}
	for i in range(1, holder.get_child_count()):
		var parameter: BaseParameter = holder.get_child(i)
		if !parameter.visible:
			continue # dont add invisible parameters
		details.merge(parameter.get_value_as_dict())
	return {get_physical_ID() : details}
		
		
