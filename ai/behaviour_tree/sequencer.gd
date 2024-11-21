## Cycles through each of it's children, one by one.
extends BehaviourTreeFlowController
class_name BehaviourTreeSequencer


# TODO:
# At the moment, changing the order/removing/adding children to this node
# at runtime will have unintended consequences.
# Currently this can somewhat be fixed by reevaluating the tree,
# but this is not ideal.


var current_id := -1


func start(blackboard: Dictionary):
	blackboard.root.connect("reevaluating", func(): current_id = -1)
	super.start(blackboard)
	return


func evaluate() -> BehaviourTreeNode:
	var branches: Array[BehaviourTreeNode] = []
	for child in get_children():
		if is_instance_of(child, BehaviourTreeNode): branches.append(child)
	
	if len(branches) == 0: current_id = -1; return null

	current_id = wrap(current_id + 1, 0, len(branches))
	return branches[current_id]
