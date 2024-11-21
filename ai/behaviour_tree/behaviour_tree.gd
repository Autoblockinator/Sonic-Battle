## The root node of a behaviour tree.
extends Node
class_name BehaviourTree


signal evaluating
signal reevaluating


var active_path: Array[BehaviourTreeNode] = []
var root_flow_controller: BehaviourTreeFlowController = null
var blackboard := {"root": self}


func evaluate():
	if len(active_path) == 0:
		active_path = [root_flow_controller]
		emit_signal("reevaluating")
	else:
		emit_signal("evaluating")

	var path_changed := false
	while !is_instance_of(active_path[-1], BehaviourTreeLeaf):
		assert(is_instance_of(active_path[-1], BehaviourTreeFlowController))
		
		var next: BehaviourTreeNode = active_path[-1].evaluate()
		
		if is_instance_valid(next): active_path.append(next)
		else: active_path.pop_back()
		if len(active_path) == 0: return
		
		path_changed = true
	
	if is_instance_of(active_path[-1], BehaviourTreeLeaf) and path_changed:
		active_path[-1].activated()
	return


## Re-evaluate the entire tree.
func reevaluate(): active_path.clear(); evaluate()


func _ready():
	for child in get_children():
		if is_instance_of(child, BehaviourTreeFlowController):
			root_flow_controller = child
			break
	
	assert(
		is_instance_valid(root_flow_controller),
		"Tree has no valid root flow control node."
	)

	root_flow_controller.start(blackboard)
	evaluate()
	return


func _process(delta: float):
	if len(active_path) > 0:
		if is_instance_of(active_path[-1], BehaviourTreeLeaf):
			active_path[-1].tick(delta)
	
	evaluate()
	return
