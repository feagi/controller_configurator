extends Node
class_name FEAGIMain
## The root node, handles general state of the application

var _template_data: FEAGIRobotConfigurationTemplateHolder

func _ready() -> void:
	_template_data = FEAGIRobotConfigurationTemplateHolder.new()
	_template_data.fill_template_cache_from_template_JSON()
