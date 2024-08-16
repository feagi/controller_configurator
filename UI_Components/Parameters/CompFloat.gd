extends BaseParameter
class_name CompFloat

var _float: SpinBox


func setup(property_name: StringName, description: StringName) -> void:
	_float = $Value
	base_setup(property_name, description)

func set_value(value: Variant) -> void:
	_float.value = value

func get_value() -> Variant:
	return _float.value
