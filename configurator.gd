extends PanelContainer
class_name Configurator

var _sensory: IO
var _motor: IO

func _ready() -> void:
	_sensory = $VBoxContainer/PanelContainer/TabContainer/Sensory
	_motor = $VBoxContainer/PanelContainer/TabContainer/Motor
	
	_sensory.setup(true)
	_motor.setup(false)
