@tool
extends BaseUIComponent
class_name CompFloat

var _float: SpinBox

func _ready() -> void:
	super()
	_float = $Value

func setup(property_name: StringName, min_value: int, max_value: int, starting_value: int) -> void:
	_name.text = property_name
	_float.min_value = min_value
	_float.max_value = max_value
	_float.value = starting_value

func get_value_as_string() -> StringName:
	return str(float(_float.value))

func set_value_as_string(value: StringName):
	_float.value = value.to_float()
	return
