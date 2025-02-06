extends BaseConfigImporter
class_name MuJoCoConfigurationImporter

var _failure: Control
var _success: Control
var _error_code: Label
var _continue: Button
var _tree: TreeSkeletonExplorer
var _edit: EditFEAGIDeviceByIO

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
	
	var root_node: TreeItem = _tree.create_item()

	## TEMP
	var recurse: Array = [{"name":"torso","type":"body","description":"","children":[{"name":"head","type":"body","description":"","children":[]},{"name":"waist_lower","type":"body","description":"","children":[{"name":"abdomen_z","type":"output","feagi device type":"servo","properties":{"name":"abdomen_z","pos":"0 0 .065","axis":"0 0 1","range":"-45 45","class":"joint_big_stiff"},"description":"","children":[]},{"name":"abdomen_y","type":"output","feagi device type":"servo","properties":{"name":"abdomen_y","pos":"0 0 .065","axis":"0 1 0","range":"-75 30","class":"joint_big"},"description":"","children":[]},{"name":"pelvis","type":"body","description":"","children":[{"name":"abdomen_x","type":"output","feagi device type":"servo","properties":{"name":"abdomen_x","pos":"0 0 .1","axis":"1 0 0","range":"-35 35","class":"joint_big"},"description":"","children":[]},{"name":"thigh_right","type":"body","description":"","children":[{"name":"hip_x_right","type":"output","feagi device type":"servo","properties":{"name":"hip_x_right","axis":"1 0 0","class":"hip_x"},"description":"","children":[]},{"name":"hip_z_right","type":"output","feagi device type":"servo","properties":{"name":"hip_z_right","axis":"0 0 1","class":"hip_z"},"description":"","children":[]},{"name":"hip_y_right","type":"output","feagi device type":"servo","properties":{"name":"hip_y_right","class":"hip_y"},"description":"","children":[]},{"name":"shin_right","type":"body","description":"","children":[{"name":"knee_right","type":"output","feagi device type":"servo","properties":{"name":"knee_right","class":"knee"},"description":"","children":[]},{"name":"foot_right","type":"body","description":"","children":[{"name":"ankle_y_right","type":"output","feagi device type":"servo","properties":{"name":"ankle_y_right","class":"ankle_y"},"description":"","children":[]},{"name":"ankle_x_right","type":"output","feagi device type":"servo","properties":{"name":"ankle_x_right","class":"ankle_x","axis":"1 0 .5"},"description":"","children":[]}]}]}]},{"name":"thigh_left","type":"body","description":"","children":[{"name":"hip_x_left","type":"output","feagi device type":"servo","properties":{"name":"hip_x_left","axis":"-1 0 0","class":"hip_x"},"description":"","children":[]},{"name":"hip_z_left","type":"output","feagi device type":"servo","properties":{"name":"hip_z_left","axis":"0 0 -1","class":"hip_z"},"description":"","children":[]},{"name":"hip_y_left","type":"output","feagi device type":"servo","properties":{"name":"hip_y_left","class":"hip_y"},"description":"","children":[]},{"name":"shin_left","type":"body","description":"","children":[{"name":"knee_left","type":"output","feagi device type":"servo","properties":{"name":"knee_left","class":"knee"},"description":"","children":[]},{"name":"foot_left","type":"body","description":"","children":[{"name":"ankle_y_left","type":"output","feagi device type":"servo","properties":{"name":"ankle_y_left","class":"ankle_y"},"description":"","children":[]},{"name":"ankle_x_left","type":"output","feagi device type":"servo","properties":{"name":"ankle_x_left","class":"ankle_x","axis":"-1 0 -.5"},"description":"","children":[]}]}]}]}]}]},{"name":"upper_arm_right","type":"body","description":"","children":[{"name":"shoulder1_right","type":"output","feagi device type":"servo","properties":{"name":"shoulder1_right","axis":"2 1 1","class":"shoulder"},"description":"","children":[]},{"name":"shoulder2_right","type":"output","feagi device type":"servo","properties":{"name":"shoulder2_right","axis":"0 -1 1","class":"shoulder"},"description":"","children":[]},{"name":"lower_arm_right","type":"body","description":"","children":[{"name":"elbow_right","type":"output","feagi device type":"servo","properties":{"name":"elbow_right","axis":"0 -1 1","class":"elbow"},"description":"","children":[]},{"name":"hand_right","type":"body","description":"","children":[]}]}]},{"name":"upper_arm_left","type":"body","description":"","children":[{"name":"shoulder1_left","type":"output","feagi device type":"servo","properties":{"name":"shoulder1_left","axis":"-2 1 -1","class":"shoulder"},"description":"","children":[]},{"name":"shoulder2_left","type":"output","feagi device type":"servo","properties":{"name":"shoulder2_left","axis":"0 -1 -1","class":"shoulder"},"description":"","children":[]},{"name":"lower_arm_left","type":"body","description":"","children":[{"name":"elbow_left","type":"output","feagi device type":"servo","properties":{"name":"elbow_left","axis":"0 -1 -1","class":"elbow"},"description":"","children":[]},{"name":"hand_left","type":"body","description":"","children":[]}]}]}]}]
	
	_tree.setup(feagi_template, recurse)
	_edit.setup(feagi_template)


func _pressed_back() -> void:
	UI_import_fail.emit()

func _pressed_continue() -> void:
	_edit.save_current_device_from_UI()
	UI_import_successful.emit(_tree.generate_robot_config())
