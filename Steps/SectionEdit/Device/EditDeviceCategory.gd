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
