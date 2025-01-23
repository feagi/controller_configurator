extends PanelContainer
class_name EditDevice

var _header: Label



func setup_Device(device_definition: FEAGIDevice) -> void:
	_header = $MarginContainer/VBoxContainer/Header/Label
	var holder: VBoxContainer = $MarginContainer/VBoxContainer
	for parameter in device_definition.parameters:
		



func get_physical_ID() -> int:
	return get_index() - 1
