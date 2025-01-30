extends BaseConfigImporter
class_name MuJoCoConfigurationImporter

var _failure: Control
var _success: Control
var _error_code: Label
var _continue: Button
var _tree: Tree

func _ready() -> void:
	_failure = $Failure
	_success = $Success
	_error_code = $Failure/error
	_continue = $Options/Continue
	_tree = $Success/HBoxContainer/Import/tree

## This should return the expected file extension as a string
func get_expected_file_extension() -> StringName:
	return "xml"

## Called on UI startup. Loads the raw bytes of the data. Make sure to verify data to be valid
func load_input_data(data: PackedByteArray, feagi_template: FEAGIRobotConfigurationTemplateHolder, _file_name: StringName) -> void:
	
	var root_node: TreeItem = _tree.create_item()
	
	var recurse: Dictionary = {
  "0": {
	"type": "body",
	"label": "torso1",
	"children": {
	  "0_0": {
		"type": "body",
		"label": "hand"
	  },
	  "0_1": {
		"type": "input",
		"subtype": "gyro",
		"label": "top_left_arm_gyro"
	  },
	  "0_2": {
		"type": "input",
		"subtype": "servo_location",
		"label": "top_left_arm_servo_location1"
	  },
	   "0_3": {
		"type": "input",
		"subtype": "servo_location",
		"label": "top_left_arm_servo_location2"
	  },
	   "0_4": {
		"type": "output",
		"subtype": "servo_motor",
		"label": "top_left_arm_servo_motor1"
	  }
	}
  },
  "1": {
	"type": "body",
	"label": "torso2",
	"children": {
	  "0_0": {
		"type": "body",
		"label": "hand"
	  },
	  "0_1": {
		"type": "input",
		"subtype": "gyro",
		"label": "top_left_arm_gyro"
	  },
	  "0_2": {
		"type": "input",
		"subtype": "servo_location",
		"label": "top_left_arm_servo_location1"
	  },
	   "0_3": {
		"type": "input",
		"subtype": "servo_location",
		"label": "top_left_arm_servo_location2"
	  },
	   "0_4": {
		"type": "output",
		"subtype": "servo_motor",
		"label": "top_left_arm_servo_motor1"
	  }
	}
  }
}
	_temp(recurse, root_node)
	
	
	
	return
	var XML_parser: XMLParser = XMLParser.new()
	var import_err: Error  = XML_parser.open_buffer(data)

	_success.visible = true
	_failure.visible = false

	if import_err:
		_success.visible = false
		_failure.visible = true
		_error_code.text = "Unable to open given file as an XML!"
		return
	
	
func _temp(dict: Dictionary, parent_node: TreeItem) -> void:
	for key in dict:
		var child_node: TreeItem = parent_node.create_child()
		child_node.set_text(0, key)
		if dict[key] is Dictionary:
			_temp(dict[key], child_node)
		else:
			var double_child: TreeItem = child_node.create_child()
			double_child.set_text(0, dict[key])
	
