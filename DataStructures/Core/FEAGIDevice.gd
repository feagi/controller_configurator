extends Resource
class_name FEAGIDevice
## Represents a device that can be exported for FEAGI. Loaded as templates but can also hgold specific values for live use

@export var device_key: StringName
@export var label: StringName
@export var description: StringName
@export var is_input: bool

@export var parameters: Array[AbstractParameter] = []

static func create_from_template(JSON_dict: Dictionary, device_key_name: StringName, is_device_input_device: bool) -> FEAGIDevice:
	var output: FEAGIDevice = FEAGIDevice.new()
	output.is_input = is_device_input_device
	output.device_key = device_key_name
	if "label" in JSON_dict:
		output.label = JSON_dict["label"]
	if "description" in JSON_dict:
		output.description = JSON_dict['description']
	if "parameters" in JSON_dict:
		var params: Array[Dictionary]
		params.assign(JSON_dict["parameters"])
		output.parameters = AbstractParameter.auto_create_from_template_JSON_dict_array(params)
	return output

## Attempts to update multiple parameters by their label names key'd to their value
func overwrite_parameter_values(parameter_labels_and_values: Dictionary) -> void:
	for parameter_label in parameter_labels_and_values: # NOTE: This isnt particularly efficient since we are using for loops twice. Too bad!
		overwrite_parameter_value(parameter_label, parameter_labels_and_values[parameter_label])
		
## Attempts to overwrite the parameter by name of the device. Returns true if success 
func overwrite_parameter_value(parameter_label: StringName, value: Variant) -> bool:
	for parameter in parameters:
		if parameter_label == parameter.label:
			if typeof(value) == parameter.value_type:
				parameter.value = value
				return true
			else:
				push_error("Unable to update parameter %s of device %s as parameter is of type %s and given value is %s!" % [parameter_label, label, type_string(parameter.value_type), type_string(typeof(value))])
				return false
		continue
	push_error("Unable to find parameter %s to update in device %s!" % [parameter_label, label])
	return false

func get_as_JSON_formatable_dict(device_ID_index: int) -> Dictionary:
	var parameter_JSONable: Dictionary = {}
	for parameter in parameters:
		parameter_JSONable.merge(parameter.get_as_JSON_formatable_dict())
	return {str(device_ID_index): parameter_JSONable}
