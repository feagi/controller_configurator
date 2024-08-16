extends PanelContainer
class_name Device

var _holder: VBoxContainer

func _ready() -> void:
	_holder = $VBoxContainer

func setup(parameters: Array[Control]) -> void:
	for parameter in parameters:
		_holder.add_child(parameter)

func get_physical_ID() -> int:
	return get_index()
