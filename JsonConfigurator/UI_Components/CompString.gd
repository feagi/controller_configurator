@tool
extends BaseUIComponent
class_name CompString

var _string: LineEdit

func _ready() -> void:
	super()
	_string = $Value

func setup(property_name: StringName, description: StringName) -> void:
	base_setup(property_name, description)

func set_value(value: Variant) -> void:
	_string.text = value

func get_value() -> Variant:
	return _string.text
