extends BoxContainer
class_name BaseConfigImporter
## All importer UIs inherit from this to ensure they have the proper methods

signal UI_import_successful(robot_config: FEAGIRobotConfiguration) ## Completed a robot config import
signal UI_import_fail() ## User clicked back or import is broken, this exists the UI


## Given the data the user loaded, verify it is valid, and update your UI accordingly
func loaded_input_data(_data: PackedByteArray) -> void:
	assert(false, "This method was not overridden!")
	pass # fill in function in your use case

## This should return the expected file extension as a string
func get_expected_file_extension() -> StringName:
	assert(false, "This method was not overridden!")
	return ""
