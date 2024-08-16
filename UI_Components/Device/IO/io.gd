extends VBoxContainer
class_name IO

@export var header_text: StringName

var _header: Label
var _device_types: OptionButton
var _device_definition_holder: VBoxContainer

var _section_template: Dictionary
var _device_type_mapping: Dictionary = {} # mapped by device type ID int to its name string


func _ready() -> void:
	_header = $Label
	_device_types = $HBoxContainer/OptionButton
	_device_definition_holder = $PanelContainer/ScrollContainer/VBoxContainer
	_header.text = header_text

func setup(is_input: bool) -> void:
	var io_section: Dictionary = Template.get_IO_section(is_input)
	for possible_device_type in io_section:
		_add_possible_device_type(possible_device_type)
	_section_template = io_section

func _add_possible_device_type(device_type: StringName) -> void:
	var num_types: int = len(_device_type_mapping)
	_device_types.add_item(device_type, num_types)
	_device_type_mapping[num_types] = device_type # yes an array would be a bit more performant here but I dont care, still O(1)

func _spawn_selected_device_type() -> void:
	var selected_device_ID: int = _device_types.get_selected_id()
	if selected_device_ID == -1:
		return
	_device_types.set_item_disabled(selected_device_ID, true)
	# TODO spawn device category 

func _device_type_removed(device_type_ID: int) -> void:
	# Device type handles clearing its own nodes
	_device_types.set_item_disabled(device_type_ID, false)
