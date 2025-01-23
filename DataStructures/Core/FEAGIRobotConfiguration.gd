extends Resource
class_name FEAGIRobotConfiguration
## Represents configurations for FEAGI robots (real or virtual)

@export var description: StringName = ""
@export var inputs: Array[FEAGIDevice] = []
@export var outputs: Array[FEAGIDevice] = []

static func create_from_device_listings(input_devices: Array[FEAGIDevice], output_devices: Array[FEAGIDevice], robot_description: StringName = "") -> FEAGIRobotConfiguration:
	var output: FEAGIRobotConfiguration = FEAGIRobotConfiguration.new()
	output.inputs = input_devices
	output.outputs = output_devices
	return output
