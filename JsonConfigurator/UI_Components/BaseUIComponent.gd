@tool
extends HBoxContainer
class_name BaseUIComponent
## Semi-surperflous base class for setting name / value objects

var _name: Label

func _ready() -> void:
	_name = $Label

# NOTE: Override this in all child classes
func get_value_as_string() -> StringName:
	return ""

# NOTE: Override this in all child classes
func set_value_as_string(value: StringName):
	return
