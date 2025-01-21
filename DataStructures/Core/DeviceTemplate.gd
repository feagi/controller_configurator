extends Resource
class_name FEAGIDevice
## Represents a device that can be exported for FEAGI. Loaded as templates but can also hgold specific values for live use

var device_key: StringName
var label: StringName
var description: StringName

var parameters: Array[AbstractParameter] = []

static func create_from_template(JSON_dict: Dictionary, device_key_name: StringName) -> FEAGIDevice:
	var output: FEAGIDevice = FEAGIDevice.new()
	output.device_key = device_key_name
	if "label" in JSON_dict:
		output.label = JSON_dict["label"]
	if "description" in JSON_dict:
		output.description = JSON_dict['description']
	if "parameters" in JSON_dict:
		output.parameters = AbstractParameter.auto_create_from_template_JSON_dict_array(JSON_dict["parameters"])
	return output
	
