extends Object
class_name GlobalJSONEntityFactory

const SUPPORTED_TYPES: Array[StringName] = ["string", "boolean", "integer", "float"] # list, object

const PARAM_BOOL: PackedScene = preload("res://JsonConfigurator/UI_Components/Comp_Bool.tscn")
const PARAM_STRING: PackedScene = preload("res://JsonConfigurator/UI_Components/Comp_String.tscn")
const PARAM_INT: PackedScene = preload("res://JsonConfigurator/UI_Components/Comp_Int.tscn")
const PARAM_FLOAT: PackedScene = preload("res://JsonConfigurator/UI_Components/Comp_Float.tscn")

## Parses from the global template json, as well as (optionally) the current device dict to get the array of controls making up the device parameters
static func parse_parameters_for_device(parameters: Array, existing_values_for_device: Dictionary = {}) -> Array[Control]:
	var output: Array[Control] = []

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


	
