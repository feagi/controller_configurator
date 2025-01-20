extends AbstractParameter
class_name BooleanParameter

var value: bool = false
var default: bool = false

## Creates the instance of the object given the JSON dict
static func create_from_template_JSON_dict(JSON_dict: Dictionary) -> BooleanParameter:
	var output: BooleanParameter = BooleanParameter.new()
	output.fill_in_metadata_from_JSON_dict(JSON_dict)
	if "default" in JSON_dict:
		output.default = JSON_dict["default"]
	return output
	
