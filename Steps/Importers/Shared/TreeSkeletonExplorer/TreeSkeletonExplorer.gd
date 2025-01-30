extends Tree
class_name TreeSkeletonExplorer

const POSSIBLE_TYPES: PackedStringArray = ["body", "input", "output"]
const POSSIBLE_DATA_TYPES:  PackedStringArray = ["input", "output"]



func import_tree_dictionary(dict: Dictionary) -> Error:
	"""
	Expected Structure ->
	{
		"name": str name of the node,
		"type": str value with options "body", "input", or "output",
		"subtype": str value that exists if type is input or output. defines the type of device
		"properties": dictionary that exists if type is input or output, string keys with the data property with the value being the property
		"description": optional str description of the node. may not exist or be blank,
		"children": array with this dictionary structure recursively
	}
	"""
	
	clear()
	var root_node: TreeItem = create_item(null)
	if !_populate_details(root_node, dict):
		push_error("Root Node Invalid!")
		return Error.ERR_INVALID_DATA
	
	if "children" in dict:
		var children: Array = dict["children"]
		for child_data in children:
			_generate_nod_generate_tree(child_data, root_node)

	return Error.OK


## Returns a tree item if all inputs are valid. Otherwise returns null
func _generate_nod_generate_tree(node_info: Dictionary, parent: TreeItem) -> TreeItem:
	#TODO theming for type?
	
	var new_node: TreeItem = create_item(parent)
	new_node = _populate_details(new_node, node_info)
	if !new_node:
		push_error("Failed to load node properties, skipping this node and its branch!")
		return null
	
	if "children" in node_info:
		var children: Array = node_info["children"]
		for child_data in children:
			_generate_nod_generate_tree(child_data, new_node)
	
	return new_node
	
## If details are valid, returns given [TreeItem] with the properties inserted. Otherwise return null
func _populate_details(tree_node: TreeItem, details: Dictionary) -> TreeItem:
	# Checks
	if "name" not in details:
		push_error("Missing 'name' key!")
		return null
	if "type" not in details:
		push_error("Missing 'type' key!")
		return null
	if details["type"] not in POSSIBLE_TYPES:
		push_error("Unknown type '%s'!" % str(details["type"]))
		return null
	var metadata: Dictionary = {"type": details["type"]}
	if "type" in POSSIBLE_DATA_TYPES:
		if "subtype" not in details:
			push_error("Missing 'subtype' key!")
			return null
		if "properties" not in details:
			push_error("Missing 'properties' key!")
			return null
		metadata["subtype"] = details["subtype"]
		metadata["properties"] = details["properties"].duplicate(true)
	
	tree_node.set_text(0, details["name"])
	tree_node.set_metadata(0, metadata)
	if "description" in details:
		tree_node.set_tooltip_text(0, str(details["description"]))
	return tree_node
