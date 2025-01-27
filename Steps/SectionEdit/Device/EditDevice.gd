extends PanelContainer
class_name EditDevice

var _device_key: StringName
var _device_label: StringName
var _device_description: StringName
var _is_input: bool

var _header: Label

func setup_Device(device_definition: FEAGIDevice) -> void:
	_header = $MarginContainer/VBoxContainer/Header/Label
	var holder: VBoxContainer = $MarginContainer/VBoxContainer
	_device_key = device_definition.device_key
	_device_label = device_definition.label
	_device_description = device_definition.description
	_is_input = device_definition.is_input
	for parameter in device_definition.parameters:
		EditAbstractParameter.spawn_and_add_parameter_editor(parameter, holder)
	refresh_device_ID_label()

func refresh_device_ID_label() -> void:
	_header.text = "Device ID: " + str(get_physical_ID())

func get_physical_ID() -> int:
	return get_index() + 1

func export() -> FEAGIDevice:
	var output: FEAGIDevice = FEAGIDevice.new()
	output.device_key = _device_key
	output.label = _device_label
	output.description = _device_description
	output.is_input = _is_input
	output.parameters = []
	var parameter_holder: VBoxContainer = $MarginContainer/VBoxContainer
	for child in parameter_holder.get_children():
		if child is not EditAbstractParameter:
			continue
		output.parameters.append((child as EditAbstractParameter).export())
	return output
