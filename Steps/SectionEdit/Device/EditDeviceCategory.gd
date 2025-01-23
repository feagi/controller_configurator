extends PanelContainer
class_name EditDeviceCategory
## Holds all instances of a certain device type

const DEVICE_PREFAB: PackedScene = preload("res://Steps/SectionEdit/Device/EditDevice.tscn")

var _is_input: bool

var _box: VBoxContainer
var _header: Label

func _ready() -> void:
	_box = $DeviceType
	_header = $DeviceType/HBoxContainer/Label

func setup(is_input: bool, title: StringName, description: StringName) -> void:
	_is_input = is_input
	name = title
	_header.text = title
	_header.tooltip_text = description

func spawn_device(device_definition: FEAGIDevice) -> void:
	var device_UI: EditDevice = DEVICE_PREFAB.instantiate()
	device_UI.setup_Device(device_definition)
	_box.add_child(device_UI)

## Exports JSON as {"Device Key" : {"str device index" : {device details}}}
func export_as_FEAGI_configurator_JSON() -> Dictionary:
	var output: Dictionary = {}
	var device_index: int = 0
	for child in _box.get_children():
		if child is not EditDevice:
			continue
		var device_definition: FEAGIDevice = (child as EditDevice).export()
		var JSON_device_definition: Dictionary = device_definition.get_as_JSON_formatable_dict(device_index)
		device_index += 1
		output.merge(JSON_device_definition)
	return output
