extends AbstractParameter
class_name ObjectParameter
# canm hold other objects

var value: Array[AbstractParameter] = []

## Creates the instance of the object given the JSON dict
static func create_from_template_JSON_dict(JSON_dict: Dictionary) -> ObjectParameter:
	var output: ObjectParameter = ObjectParameter.new()
	output.fill_in_metadata_from_JSON_dict(JSON_dict)
	if "parameters" in JSON_dict:
		if JSON_dict["parameters"] is not Array:
			push_error("Expected array of parameters for object parameter %s!" % output.label)
			return output
		var sub_dicts: Array = JSON_dict["parameters"]
		output.value = []
		for sub_dict in sub_dicts:
			if sub_dict is not Dictionary:
				push_error("Expected parameter array element to be a parameter JSON for object parameter %s!" % output.label)
				continue
			output.value.append(AbstractParameter.create_from_template_JSON_dict(sub_dict))
	return output
