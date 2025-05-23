extends BoxContainer
class_name BaseConfigImporter
## All importer UIs inherit from this to ensure they have the proper methods

@warning_ignore("unused_signal")
signal UI_import_successful(robot_config: FEAGIRobotConfiguration) ## Completed a robot config import
@warning_ignore("unused_signal")
signal UI_import_fail() ## User clicked back or import is broken, this exists the UI


## Called on UI startup. Loads the raw bytes of the data. Make sure to verify data to be valid
func load_input_data(_data: PackedByteArray, _feagi_template: FEAGIRobotConfigurationTemplateHolder, _file_name: StringName) -> void:
	assert(false, "This method was not overridden!")
	pass # fill in function in your use case

## This should return the expected file extension as a string
func get_expected_file_extension() -> StringName:
	assert(false, "This method was not overridden!")
	return ""
