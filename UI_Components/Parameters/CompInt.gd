extends BaseParameter
class_name CompInt

var _int: SpinBox

func _ready() -> void:
	super()
	_int = $Value
	
func setup(property_name: StringName, description: StringName) -> void:
	base_setup(property_name, description)

func set_value(value: Variant) -> void:
	_int.value = value

func get_value() -> Variant:
	return _int.value
