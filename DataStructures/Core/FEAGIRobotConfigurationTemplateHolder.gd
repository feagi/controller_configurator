extends RefCounted
class_name FEAGIRobotConfigurationTemplateHolder

const TEMPLATE_JSON_PATH: StringName = "res://template.json"

var _cached_input_device_templates: Dictionary = {}
var _cached_output_device_templates: Dictionary = {}

## Ran first thing to initialize the cache with the devices from the templates
func fill_template_cache_from_template_JSON() -> void:
	var template_dict: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(TEMPLATE_JSON_PATH))
	if !template_dict or len(template_dict) == 0:
		assert(false, "Unable to read template JSON!")
	assert("input" in template_dict, "Unable to read inputs from template JSON!")
	assert("output" in template_dict, "Unable to read outputs from template JSON!")
	_write_device_templates_to(_cached_input_device_templates, template_dict["input"], true)
	_write_device_templates_to(_cached_output_device_templates, template_dict["output"], false)

## Get a list of all possible input / output devices from the template cache
func get_possible_devices_from_template_cache(from_input: bool) -> Array[StringName]:
	var output: Array[StringName] 
	if from_input:
		output.assign(_cached_input_device_templates.keys())
	else:
		output.assign(_cached_output_device_templates.keys())
	return output

## From the template, tries to spawn a copy of a device by name. Returns null if device name is invalid
func spawn_device_from_template(device_name: StringName, is_input_device: bool) -> FEAGIDevice:
	var dict_ref: Dictionary = _cached_output_device_templates
	if is_input_device:
		dict_ref = _cached_input_device_templates
	if device_name not in dict_ref:
		return null
	var template_ref: FEAGIDevice = dict_ref[device_name]
	return template_ref.duplicate()

func is_device_type_valid(device_type: StringName, is_input: bool) -> bool:
	if is_input:
		return device_type in _cached_input_device_templates
	else:
		return device_type in _cached_output_device_templates

func _write_device_templates_to(target_write: Dictionary, template_IO_source: Dictionary, is_input: bool) -> void:
	# where "template_IO_source" is CONFIG_JSON[output/input]
	for device_name in template_IO_source:
		target_write[device_name] = FEAGIDevice.create_from_template(template_IO_source[device_name], device_name, is_input)
