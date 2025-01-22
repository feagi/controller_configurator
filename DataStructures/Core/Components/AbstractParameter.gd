extends Resource
class_name AbstractParameter
## Abstract / base class for all Parameters

@export var label: StringName
@export var description: StringName

# NOTE: All [AbstractParameter] classes should have a value called "value" of their associated data type!

## Creates the instance of the object given the JSON dict
static func create_from_template_JSON_dict(JSON_dict: Dictionary) -> AbstractParameter:
	assert(false, "Method not overridden!")
	return null

## Given the dictionary for the parameter, returns the correct object generated and filled out
static func auto_create_from_template_JSON_dict(JSON_dict: Dictionary) -> AbstractParameter:
	if "type" not in JSON_dict:
		push_error("No type defined for given JSON!")
		return null
	match(JSON_dict["type"]):
		"string":
			return StringParameter.create_from_template_JSON_dict(JSON_dict)
		"boolean":
			return BooleanParameter.create_from_template_JSON_dict(JSON_dict)
		"integer":
			return IntegerParameter.create_from_template_JSON_dict(JSON_dict)
		"float":
			return FloatParameter.create_from_template_JSON_dict(JSON_dict)
		"vector3":
			return Vector3Parameter.create_from_template_JSON_dict(JSON_dict)
		"object":
			return ObjectParameter.create_from_template_JSON_dict(JSON_dict)
	push_error("Unknown paramter type %s!" % JSON_dict["type"])
	return null

## Given the dictionaries for the parameter array, returns the correct objects generated and filled out
static func auto_create_from_template_JSON_dict_array(JSON_dicts: Array[Dictionary]) -> Array[AbstractParameter]:
	var output: Array[AbstractParameter] = []
	for JSON_dict in JSON_dicts:
		var result: AbstractParameter = AbstractParameter.create_from_template_JSON_dict(JSON_dict)
		if !result:
			continue
		output.append(result)
	return output
	
func fill_in_metadata_from_template_JSON_dict(JSON_dict: Dictionary) -> void:
	if "label" in JSON_dict:
		label = JSON_dict["label"]
	if "description" in JSON_dict:
		description = JSON_dict["description"]

## Returns the parameter as a JSOn formattable dict
func get_as_JSON_formatable_dict() -> Dictionary:
	return {label: _get_value_as_JSON()}

## Returns the value of the object in a format that can be writted in a JSON. Should be overridden
func _get_value_as_JSON() -> Variant:
	assert(false, "Method not overridden!")
	return null
	
