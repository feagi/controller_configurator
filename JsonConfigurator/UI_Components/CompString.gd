@tool
extends BaseUIComponent
class_name CompString

var _string: LineEdit

func _ready() -> void:
	super()
	_string = $Value

func setup(property_name: StringName, initial_value: StringName, placeholder_text: StringName) -> void:
	_name.text = property_name
	_string.text = initial_value
	_string.placeholder_text = placeholder_text

func get_value_as_string() -> StringName:
	return _string.text

func set_value_as_string(value: StringName):
	_string.text = value
	return
