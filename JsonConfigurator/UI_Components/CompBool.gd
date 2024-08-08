@tool
extends BaseUIComponent
class_name CompBool

var _bool: CheckBox

func _ready() -> void:
	super()
	_bool = $Value

func setup(property_name: StringName, starting_value_str: StringName) -> void:
	_name.text = property_name
	set_value_as_string(starting_value_str)

func get_value_as_string() -> StringName:
	if _bool.button_pressed:
		return "true"
	else:
		return "false"

func set_value_as_string(value: StringName):
	_bool.button_pressed = value == "true"
