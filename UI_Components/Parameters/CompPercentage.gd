extends BaseParameter
class_name CompPercentage

var _percent: SpinBox
	
func setup(property_name: StringName, description: StringName) -> void:
	_percent = $Value
	base_setup(property_name, description)

func set_value(value: Variant) -> void:
	_percent.value = value

func get_value() -> Variant:
	return _percent.value
