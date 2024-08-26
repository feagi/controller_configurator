extends VBoxContainer
class_name IO

const DEVICE_TYPE_PREFAB: PackedScene = preload("res://UI_Components/Device/DeviceType/DeviceType.tscn")

@export var header_text: StringName

var _header: Label
var _device_types: IODropDown
var _device_definition_holder: VBoxContainer

var _section_template: Dictionary
var _is_input: bool


func _ready() -> void:
	_header = $Label
	_device_types = $HBoxContainer/OptionButton
	_device_definition_holder = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer
	_header.text = header_text

func setup(is_input: bool) -> void:
	_is_input = is_input
	var io_section: Dictionary = Template.get_IO_section(is_input)
	for possible_device_type in io_section:
		_device_types.add_device_type(possible_device_type)
	_section_template = io_section

func export_as_dict() -> Dictionary:
	var details: Dictionary = {}
	for child in _device_definition_holder.get_children():
		details.merge((child as DeviceType).export_as_dict())
	var direction: String = "output"
	if _is_input:
		direction = "input"
	return {direction: details}

## Given the input/output dictionary elements from capabilities, spawn all devices
func import_from_dicts(elements: Dictionary) -> void:
	for device_type_name: StringName in elements:
		if elements[device_type_name] is not Dictionary:
			push_error("Device definition for device of type %s appears malformed!" % device_type_name)
			continue
		var device_type_holder: DeviceType = _spawn_device_type(device_type_name)
		var device_definitions: Dictionary = elements[device_type_name]
		for raw_single_device_definition in device_definitions.values():
			if raw_single_device_definition is not Dictionary:
				push_error("Device definition for device of type %s appears malformed!" % device_type_name)
				device_type_holder.queue_free()
				continue
			var single_device_definition: Dictionary = raw_single_device_definition
			device_type_holder.spawn_device(single_device_definition)


func clear_UI() -> void:
	for child in _device_definition_holder.get_children():
		child.free() # SCARY

func _add_device_button_pressed() -> void:
	var selected_device_type: StringName = _device_types.get_selected_text()
	if selected_device_type == "":
		return
	var device_type: DeviceType = _spawn_device_type(selected_device_type)
	device_type.spawn_device()

func _spawn_device_type(device_type_name: StringName) -> DeviceType:
	_device_types.toggle_disabled_item_by_name(device_type_name, true)
	var device_type: DeviceType = DEVICE_TYPE_PREFAB.instantiate()
	_device_definition_holder.add_child(device_type)
	device_type.setup(_is_input, device_type_name, _section_template[device_type_name]["description"])
	_device_types.set_to_unselected()
	device_type.tree_exited.connect(_device_types.toggle_disabled_item_by_name.bind(device_type_name, false)) # bind such that if device type is disabled, that the option in the drop down is no longer disabled
	return device_type
