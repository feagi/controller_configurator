extends Tree
class_name TreeSkeletonExplorer

const ICONS_PATH = "res://Steps/Importers/Shared/TreeSkeletonExplorer/icons/"
const GENERIC_ICON_PATH = "res://Steps/Importers/Shared/TreeSkeletonExplorer/icons/generic.png"

signal device_editing_requested(device: FEAGIDevice, from_node: TreeItem) # device may be null if no device is found for the given node

var _robot_config_template_holder_ref: FEAGIRobotConfigurationTemplateHolder

## Call to initialize this object
func setup(ref_to_robot_config_template_holder: FEAGIRobotConfigurationTemplateHolder, imported_possible_devices_root_tree_nodes: Array) -> Error:
	"""
	Expected Structure for imported_possible_devices_tree->
	[
		{
			"name": str name of the node,
			"type": str value with options "body", "input", or "output",
			"feagi device type": str value that exists if type is input or output. defines the type of device
			"properties": dictionary that exists if type is input or output, string keys with the data property with the value being the property
			"description": optional str description of the node. may not exist or be blank,
			"children": array with this dictionary structure recursively
		}
	]
	"""
	clear()
	
	_robot_config_template_holder_ref = ref_to_robot_config_template_holder
	
	if len(imported_possible_devices_root_tree_nodes) == 0:
		push_error("No nodes to import!")
		return Error.ERR_DOES_NOT_EXIST
		
	# Make sure we have only 1 root node. If not, create one root node to hold all given nodes
	var imported_possible_devices_tree: Dictionary
	if len(imported_possible_devices_root_tree_nodes) == 1:
		imported_possible_devices_tree = imported_possible_devices_root_tree_nodes[0]
	else: # we want 1 root node
		imported_possible_devices_tree = {
			"name": "root",
			"type": "body",
			"description": "root node",
			"children": imported_possible_devices_root_tree_nodes
		}
	
	if imported_possible_devices_tree["type"] != "body": # NOTE: Root node must always be a body
		push_error("Root body must be of type 'body'!")
		return Error.ERR_INVALID_DATA
	
	var root_node: TreeItem = create_item(null) 
	var root_node_ok: Error = _check_and_populate_tree_node_UI(root_node, imported_possible_devices_tree)

	if root_node_ok != Error.OK:
		push_error("Root Node Invalid!")
		return Error.ERR_INVALID_DATA
	

	if "children" in imported_possible_devices_tree:
		var children: Array = imported_possible_devices_tree["children"]
		for child_data in children:
			_generate_node_generate_tree(child_data, root_node)
	
	item_selected.connect(_user_clicked_item)
	return Error.OK

func generate_robot_config() -> FEAGIRobotConfiguration:
	
	var root_node: TreeItem = get_root()
	if !root_node:
		push_error("unable to generate inputs or outputs for Generated Robot Config!")
		return  FEAGIRobotConfiguration.create_from_device_listings([], [])
	
	var inputs: Array[FEAGIDevice] = _recursive_return_FEAGI_devices([], true, root_node)
	var outputs: Array[FEAGIDevice] = _recursive_return_FEAGI_devices([], false, root_node)
	
	return FEAGIRobotConfiguration.create_from_device_listings(inputs, outputs)

## Using the set metadata of the node, updates UI elements to reflect
func update_UI_of_node_given_device(tree_node: TreeItem, device: FEAGIDevice) -> void:
	if !device:
		return
	if !tree_node:
		return
	var node_info: Dictionary
	if device.is_input:
		node_info["type"] = "input"
	else:
		node_info["type"] = "output"
	node_info["feagi device type"] = device.device_key
	_check_and_populate_tree_node_UI(tree_node, node_info)


## Returns a tree item if all inputs are valid. Otherwise returns null
func _generate_node_generate_tree(node_info: Dictionary, parent: TreeItem) -> TreeItem:
	
	var node_ok: Error = _confirm_node_details_has_required_keys(node_info)
	if node_ok != Error.OK:
		return null
	
	var new_node: TreeItem = create_item(parent)
	node_ok = _generate_metadata_of_node(new_node, node_info)
	if node_ok != Error.OK:
		push_error("Failed to FEAGI device details for node '%s'! No device will be suggested!" % node_info["name"])
		# No need to stop, just make sure that we can handle null [FEAGIDevice] in signals!
	
	node_ok = _check_and_populate_tree_node_UI(new_node, node_info)
	if node_ok != Error.OK:
		push_error("Failed to load node properties for the UI, skipping this node and its branch!")
		parent.remove_child(new_node)
		return null
	
	if "children" in node_info:
		var children: Array = node_info["children"]
		for child_data in children:
			_generate_node_generate_tree(child_data, new_node)
	
	return new_node

