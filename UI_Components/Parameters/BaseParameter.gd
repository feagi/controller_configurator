extends HBoxContainer
class_name BaseParameter
## Semi-surperflous base class for setting name / value objects


func base_setup(label: StringName, description: StringName) -> void:
	var label_text: Label = $Label
	label_text.text = label
	label_text.tooltip_text = description
	name = label

func set_value(_value: Variant) -> void:
	pass

func get_value() -> Variant:
	return null
