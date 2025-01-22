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
		output.parameters = AbstractParameter.auto_create_from_template_JSON_dict_array(JSON_dict["parameters"])
	return output
	
func get_as_JSON_formatable_dict(device_ID_index: int) -> Dictionary:
	var parameter_JSONable: Dictionary = {}
	for parameter in parameters:
		parameter_JSONable.merge(parameter.get_as_JSON_formatable_dict())
	return {str(device_ID_index): parameter_JSONable}
