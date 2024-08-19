extends Node
class_name JSONTemplate
## Global node

const SUPPORTED_TYPES: Array[StringName] = ["string", "boolean", "integer", "float", "list"] # list, object

const PARAM_BOOL: PackedScene = preload("res://UI_Components/Parameters/Comp_Bool.tscn")
const PARAM_STRING: PackedScene = preload("res://UI_Components/Parameters/Comp_String.tscn")
const PARAM_INT: PackedScene = preload("res://UI_Components/Parameters/Comp_Int.tscn")
const PARAM_FLOAT: PackedScene = preload("res://UI_Components/Parameters/Comp_Float.tscn")
const PARAM_LIST: PackedScene = preload("res://UI_Components/Parameters/Comp_List.tscn")

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
func get_parameter_objects_for_device(is_input: bool, device_type: StringName, existing_values_for_device: Dictionary = {}) -> Array[BaseParameter]:
	var output: Array[BaseParameter] = []
	var io: StringName = "output"
	if is_input:
		io = "input"
	if device_type not in _template[io]:
		push_error("Unknown device type %s!" % device_type)
		return []
	var parameters: Array = _template[io][device_type]["parameters"]

	for parameter: Dictionary in parameters:
		output.append(_spawn_parameter(parameter))
	
	return output
	

func _spawn_parameter(parameter: Dictionary, default_value: Variant = null) -> BaseParameter:
	if "type" not in parameter:
		push_error("No parameter type given!")
		return null
	if parameter["type"] not in SUPPORTED_TYPES:
		push_error("Unknown type %s!" % parameter["type"])
		return null
	if "label" not in parameter:
		push_error("No label given for %s parameter!" % parameter["type"])
		return null
	if "description" not in parameter:
		push_error("No description given for %s parameter!" % parameter["type"])
		return null
	
	var label: StringName = parameter["label"]
	var description: StringName = parameter["description"]
	var appending: BaseParameter = null

	if default_value == null and "default" in parameter:
		default_value = parameter["default"]
	
	match(parameter["type"]):
		"string":
			appending = PARAM_STRING.instantiate()
			(appending as CompString).setup(label, description)
			if default_value:
				(appending as CompString).set_value(default_value)
		"boolean":
			appending = PARAM_BOOL.instantiate()
			(appending as CompBool).setup(label, description)
			if default_value:
				(appending as CompBool).set_value(default_value)
		"integer":
			appending = PARAM_INT.instantiate()
			(appending as CompInt).setup(label, description)
			if default_value:
				(appending as CompInt).set_value(default_value)
		"float":
			appending = PARAM_FLOAT.instantiate()
			(appending as CompFloat).setup(label, description)
			if default_value:
				(appending as CompFloat).set_value(default_value)
		"list":
			if "element_type" not in parameter:
				push_error("No element type defined for list parameter!")
				return null
			if "min_length" not in parameter:
				push_error("No minimum length defined for list parameter!")
				return null
			if default_value is not Array:
				push_warning("Given default for list type is not an array. Resetting defaults for this list...")
				default_value = []
			appending = PARAM_LIST.instantiate()
			(appending as CompList).setup(label, description)
			(appending as CompList).setup_internals(_return_parameter_list(parameter["element_type"], parameter["min_length"], default_value))
			
	
	return appending
	

func _return_parameter_list(element_type: StringName, count: int, default: Array) -> Array[BaseParameter]:
	var building_list: Array[BaseParameter] = []
	var artificial_parameter: Dictionary = {
		"type" = element_type,
		"label" = element_type,
		"description" = ""
	}
	var appending: BaseParameter
	for i in range(count):
		if i < len(default):
			appending = _spawn_parameter(artificial_parameter, default[i])
		else:
			appending = _spawn_parameter(artificial_parameter)
	
		if appending != null:
			building_list.append(appending)
	
	return building_list
	
