extends EditAbstractParameter
class_name EditStringParameter

var _string: LineEdit

func setup(parameter: StringParameter) -> void:
	base_setup(parameter)
	_string = $Value
	_string.text = parameter.value
	

func export() -> AbstractParameter:
	var parameter: StringParameter = super()
	parameter.value = _string.value
	return parameter
