extends BaseConfigImporter
class_name MuJoCoConfigurationImporter

var _failure: Control
var _success: Control
var _error_code: Label
var _continue: Button

func _ready() -> void:
	_failure = $Failure
	_success = $Success
	_error_code = $Failure/error
	_continue = $Options/Continue

## This should return the expected file extension as a string
func get_expected_file_extension() -> StringName:
	return "xml"

## Called on UI startup. Loads the raw bytes of the data. Make sure to verify data to be valid
func load_input_data(data: PackedByteArray, feagi_template: FEAGIRobotConfigurationTemplateHolder, _file_name: StringName) -> void:
	var XML_parser: XMLParser = XMLParser.new()
	var import_err: Error  = XML_parser.open_buffer(data)

	_success.visible = true
	_failure.visible = false

	if import_err:
		_success.visible = false
		_failure.visible = true
		_error_code.text = "Unable to open given file as an XML!"
		return
	
	
