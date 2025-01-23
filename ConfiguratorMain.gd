extends Node
class_name FEAGIMain
## The root node, handles general state of the application

var _template_data: FEAGIRobotConfigurationTemplateHolder

var _section_start: SectionStart
var _section_config_importer: BaseConfigImporter # NOTE: will be Null when not in use!
var _steps_holder: BoxContainer

func _ready() -> void:
	_section_start = $MarginContainer/BoxContainer/PanelContainer/MarginContainer/StepsHolder/SectionStart
	_steps_holder = $MarginContainer/BoxContainer/PanelContainer/MarginContainer/StepsHolder
	
	_template_data = FEAGIRobotConfigurationTemplateHolder.new()
	_template_data.fill_template_cache_from_template_JSON()
	

func _revert_to_start():
	if _section_config_importer:
		_section_config_importer.queue_free()
		_section_config_importer = null
	_section_start.visible = true
	_section_start.reset_UI()


func _import_file(UI: BaseConfigImporter, data: PackedByteArray, file_name: StringName) -> void:
	_section_start.visible = false
	_steps_holder.add_child(UI)
	_section_config_importer = UI
	UI.load_input_data(data, _template_data, file_name)
	UI.UI_import_fail.connect(_revert_to_start)
	UI.UI_import_successful.connect(_display_robot_config)

func _build_from_scratch() -> void:
	pass

func _display_robot_config(_robot_config: FEAGIRobotConfiguration) -> void:
	pass
