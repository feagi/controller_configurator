extends BaseParameter
class_name CompInt

var _int: SpinBox
	
func setup(property_name: StringName, description: StringName) -> void:
	_int = $Value
	base_setup(property_name, description)

func set_value(value: Variant) -> void:
	_int.value = value

func get_value() -> Variant:
	return _int.value
