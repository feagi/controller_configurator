extends PanelContainer
class_name DeviceType

const DEVICE_PREFAB: PackedScene = preload("res://UI_Components/Device/Device/Device.tscn")

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
	spawn_device_default()

func spawn_device_default() -> void:
	var device: Device = DEVICE_PREFAB.instantiate()
	_box.add_child(device)
	device.setup(Template.get_parameter_objects_for_device(_is_input, name))
	device.tree_exited.connect(_on_device_instance_leaving)

func export_as_dict() -> Dictionary:
	var details: Dictionary = {}
	for i in range(1, _box.get_child_count()):
		var device: Device = _box.get_child(i)
		details.merge(device.get_value_as_dict())
	return {name : details}

func _on_device_instance_leaving() -> void:
	# If there are no devices left, delete this item
	if _box.get_child_count() == 1: # one will exist due to the header
		queue_free()
