extends VBoxContainer
class_name EditFEAGIDeviceByIO

const FEAGI_DEVICE_UI_PREFAB: PackedScene = preload("res://Steps/SectionEdit/Device/EditDevice.tscn")

var _robot_configuration_template: FEAGIRobotConfigurationTemplateHolder
var _current_device_UI: EditDevice = null
var _from_node: TreeItem = null
var _inputs: OptionButton
var _outputs: OptionButton
var _label: Label

func setup(robot_configuration_template: FEAGIRobotConfigurationTemplateHolder) -> void:
	_robot_configuration_template = robot_configuration_template
	_inputs = $HBoxContainer/Inputs
	_outputs = $HBoxContainer/Outputs
	_label = $HBoxContainer/Label
	
	for possible_input in _robot_configuration_template.get_possible_devices_from_template_cache(true):
		_inputs.add_item(possible_input)
	
	for possible_output in _robot_configuration_template.get_possible_devices_from_template_cache(false):
		_outputs.add_item(possible_output)

	

func show_FEAGI_device(feagi_device: FEAGIDevice, from_node: TreeItem) -> void:
	
	_label.text = "Change Device Type: "
	
	if feagi_device.is_input:
		_outputs.visible = false
		_inputs.visible = true
		_inputs.selected = _robot_configuration_template.get_possible_devices_from_template_cache(true).find(feagi_device.device_key)
	
	if feagi_device.is_input:
		_inputs.visible = false
		_outputs.visible = true
		_outputs.selected = _robot_configuration_template.get_possible_devices_from_template_cache(false).find(feagi_device.device_key)
	
	if _current_device_UI:
		if _from_node:
			var metadata: Dictionary = _from_node.get_metadata(0)
			if metadata.has("device"):
				metadata["device"] = _current_device_UI.export() # write the new device details
		
		_current_device_UI.queue_free()
		_current_device_UI = null
	
	_from_node = from_node
	
	_current_device_UI = FEAGI_DEVICE_UI_PREFAB.instantiate()
	add_child(_current_device_UI)
	_current_device_UI.setup_device(feagi_device)


func export_device() -> FEAGIDevice:
	if !_current_device_UI:
		push_error("No UI with a FEAGIDevice to export!")
		return null
	var device: FEAGIDevice = _current_device_UI.export()
	if !device:
		push_error("Unable to export device!")
	return device

func _device_type_changed(id: int) -> void:
	if !_current_device_UI:
		push_error("Unknown device class to change!")
		return
	
	var is_input: bool = _current_device_UI.is_input
	var options: Array[StringName] = _robot_configuration_template.get_possible_devices_from_template_cache(is_input)
	var selected_type: StringName = options[id]
	
	var new_FEAGI_device: FEAGIDevice = _robot_configuration_template.spawn_device_from_template(selected_type, is_input)
	if !new_FEAGI_device:
		push_error("Unable to spawn UI for device type %s!" % selected_type)
		return
	show_FEAGI_device(new_FEAGI_device, _from_node)
	
	
	
