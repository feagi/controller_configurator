extends BaseConfigImporter
class_name FeagiConfiguratorImporter

var _cached_robot_config: FEAGIRobotConfiguration

var _failure: Control
var _success: Control
var _error_code: Label
var _continue: Button

func _ready() -> void:
	_failure = $Failure
	_success = $Success
	_error_code = $Failure/error
	_continue = $Options/Continue

## Called on UI startup. Loads the raw bytes of the data. Make sure to verify data to be valid
func load_input_data(_data: PackedByteArray, feagi_template: FEAGIRobotConfigurationTemplateHolder, file_name: StringName) -> void:
	var JSON_string = _data.get_string_from_utf8()
	if JSON_string == "":
		_error_code.text = "File does not appear to be a valid JSON!"
		return
	var JSON_check: Variant = JSON.parse_string(JSON_string)
	if !JSON_check:
		_error_code.text = "File does not appear to be a valid JSON!"
		return
	if JSON_check is not Dictionary:
		_error_code.text = "File does not appear to be a valid FEAGI Robot Configurator JSON\n(not a dictionary)!"
		return
	
	var JSON_import: Dictionary = JSON_check
	
	if not _assert_key_valid(JSON_import, "capabilities", TYPE_DICTIONARY):
		_error_code.text = "File does not appear to be a valid FEAGI Robot Configurator JSON!\n(missing capabilities)"
		return
	
	var capabilities: Dictionary = JSON_import["capabilities"]
	
	if (!_assert_key_valid(capabilities, "input", TYPE_DICTIONARY)) or (!_assert_key_valid(capabilities, "output", TYPE_DICTIONARY)):
		_error_code.text = "File does not appear to be a valid FEAGI Robot Configurator JSON!\n(missing input/output)"
		return
	
	_failure.visible = false
	_success.visible = true
	_continue.disabled = false
	
	var input_devices: Array[FEAGIDevice] = []
	var output_devices: Array[FEAGIDevice] = []
	
	_load_devices(input_devices, capabilities["input"], feagi_template, true)
	_load_devices(output_devices, capabilities["output"], feagi_template, false)
	
	_cached_robot_config = FEAGIRobotConfiguration.create_from_device_listings(input_devices, output_devices)


## This should return the expected file extension as a string
func get_expected_file_extension() -> StringName:
	return "json"

func _pressed_back() -> void:
	UI_import_fail.emit()

func _forward_pressed() -> void:
	UI_import_successful.emit(_cached_robot_config)


## Loads devices from config JSON into the input/output array as [FEAGIDevice] objects
func _load_devices(array_target: Array[FEAGIDevice], devices_JSON_dict: Dictionary, feagi_template: FEAGIRobotConfigurationTemplateHolder, is_input: bool) -> void:
	for device_type in devices_JSON_dict:
		if !feagi_template.is_device_type_valid(device_type, is_input):
			push_error("Unknown device type '%s'!" % device_type)
			continue
		
		if not _assert_key_valid(devices_JSON_dict, device_type, TYPE_DICTIONARY):
			push_error("Unknown data for device type '%s'!" % device_type)
			continue
		for device_ID in devices_JSON_dict[device_type]:			
			if !(device_ID as String).is_valid_int():
				push_error("'%s' is not a valid ID under device type '%s'!" % [str(device_ID), device_type])
				continue
			
			if not _assert_key_valid(devices_JSON_dict[device_type], device_ID, TYPE_DICTIONARY):
				push_error("Unknown data for device type '%s' ID '%s!" % [device_type, str(device_ID)])
				continue
			
			var device_JSON_dict: Dictionary = devices_JSON_dict[device_type][device_ID]
			var device: FEAGIDevice = feagi_template.spawn_device_from_template(device_type, is_input)
			device.overwrite_parameter_values(device_JSON_dict)
			array_target.append(device)
			

## Returns true if dictionary contains key with expected value type. otherwise returns false
func _assert_key_valid(dict: Dictionary, key: String, expected_value_type: Variant.Type) -> bool:
	if key not in dict:
		push_error("Missing key %s!" % key)
		return false
	if typeof(dict[key]) != expected_value_type:
		push_error("Expected value of type '%s' for key '%s' but recieved type '%s'!" % [type_string(expected_value_type), key, type_string(typeof(dict[key]))])
		return false
	return true
