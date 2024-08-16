extends Node
class_name JSONTemplate
## Global node

const SUPPORTED_TYPES: Array[StringName] = ["string", "boolean", "integer", "float"] # list, object

const PARAM_BOOL: PackedScene = preload("res://UI_Components/Parameters/Comp_Bool.tscn")
const PARAM_STRING: PackedScene = preload("res://UI_Components/Parameters/Comp_String.tscn")
const PARAM_INT: PackedScene = preload("res://UI_Components/Parameters/Comp_Int.tscn")
const PARAM_FLOAT: PackedScene = preload("res://UI_Components/Parameters/Comp_Float.tscn")

var _template: Dictionary

func _enter_tree() -> void:
	_template = JSON.parse_string(FileAccess.get_file_as_string("res://template.json"))

## Parses from the global template json the entirety of an IO seciton details
func get_IO_section(is_input: bool) -> Dictionary:
	var io: StringName = "output"
	if is_input:
		io = "input"
	return _template[io]
	
## Parses from the global template json, as well as (optionally) the current device dict to get the array of controls making up the device parameters
func get_parameter_objects_for_device(is_input: bool, device_type: StringName, existing_values_for_device: Dictionary = {}) -> Array[Control]:
	var output: Array[Control] = []
	var io: StringName = "output"
	if is_input:
		io = "input"
	if device_type not in _template[io]:
		push_error("Unknown device type %s!" % device_type)
		return []
	var parameters: Dictionary = _template[io][device_type]

	for parameter: Dictionary in parameters:
		if "type" not in parameter:
			push_error("No parameter type given!")
			continue
		if parameter["type"] not in SUPPORTED_TYPES:
			push_error("Uknown type $s!" % parameter["type"])
			continue
		if "label" not in parameter:
			push_error("No label given for %s parameter!" % parameter["type"])
			continue
		if "description" not in parameter:
			push_error("No description given for %s parameter!" % parameter["type"])
			continue
		
		
		var label: StringName = parameter["label"]
		var description: StringName = parameter["description"]
		var appending: Control
		var default_value: Variant = null
		if label in existing_values_for_device:
			default_value = existing_values_for_device[label]
		elif "default" in parameter:
			default_value = parameter["default"]
		
		# This code isnt very dry, but at least it wont be overoupled if we have more unique types later
		match(parameter["type"]):
			"string":
				appending = PARAM_STRING.instantiate()
				(appending as CompString).setup(label, description)
				if default_value:
					(appending as CompString).set_value(default_value)
			"boolean":
				appending = PARAM_STRING.instantiate()
				(appending as CompBool).setup(label, description)
				if default_value:
					(appending as CompBool).set_value(default_value)
			"integer":
				appending = PARAM_STRING.instantiate()
				(appending as CompInt).setup(label, description)
				if default_value:
					(appending as CompInt).set_value(default_value)
			"float":
				appending = PARAM_STRING.instantiate()
				(appending as CompFloat).setup(label, description)
				if default_value:
					(appending as CompFloat).set_value(default_value)
		
		output.append(appending)
	return output


	
