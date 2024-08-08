@tool
extends BaseUIComponent
class_name CompInt

var _int: SpinBox

func _ready() -> void:
	super()
	_int = $Value

func setup(property_name: StringName, min_value: int, max_value: int, starting_value: int) -> void:
	_name.text = property_name
	_int.min_value = min_value
	_int.max_value = max_value
	_int.value = starting_value

func get_value_as_string() -> StringName:
	return str(int(_int.value))

func set_value_as_string(value: StringName):
	_int.value = value.to_int()
	return
