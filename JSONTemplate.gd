extends Node
class_name JSONTemplate
## Global node

const SUPPORTED_TYPES: Array[StringName] = ["string", "boolean", "integer", "float", "list", "percentage", "object"]

const PARAM_BOOL: PackedScene = preload("res://UI_Components/Parameters/Comp_Bool.tscn")
const PARAM_STRING: PackedScene = preload("res://UI_Components/Parameters/Comp_String.tscn")
const PARAM_INT: PackedScene = preload("res://UI_Components/Parameters/Comp_Int.tscn")
const PARAM_FLOAT: PackedScene = preload("res://UI_Components/Parameters/Comp_Float.tscn")
const PARAM_PERCENT: PackedScene = preload("res://UI_Components/Parameters/Comp_Percentage.tscn")
const PARAM_LIST: PackedScene = preload("res://UI_Components/Parameters/Comp_List.tscn")
const PARAM_OBJECT: PackedScene = preload("res://UI_Components/Parameters/Comp_Object.tscn")

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
	var parameters: Array[Dictionary]
	parameters.assign(_template[io][device_type]["parameters"])

	output = _generate_parameter_controls(parameters, existing_values_for_device)
	return output
	
## Handles spawning logic of single parameters along the JSON. Returns null if something is invalid
func spawn_parameter(parameter: Dictionary, possible_default_values: Dictionary = {}) -> BaseParameter:
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

	var default_value: Variant = null
	if label in possible_default_values:
		default_value = possible_default_values[label]
	elif default_value == null and "default" in parameter:
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
			(appending as CompList).setup_internals(_return_parameter_controls_list(parameter["element_type"], parameter["min_length"], default_value))
		"percentage":
			appending = PARAM_PERCENT.instantiate()
			(appending as CompPercentage).setup(label, description)
			if default_value:
				(appending as CompPercentage).set_value(default_value)
		"object":
			if "parameters" not in parameter:
				push_error("No parameter defined for object type parameter!")
				return null
			appending = PARAM_OBJECT.instantiate()
			(appending as CompObject).setup(label, description)
			var subparameters_array: Array[Dictionary]
			subparameters_array.assign(parameter["parameters"])
			(appending as CompObject).setup_internals(_generate_parameter_controls(subparameters_array, possible_default_values))
			
			
			

	
	return appending

func _return_parameter_controls_list(element_type: StringName, count: int, default: Array) -> Array[BaseParameter]:
	var building_list: Array[BaseParameter] = []
	var artificial_parameter: Dictionary = {
		"type" = element_type,
		"label" = element_type,
		"description" = ""
	}
	var appending: BaseParameter
	for i in range(count):
		if i < len(default):
			appending = spawn_parameter(artificial_parameter, default[i])
		else:
			appending = spawn_parameter(artificial_parameter)
	
		if appending != null:
			building_list.append(appending)
	
	return building_list

func _generate_parameter_controls(object_parameters: Array[Dictionary], existing_values_for_device: Dictionary = {}) -> Array[BaseParameter]:
	var building_list: Array[BaseParameter] = []
	# TODO logic for default values? Right now example output shows them as dict, discuss this
	for parameter: Dictionary in object_parameters:
		var object: BaseParameter = spawn_parameter(parameter, existing_values_for_device)
		if object != null:
			building_list.append(object)
	return building_list
