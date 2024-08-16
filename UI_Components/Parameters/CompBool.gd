extends BaseParameter
class_name CompBool

var _bool: CheckBox

func _ready() -> void:
	super()
	_bool = $Value

func setup(property_name: StringName, description: StringName) -> void:
	base_setup(property_name, description)

func set_value(value: Variant) -> void:
	_bool.button_pressed = value

func get_value() -> Variant:
	return _bool.button_pressed
