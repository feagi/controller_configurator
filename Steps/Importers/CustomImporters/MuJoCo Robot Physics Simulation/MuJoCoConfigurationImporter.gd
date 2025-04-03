extends BaseConfigImporter
class_name MuJoCoConfigurationImporter

var _failure: Control
var _success: Control
var _error_code: Label
var _continue: Button
var _tree: TreeSkeletonExplorer
var _edit: EditFEAGIDeviceByIO
var _http_request: HTTPRequest

func _ready() -> void:
	_failure = $Failure
	_success = $Success
	_error_code = $Failure/error
	_continue = $Options/Continue
	_tree = $Success/TreeAndDeviceEditor/Tree
	_edit = $Success/TreeAndDeviceEditor/EditFeagiDeviceByIO

## This should return the expected file extension as a string
func get_expected_file_extension() -> StringName:
	return "xml"

## Called on UI startup. Loads the raw bytes of the data. Make sure to verify data to be valid
func load_input_data(data: PackedByteArray, feagi_template: FEAGIRobotConfigurationTemplateHolder, _file_name: StringName) -> void:
	var XML_string: StringName = data.get_string_from_utf8()
	if XML_string == "":
		_error_code.text = "File does not appear to be a valid XML!"
		_error_import_state_UI(true)
		return
	
	var endpoint_URL: StringName = "https://us-east1-nrs-production.cloudfunctions.net/parser"
	
	if OS.get_name() == "Web":
		var JS_func_to_get_URL: StringName = """
		function getURL() {
			var url_string = window.location.href;
			var url = new URL(url_string);
			const searchParams = new URLSearchParams(url.search);
			return searchParams.get("parser_url");
		}
		"""
		var result: Variant = JavaScriptBridge.eval(JS_func_to_get_URL)
		if !result:
			push_error("Unable to get URL for endpoint, falling back to default...")
		elif result is String or result is StringName:
			endpoint_URL = result
	else:
		push_warning("Using fallback endpoint details as we dont have a way to get an up to date one")
		
	endpoint_URL += "?parser_type=mujoco"

	
	
	
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_raw( endpoint_URL, ["Content-Type: application/xml"], HTTPClient.METHOD_POST, data) # cloud
	var results: Array = await _http_request.request_completed
	_http_request.queue_free()
	_http_request = null

	if results[1] != 200:
		_error_code.text = "Unable to communicate with endpoint XML details!"
		_error_import_state_UI(true)
		return

	var JSON_string = results[3].get_string_from_utf8()
	if JSON_string == "":
		_error_code.text = "Endpoint did not return valid JSON!"
		_error_import_state_UI(true)
		return
	var JSON_check: Variant = JSON.parse_string(JSON_string)
	if !JSON_check:
		_error_code.text = "Endpoint did not return valid JSON!"
		_error_import_state_UI(true)
		return
	if JSON_check is not Array:
		_error_code.text = "Endpoint did not return valid JSON!"
		_error_import_state_UI(true)
		return


	_error_import_state_UI(false)
	_tree.setup(feagi_template, JSON_check)
	_edit.setup(feagi_template)


func _pressed_back() -> void:
	if _http_request:
		_http_request.cancel_request()
		_http_request.queue_free()
	UI_import_fail.emit()

func _pressed_continue() -> void:
	_edit.save_current_device_from_UI()
	UI_import_successful.emit(_tree.generate_robot_config())

func _error_import_state_UI(has_failed: bool) -> void:
	_failure.visible = has_failed
	_success.visible = !has_failed
	_continue.disabled = has_failed
	
	
