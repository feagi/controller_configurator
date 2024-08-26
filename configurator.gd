extends PanelContainer
class_name Configurator

var _sensory: IO
var _motor: IO
var _textbox: TextEdit

func _ready() -> void:
	_sensory = $VBoxContainer/PanelContainer/TabContainer/Sensory
	_motor = $VBoxContainer/PanelContainer/TabContainer/Motor
	_textbox = $"VBoxContainer/PanelContainer/TabContainer/Import and Export/MarginContainer/VBoxContainer/TextEdit"
	
	_sensory.setup(true)
	_motor.setup(false)

func export_capabilities() -> Dictionary:
	var capabilities: Dictionary = {}
	capabilities.merge(_sensory.export_as_dict())
	capabilities.merge(_motor.export_as_dict())
	return {"capabilities": capabilities}

func clear_UI() -> void:
	_sensory.clear_UI()
	_motor.clear_UI()

func _generate_json() -> void:
	var capabilities: Dictionary = export_capabilities()
	var json: StringName = JSON.stringify(capabilities, "\t")
	_textbox.text = json

func _import_json() -> void:
	var raw_import: Variant = JSON.parse_string(_textbox.text)
	if !raw_import:
		push_error("Inputted string does not seem to be a valid JSON object!")
		return
	if raw_import is Array:
		push_error("JSON expected to be a dictionary!")
		return
	if "capabilities" not in (raw_import as Dictionary):
		print("'Capabilities' Key Expected!")
		return
	var capabilities: Dictionary = (raw_import as Dictionary)["capabilities"]
	if "input" not in capabilities:
		print("'input' Key Expected!")
		return
	if "output" not in capabilities:
		print("'output' Key Expected!")
		return
	 # at this point, we likely have something valid. clear the current stuff and prepare to import new
	clear_UI()
	
	
