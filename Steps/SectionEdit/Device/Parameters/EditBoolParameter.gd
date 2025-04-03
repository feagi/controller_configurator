extends EditAbstractParameter
class_name EditBoolParameter

var _bool: CheckBox

func setup(parameter: BooleanParameter) -> void:
	base_setup(parameter)
	_bool = $Value
	_bool.button_pressed = parameter.value
	
func export() -> AbstractParameter:
	var parameter: BooleanParameter = super()
	parameter.value = _bool.button_pressed
	return parameter
