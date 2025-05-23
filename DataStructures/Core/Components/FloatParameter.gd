extends AbstractParameter
class_name FloatParameter

@export var value: float = NAN # use default if NAN cause not initialized
@export var default: float = 0
@export var minimum: float = 0
@export var maximum: float = 100

func _init() -> void:
	value_type = TYPE_FLOAT

## Creates the instance of the object given the JSON dict
static func create_from_template_JSON_dict(JSON_dict: Dictionary) -> FloatParameter:
	var output: FloatParameter = FloatParameter.new()
	output.fill_in_metadata_from_template_JSON_dict(JSON_dict)
	if "default" in JSON_dict:
		output.default = JSON_dict["default"]
	if "minimum" in JSON_dict:
		output.default = JSON_dict["minimum"]
	if "maximum" in JSON_dict:
		output.default = JSON_dict["maximum"]
	return output

func _get_value_as_JSON() -> Variant:
	return value
