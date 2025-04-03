extends VBoxContainer
class_name EditIO
## Handles input / output panels

const DEIVCE_CATEGORAY_PREFAB: PackedScene = preload("res://Steps/SectionEdit/Device/EditDeviceCategory.tscn")

@export var is_input: bool

var _add_device_dropdown: OptionButton
var _device_category_holder: VBoxContainer

signal request_adding_device(device_name: StringName, is_input_device: bool)

func setup(device_type_names: Array[StringName]) -> void:
	_add_device_dropdown = $HBoxContainer/OptionButton
	_device_category_holder = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer
	for device_type_name in device_type_names:
		_add_device_dropdown.add_item(device_type_name)
	_add_device_dropdown.selected = 0

func add_device(device_definition: FEAGIDevice) -> void:
	for child in _device_category_holder.get_children():
		if child is not EditDeviceCategory:
			continue
		if child.name != device_definition.device_key:
			continue
		# we found an existing device category
		(child as EditDeviceCategory).spawn_device(device_definition)
		return
	# no device category exists, spawn one and then add the device to it
	var category: EditDeviceCategory = DEIVCE_CATEGORAY_PREFAB.instantiate()
	category.setup(is_input, device_definition.device_key, device_definition.description)
	_device_category_holder.add_child(category)
	category.spawn_device(device_definition)
	category.request_adding_device.connect(func(device_name: StringName, is_input_device: bool): request_adding_device.emit(device_name, is_input_device))

## Exports dictionary for configurator as {"input/output" : { "device_category: ... } }
func export_as_FEAGI_configurator_JSON() -> Dictionary:
	var output: Dictionary = {}
	for child in _device_category_holder.get_children():
		if child is not EditDeviceCategory:
			continue
		output.merge((child as EditDeviceCategory).export_as_FEAGI_configurator_JSON())
	if is_input:
		return {"input": output}
	else:
		return {"output": output}

func reset() -> void:
	for child in _device_category_holder.get_children():
		if child is not EditDeviceCategory:
			continue
		child.queue_free() # Risky in a for loop but should be fine since we are queueing

func _user_pressed_add_button() -> void:
	if _add_device_dropdown.selected == -1:
		return
	request_adding_device.emit(_add_device_dropdown.get_item_text(_add_device_dropdown.selected), is_input)
