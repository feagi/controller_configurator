extends PanelContainer
class_name DeviceType

var _box: VBoxContainer
var _header: Label


func _ready() -> void:
	_box = $DeviceType
	_header = $DeviceType/Label



func setup(title: StringName, description: StringName) -> void:
	name = title
	_header.text = title
	_header.tooltip_text = description

func spawn_device()
