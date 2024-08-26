extends VBoxContainer
class_name IO

const DEVICE_TYPE_PREFAB: PackedScene = preload("res://UI_Components/Device/DeviceType/DeviceType.tscn")

@export var header_text: StringName

var _header: Label
var _device_types: OptionButton
var _device_definition_holder: VBoxContainer

var _section_template: Dictionary
var _is_input: bool
var _device_type_mapping: Dictionary = {} # mapped by device type ID int to its name string


func _ready() -> void:
	_header = $Label
	_device_types = $HBoxContainer/OptionButton
	_device_definition_holder = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer
	_header.text = header_text

func setup(is_input: bool) -> void:
	_is_input = is_input
	var io_section: Dictionary = Template.get_IO_section(is_input)
	for possible_device_type in io_section:
		_add_possible_device_type(possible_device_type)
	_section_template = io_section

func export_as_dict() -> Dictionary:
	var details: Dictionary = {}
	for child in _device_definition_holder.get_children():
		details.merge((child as DeviceType).export_as_dict())
	var direction: String = "output"
	if _is_input:
		direction = "input"
	return {direction: details}

func clear_UI() -> void:
	for child in _device_definition_holder.get_children():
		_device_type_removed((child as DeviceType).device_ID)
		child.queue_free()
		

func _add_possible_device_type(device_type: StringName) -> void:
	var num_types: int = len(_device_type_mapping)
	_device_types.add_item(device_type, num_types)
	_device_type_mapping[num_types] = device_type # yes an array would be a bit more performant here but I dont care, still O(1)

func _spawn_selected_device_type() -> void:
	var selected_device_ID: int = _device_types.get_selected_id()
	if selected_device_ID == -1:
		return
	_device_types.set_item_disabled(selected_device_ID, true)
	var device_type: DeviceType = DEVICE_TYPE_PREFAB.instantiate()
	_device_definition_holder.add_child(device_type)
	var device_type_name: StringName = _device_type_mapping[selected_device_ID]
	device_type.setup(_is_input, device_type_name, _section_template[device_type_name]["description"], selected_device_ID)
	_device_types.selected = -1
	device_type.tree_exited.connect(_device_type_removed.bind(selected_device_ID))
	

func _device_type_removed(device_type_ID: int) -> void:
	# Device type handles clearing its own nodes
	_device_types.set_item_disabled(device_type_ID, false)
