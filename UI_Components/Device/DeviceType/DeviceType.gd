extends PanelContainer
class_name DeviceType

const DEVICE_PREFAB: PackedScene = preload("res://UI_Components/Device/Device/Device.tscn")

var _is_input: bool

var _box: VBoxContainer
var _header: Label

func _ready() -> void:
	_box = $DeviceType
	_header = $DeviceType/Label



func setup(is_input: bool, title: StringName, description: StringName) -> void:
	_is_input = is_input
	name = title
	_header.text = title
	_header.tooltip_text = description
	spawn_device_default()

func spawn_device_default() -> void:
	var device: Device = DEVICE_PREFAB.instantiate()
	device.setup(Template.get_parameter_objects_for_device(_is_input, name))
