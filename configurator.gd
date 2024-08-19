extends PanelContainer
class_name Configurator

var _sensory: IO
var _motor: IO

func _ready() -> void:
	_sensory = $VBoxContainer/PanelContainer/TabContainer/Sensory
	_motor = $VBoxContainer/PanelContainer/TabContainer/Motor
	
	_sensory.setup(true)
	_motor.setup(false)

func export_capabilities() -> Dictionary:
	var capabilities: Dictionary = {}
	capabilities.merge(_sensory.export_as_dict())
	capabilities.merge(_motor.export_as_dict())
	return {"capabilities": capabilities}

func _generate_json() -> void:
	var capabilities: Dictionary = export_capabilities()
	var json: StringName = JSON.stringify(capabilities)
	var textbox: TextEdit = $"VBoxContainer/PanelContainer/TabContainer/Import and Export/MarginContainer/VBoxContainer/TextEdit"
	textbox.text = json
