extends Tree
class_name TreeSkeletonExplorer

signal possible_devices_list_requested(possible_devices: Array[FEAGIDevice])

var _robot_config_template_holder_ref: FEAGIRobotConfigurationTemplateHolder

## Call to initialize this object
func setup(ref_to_robot_config_template_holder: FEAGIRobotConfigurationTemplateHolder, imported_possible_devices_root_tree_nodes: Array) -> Error:
	"""
	Expected Structure for imported_possible_devices_tree->
	[
		{
			"name": str name of the node,
			"type": str value with options "body", "input", or "output",
			"subtype": str value that exists if type is input or output. defines the type of device
			"properties": dictionary that exists if type is input or output, string keys with the data property with the value being the property
			"description": optional str description of the node. may not exist or be blank,
			"children": array with this dictionary structure recursively
		}
	]
	"""
	clear()
	if len(imported_possible_devices_root_tree_nodes) == 0:
		push_error("No nodes to import!")
		return Error.ERR_DOES_NOT_EXIST
	
	
	_robot_config_template_holder_ref = ref_to_robot_config_template_holder
	
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
	
	var root_node: TreeItem = create_item(null) 
	var root_node_ok: Error = _check_and_populate_tree_node_UI(root_node, imported_possible_devices_tree)

	
	if root_node_ok != Error.OK:
		push_error("Root Node Invalid!")
		return Error.ERR_INVALID_DATA
	if imported_possible_devices_tree["type"] != "body": # NOTE: Root node must always be a body
		push_error("Root body must be of type 'body'!")
		return Error.ERR_INVALID_DATA
	

	if "children" in imported_possible_devices_tree:
		var children: Array = imported_possible_devices_tree["children"]
		for child_data in children:
			_generate_node_generate_tree(child_data, root_node)
	
	return Error.OK



## Returns a tree item if all inputs are valid. Otherwise returns null
func _generate_node_generate_tree(node_info: Dictionary, parent: TreeItem    , ) -> TreeItem:
	#TODO theming for type?
	
	var new_node: TreeItem = create_item(parent)
	var node_ok: Error = _check_and_populate_tree_node_UI(new_node, node_info)
	if node_ok != Error.OK:
		push_error("Failed to load node properties for the UI, skipping this node and its branch!")
		parent.remove_child(new_node)
		return null
	node_ok = _generate_metadata_of_node(new_node, node_info)
	if node_ok != Error.OK:
		push_error("Failed to FEAGI device details for node '%s'! No devices will be suggested!" % node_info["name"])
		# no need to stop

	if "children" in node_info:
		var children: Array = node_info["children"]
		for child_data in children:
			_generate_node_generate_tree(child_data, new_node)
	
	return new_node
	
## If details are valid, returns given [TreeItem] with the UI elements updated. Otherwise return null
func _check_and_populate_tree_node_UI(tree_node: TreeItem, details: Dictionary) -> Error:
	# Checks
	if "name" not in details:
		push_error("Missing 'name' key!")
		return Error.ERR_INVALID_PARAMETER
	if "type" not in details:
		push_error("Missing 'type' key!")
		return Error.ERR_INVALID_PARAMETER
	if details["type"] not in ["body", "input", "output"]:
		push_error("Unknown type '%s'!" % str(details["type"]))
		return Error.ERR_INVALID_PARAMETER
	
	tree_node.set_text(0, details["name"])
	if "description" in details:
		tree_node.set_tooltip_text(0, str(details["description"]))
	
	#if "type" in ["input", "output"]:
	# TODO additional UI, colums? icons? buttons?
	return Error.OK

## Generates the possible geagi devices for a given node, and the selector index
func _generate_metadata_of_node(tree_node: TreeItem, node_details: Dictionary) -> Error:
	var possible_FEAGI_devices: Array[FEAGIDevice] = _init_possible_feagi_devices_for_node(node_details)
	if len(possible_FEAGI_devices) == 0:
		# Something went wrong if nothing was found
		return Error.FAILED
	
	var metadata: Dictionary = {
		"selected device index" : 0,
		"possible devices": possible_FEAGI_devices
		}
	tree_node.set_metadata(0, metadata)
	return Error.OK


## Assuming node details dict is valid, returns an array of all possible [FEAGIDevice]s this node could be
func _init_possible_feagi_devices_for_node(node_details: Dictionary) -> Array[FEAGIDevice]:
	# Where 'node_details' is the generated details about this node
	
	if node_details.get("type") not in ["input", "output"]:
		push_error("non input/output node type cannot have FEAGI Devices!")
		return []
	
	var is_input: bool = node_details["type"] == "input"
	var node_subtype: StringName = node_details["subtype"]
	var node_properties: Dictionary = node_details["properties"].duplicate(true)
	
	var possible_matching_types_mappings: Array[Dictionary] = []
	
	var output: Array[FEAGIDevice] = []
	
	for possible_matching_type_mapping in possible_matching_types_mappings:
		var matched_FEAGI_type: StringName = possible_matching_type_mapping["type"]
		var FEAGI_device: FEAGIDevice = _robot_config_template_holder_ref.spawn_device_from_template(matched_FEAGI_type, is_input)
		if !FEAGI_device: # if not valid
			push_error("Unable to spawn FEAGI Device of type '%s'!" % matched_FEAGI_type)
			continue

		## We have the device with default values, lets fill in what we have
		FEAGI_device.label = node_details["name"]
		if "description" in node_details:
			FEAGI_device.description = node_details["description"]
		var node_details_map_to_FEAGI_device_properties: Dictionary = possible_matching_type_mapping["properties"] 
		var new_parameters: Dictionary = node_details["parameters"]
		FEAGI_device.overwrite_parameter_values(new_parameters)

		output.append(FEAGI_device)
	
	return output
