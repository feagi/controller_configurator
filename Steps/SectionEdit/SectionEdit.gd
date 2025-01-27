extends BoxContainer
class_name SectionEdit

var _inputs: EditIO
var _outputs: EditIO

var _template_ref: FEAGIRobotConfigurationTemplateHolder

signal user_requests_saving_configurator_as_JSON_dict(robot_config_as_JSON_dict: Dictionary)
signal user_requests_going_back()

func setup(template: FEAGIRobotConfigurationTemplateHolder) -> void:
	_inputs = $Inputs
	_outputs = $Outputs
	_inputs.setup(template.get_possible_devices_from_template_cache(true))
	_outputs.setup(template.get_possible_devices_from_template_cache(false))
	_template_ref = template


func load_config(defined_config: FEAGIRobotConfiguration) -> void:

	# TODO robot description?
	
	for device in defined_config.inputs:
		_inputs.add_device(device)
	for device in defined_config.outputs:
		_outputs.add_device(device)

func reset_view() -> void:
	_inputs.reset()
	_outputs.reset()

func _add_device(device_name: StringName, is_input_device: bool) -> void:
	var device: FEAGIDevice = _template_ref.spawn_device_from_template(device_name, is_input_device)
	if !device:
		push_error("Invalid device %s!" % device_name)
		return
	if is_input_device:
		_inputs.add_device(device)
	else:
		_outputs.add_device(device)

func _user_pressed_back() -> void:
	user_requests_going_back.emit()


func _user_requests_saving_config() -> void:
	var dictionary: Dictionary = { "capapabilities": { } }
	dictionary["capapabilities"].merge(_inputs.export_as_FEAGI_configurator_JSON())
	dictionary["capapabilities"].merge(_outputs.export_as_FEAGI_configurator_JSON())
	user_requests_saving_configurator_as_JSON_dict.emit(dictionary)