## Checks if for a given node, all required keys exist
func _confirm_node_details_has_required_keys(node_details: Dictionary) -> Error:
	if "name" not in node_details:
		if "custom_name" in node_details:
			if node_details["custom_name"] is not String and node_details["custom_name"] is not StringName:
				push_error("Node is missing 'name' key and has a broken 'custom_name' key! Skipping!")
				return Error.ERR_INVALID_PARAMETER
			push_warning("Node is missing 'name' key but has 'custom_name' key by name of '%s'. Remapping. Note that this is an error in the source data structure and may lead to unexpected results!" % node_details["custom_name"])
			node_details["name"] = node_details["custom_name"]
		else:
			push_error("Missing 'name' key for node!")
			return Error.ERR_INVALID_PARAMETER
	if "type" not in node_details:
		push_error("Missing 'type' key for node!")
		return Error.ERR_INVALID_PARAMETER
	if node_details["type"] not in ["body", "input", "output"]:
		push_error("Unknown type '%s' for node!" % str(node_details["type"]))
		return Error.ERR_INVALID_PARAMETER
	
	if node_details["type"] in ["input", "output"]:
		if not node_details.has("feagi device type"):
			push_error("Missing 'feagi device type' key for IO node!")
			return Error.ERR_INVALID_PARAMETER
		
		if not node_details.has("properties"):
			push_error("Missing 'properties' key! for IO node")
			return Error.ERR_INVALID_PARAMETER
	
	return Error.OK
		

## Generates metadata holding the node type and the feagi device configured (if relevant
func _generate_metadata_of_node(tree_node: TreeItem, node_details: Dictionary) -> Error:
	#var possible_FEAGI_devices: Array[FEAGIDevice] = _init_possible_feagi_devices_for_node(node_details)
	var to_return: Error = Error.OK
	var metadata: Dictionary = {
		"type" : node_details["type"],
		}
	if node_details.get("type") in ["input", "output"]:
		# add "custom_name" to properties
		if node_details.has("properties") and node_details.has("name"):
			node_details["properties"]["custom_name"] = node_details["name"]
		
		metadata["device"] = _init_FEAGI_device_for_node(node_details)
		if metadata["device"] == null:
			to_return = Error.ERR_INVALID_PARAMETER
	tree_node.set_metadata(0, metadata)
	
	return to_return


## Applies UI settings to treenodes
func _check_and_populate_tree_node_UI(tree_node: TreeItem, details: Dictionary) -> Error:
	
	const DEFAULT_COLOR: Color = Color.GRAY
	const INPUT_COLOR: Color = Color.WEB_GREEN
	const OUTPUT_COLOR: Color = Color.DARK_CYAN
	
	if "name" in details:
		tree_node.set_text(0, details["name"])
	if "description" in details:
		tree_node.set_tooltip_text(0, str(details["description"]))
	
	# get icon color skew
	var color_skew: Color = DEFAULT_COLOR
	match details["type"]:
		"input":
			color_skew = INPUT_COLOR
		"output":
			color_skew = OUTPUT_COLOR
		"_":
			pass

	tree_node.set_icon(0, _get_icon_for_node(details))
	tree_node.set_icon_max_width(0, 24)
	tree_node.set_icon_modulate(0, color_skew)
	
	
	return Error.OK


## Assuming node details dict is valid, returns the default [FEAGIDevice] for this node. Otherwise returns null
func _init_FEAGI_device_for_node(node_details: Dictionary) -> FEAGIDevice:
	# Where 'node_details' is the generated details about this node
	
	if node_details.get("type") not in ["input", "output"]:
		push_error("non input/output node type cannot have FEAGI Devices!")
		return null
	
	var is_input: bool = node_details["type"] == "input"
	if not node_details.has("feagi device type"):
		push_error("Input/Output node type does not have a default FEAGI device type defined!")
		return null
	var node_feagi_type: StringName = node_details["feagi device type"]
	
	var FEAGI_device: FEAGIDevice = _robot_config_template_holder_ref.spawn_device_from_template(node_feagi_type, is_input)
	if !FEAGI_device: # if not valid
		push_error("Unable to spawn FEAGI Device of type '%s'!" % node_feagi_type)
		return null
	
	if node_details.has("name"):
		FEAGI_device.label = node_details["name"]
	if node_details.has("description"):
		FEAGI_device.description = node_details["description"]
	
	if node_details.has("properties"):
		FEAGI_device.overwrite_parameter_values(node_details["properties"])
	
	return FEAGI_device
	

func _get_icon_for_node(node_info: Dictionary) -> Texture2D:
	if node_info["type"] == "body":
		return load(str(GENERIC_ICON_PATH))
		
	# load icon
	var loading_path: String = GENERIC_ICON_PATH
	if node_info["type"] != "body":
		loading_path = ICONS_PATH + node_info["type"] + "/" + node_info["feagi device type"] + ".png"
		if !FileAccess.file_exists(loading_path):
			loading_path = GENERIC_ICON_PATH # fallback to generic icon if no specific icon found
	
	return load(str(loading_path))

func _user_clicked_item() -> void:
	var item: TreeItem = get_selected()
	if !item:
		return
	
	if !item.get_metadata(0):
		# likely root node, as there is no metadata here.
		device_editing_requested.emit(null, item)
		return
	
	var metadata: Dictionary = item.get_metadata(0)
	var device: FEAGIDevice = metadata.get("device")
	device_editing_requested.emit(device, item)

func _recursive_return_FEAGI_devices(arr: Array[FEAGIDevice], is_input: bool, current_node: TreeItem) -> Array[FEAGIDevice]:
	if current_node.get_metadata(0):
		var device: FEAGIDevice = current_node.get_metadata(0).get("device")
		if device:
			if is_input == device.is_input:
				arr.append(device)
	for child in current_node.get_children():
		_recursive_return_FEAGI_devices(arr, is_input, child)
	return arr



	
