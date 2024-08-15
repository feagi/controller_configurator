extends Object
class_name GlobalJSONEntityFactory

const SUPPORTED_TYPES: Array[StringName] = ["string", "boolean", "integer", "float"] # list, object

static func parse_parameters_for_device(parameters: Array) -> Array[Control]:
	var output: Array[Control] = []

	for parameter: Dictionary in parameters:
		if "type" not in parameter:
			push_error("No parameter type given!")
			continue
		if parameter["type"] not in SUPPORTED_TYPES:
			push_error("Uknown type $s!" % parameter["type"])
			continue
		
		
		
	return output


	
