extends BaseParameter
class_name CompString

var _string: LineEdit

func setup(property_name: StringName, description: StringName) -> void:
	_string = $Value
	base_setup(property_name, description)

func set_value(value: Variant) -> void:
	_string.text = value

func get_value() -> Variant:
	return _string.text
