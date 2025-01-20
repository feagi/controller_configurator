extends AbstractParameter
class_name IntegerParameter

var value: int = 0
var default: int = 0
var minimum: int = 0
var maximum: int = 100

## Creates the instance of the object given the JSON dict
static func create_from_template_JSON_dict(JSON_dict: Dictionary) -> IntegerParameter:
	var output: IntegerParameter = IntegerParameter.new()
	output.fill_in_metadata_from_JSON_dict(JSON_dict)
	if "default" in JSON_dict:
		output.default = JSON_dict["default"]
	if "minimum" in JSON_dict:
		output.default = JSON_dict["minimum"]
	if "maximum" in JSON_dict:
		output.default = JSON_dict["maximum"]
	return output
