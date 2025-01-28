extends RefCounted
class_name IntermediateAbstractNode
## When importing from tree like structure configs, this node object can be used to construct trees representing their parts

var icon: Texture
var node_name: StringName

var _parent_node: IntermediateAbstractNode = null
var _children_nodes: Array[IntermediateAbstractNode] = []

## Returns current parent of the node, or null if this node is a root node
func get_parent() -> IntermediateAbstractNode:
	return _parent_node

## Gets all children of this node
func get_children() -> Array[IntermediateAbstractNode]:
	return _children_nodes
	
## Sets a new parent to this node (also updates old / new parent nodes)
func set_parent(new_parent: IntermediateAbstractNode) -> Error:
	if _parent_node:
		_parent_node.remove_child_by_reference(self)
	if new_parent:
		_parent_node = new_parent
		if self in new_parent.get_children():
			return Error.OK # already a child of the new parent
		return new_parent.add_child(self)
	_parent_node = null
	return Error.OK

func add_child(new_child: IntermediateAbstractNode) -> Error:
	if new_child in _children_nodes:
		return Error.ERR_ALREADY_EXISTS
	_children_nodes.append(new_child)
	if new_child.get_parent() != self:
		new_child.set_parent(self)
	return Error.OK

func remove_child_by_reference(removing_child: IntermediateAbstractNode) -> Error:
	var index: int = _children_nodes.find(removing_child)
	if index == -1:
		return Error.ERR_DOES_NOT_EXIST
	_children_nodes.remove_at(index)
	if removing_child.get_parent() == self:
		removing_child.set_parent(null)
	return Error.OK

## Returns as a Dictionary key'd by the StringName of the children nodes, with the value being the recursive call to this function (another Dictionary key'd by keyname, and valued of those children...)
func as_dictionary_tree() -> Dictionary[StringName, Dictionary]:
	var output: Dictionary[StringName, Dictionary] = {}
	for child in _children_nodes:
		var merge: Dictionary[StringName, Dictionary] = {child.node_name: child.as_dictionary_tree()}
		output.merge(merge)
	return output
	
	
