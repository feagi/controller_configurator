extends AbstractParameter
class_name StringParameter

var value: StringName

## Creates the instance of the object given the JSON dict
static func create_from_template_JSON_dict(JSON_dict: Dictionary) -> StringParameter:
	var output: StringParameter = StringParameter.new()
	output.fill_in_metadata_from_JSON_dict(JSON_dict)
	return output
