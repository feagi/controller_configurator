extends Tree
class_name TreeSkeletonExplorer

signal possible_devices_list_requested(possible_devices: Array[FEAGIDevice])

var _JSON_device_mapper: Dictionary # see _import_mapping_dictionary for expected structure
var _robot_config_template_holder_ref: FEAGIRobotConfigurationTemplateHolder

## Call to initialize this object
func setup(JSON_device_mapper_path: StringName, ref_to_robot_config_template_holder: FEAGIRobotConfigurationTemplateHolder, imported_possible_devices_root_tree_nodes: Array) -> Error:
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
	
		
	
	_JSON_device_mapper = _import_mapping_dictionary(JSON_device_mapper_path)
	_robot_config_template_holder_ref = ref_to_robot_config_template_holder
	
	var imported_possible_devices_tree: Dictionary
	if len(imported_possible_devices_root_tree_nodes) == 1:
		imported_possible_devices_tree = imported_possible_devices_root_tree_nodes[0]
	else:
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


## Reads and verifies the mapping file for mapping types of devices from the config file import, to [FEAGIDevice] types
func _import_mapping_dictionary(JSON_device_mapper_path: StringName) -> Dictionary:
	"""
	Expected Structure ->
	{
		str type (matching string from tree dictionary 'type') : 
		[ # arr of all possible matching types
			{
				"type" : str type name as defined by FEAGI template JSON,
				"properties": {
					str property name from tree : str property name from FEAGI template
			},
		]
	}
	"""

	if !FileAccess.file_exists(JSON_device_mapper_path):
		push_error("Unable to find device mapper JSON from given path!")
		return {}
	var file_text: String = FileAccess.get_file_as_string(JSON_device_mapper_path)
	if file_text == "":
		push_error("Unable to open device mapper JSON from given path!")
		return {}
	var json: Variant = JSON.parse_string(file_text)
	if json is not Dictionary:
		push_error("Unable to open device mapper JSON as a dictionary!")
		return {}
	
	return json as Dictionary


## Returns a tree item if all inputs are valid. Otherwise returns null
func _generate_node_generate_tree(node_info: Dictionary, parent: TreeItem    , ) -> TreeItem:
	#TODO theming for type?
	
	var new_node: TreeItem = create_item(parent)
	var node_ok: Error = _check_and_populate_tree_node_UI(new_node, node_info)
	if node_ok != Error.OK:
		push_error("Failed to load node properties for the UI, skipping this node and its branch!")
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
	# Where 'node_details' is the generate details about this node
	
	if !_JSON_device_mapper.has("output"):
		push_error("Missing output device tempaltes!")
		return []
	
	var device_mapper_IO: Dictionary = _JSON_device_mapper["output"]
	var is_input: bool = node_details["type"] == "input"
	
	if is_input:
		if !_JSON_device_mapper.has("input"):
			push_error("Missing input device tempaltes!")
			return []
		device_mapper_IO = _JSON_device_mapper["input"]
		
		
	var node_subtype: StringName = node_details["subtype"]
	var node_properties: Dictionary = node_details["properties"].duplicate(true)
	
	if node_subtype not in device_mapper_IO.keys():
		push_error("Unable to match any Feagi Devices for device type %s! Are the device mapper JSONs up to date?" % node_subtype)
		return []
	
	var possible_matching_types_mappings: Array[Dictionary] = []
	possible_matching_types_mappings.assign(device_mapper_IO["subtype"])
	
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
		var new_parameters: Dictionary = _move_properties_to_from_old_keynames_to_new_mapped_keynames(node_details["parameters"], node_details_map_to_FEAGI_device_properties)
		FEAGI_device.overwrite_parameter_values(new_parameters)

		output.append(FEAGI_device)
	
	return output


func _move_properties_to_from_old_keynames_to_new_mapped_keynames(original_dict: Dictionary, mappings: Dictionary) -> Dictionary:
	var output: Dictionary = {}
	for original_key in original_dict:
		if original_key in mappings.keys():
			output[mappings[original_key]] = original_dict[original_key]
	return output
