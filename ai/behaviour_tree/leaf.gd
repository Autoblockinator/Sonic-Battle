## Responsible for executing ai actions.
extends BehaviourTreeNode
class_name BehaviourTreeLeaf


## Called when this leaf becomes active.
func activated(): return


## Not the same as _process() this only gets called when this leaf is active.
func tick(delta: float): return
