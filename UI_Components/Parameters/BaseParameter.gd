@tool
extends HBoxContainer
class_name BaseParameter
## Semi-surperflous base class for setting name / value objects

var _name: Label

func _ready() -> void:
	_name = $Label

func base_setup(label: StringName, description: StringName) -> void:
	_name.text = label
	_name.tooltip_text = description
	name = label

func set_value(value: Variant) -> void:
	pass

func get_value() -> Variant:
	return null
